Class {
	#name : #PhxJsonReader,
	#superclass : #PjDomController,
	#instVars : [
		'knownObjects'
	],
	#category : #'Phx-JSON-Core'
}

{ #category : #testing }
PhxJsonReader class >> areWeOnServer [
^ (Smalltalk at: #PhxApp) notNil
]

{ #category : #'instance creation' }
PhxJsonReader class >> materializeJsonString: aString [
	<javascript: 'return JSON.parse(aString)'>
	"returns a javascript object in js world"
	"returns a dictionary in st world"
	^ Json readFrom: aString readStream
]

{ #category : #'instance creation' }
PhxJsonReader class >> readFromJsObjectOrDictionary: jsObjectOrDictionary [
	^ self new readFromJsObjectOrDictionary: jsObjectOrDictionary
]

{ #category : #'instance creation' }
PhxJsonReader class >> readFromString: aString [

	^ self readFromJsObjectOrDictionary: (self materializeJsonString: aString)
]

{ #category : #'instance creation' }
PhxJsonReader >> classNameForJsonClassName: jsonClassName [
	<javascript:
		'if(jsonClassName == "DateAndTime") { return "Date"}
if(jsonClassName == "Dictionary") { return "PjDictionary"}
return jsonClassName;'>
	^ jsonClassName
]

{ #category : #'initialize-release' }
PhxJsonReader >> initialize [
	knownObjects := OrderedCollection new
]

{ #category : #'instance creation' }
PhxJsonReader >> readFromJsObjectOrDictionary: jsonObject [
	| jsonClassName |
	jsonObject ifNil: [ ^ nil ].
	jsonObject isString
		ifTrue: [ ^ jsonObject ].
	jsonObject isNumber
		ifTrue: [ ^ jsonObject ].
	jsonObject == true
		ifTrue: [ ^ true ].
	jsonObject == false
		ifTrue: [ ^ false ].
	(jsonObject at: 'instRef' ifAbsent: [ nil ])
		ifNotNil: [ :idx | ^ knownObjects at: idx ].
	jsonClassName := jsonObject at: 'class' ifAbsent: [ nil ].
	(self classNameForJsonClassName: jsonClassName)
		ifNotNil: [ :className | 
			| class instJsonObject |
			class := Smalltalk at: className asSymbol ifAbsent: [ nil ].
			class ifNil: [ self error: 'Class not found: ' , className ].
			instJsonObject := jsonObject at: 'instance'.
			^ knownObjects
				add:
					(class
						instantiateWithPhxJsonReader: self
						instanceJsonObject: instJsonObject) ].
	^ self error
]