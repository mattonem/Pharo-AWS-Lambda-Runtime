Class {
	#name : #Lambda,
	#superclass : #Object,
	#category : #'AWS-Lambda-Core'
}

{ #category : #accessing }
Lambda class >> action: aRequest [
	^  aRequest contents
]

{ #category : #accessing }
Lambda class >> initLambda [
	"Do nothing. To be overwritten"
]

{ #category : #accessing }
Lambda class >> runtime_api [
	^ OSEnvironment current at: 'AWS_LAMBDA_RUNTIME_API'
]

{ #category : #accessing }
Lambda class >> runtime_api_error_url: anId [
	^ self runtime_api_url , anId, '/error'
]

{ #category : #accessing }
Lambda class >> runtime_api_init_error_url [
	^ 'http://',self runtime_api,'/2018-06-01/runtime/init/error'
]

{ #category : #accessing }
Lambda class >> runtime_api_next_url [
	^ self runtime_api_url , 'next'
]

{ #category : #accessing }
Lambda class >> runtime_api_reponse_url: anId [
	^ self runtime_api_url , anId, '/response'
]

{ #category : #accessing }
Lambda class >> runtime_api_url [
	^ 'http://',self runtime_api,'/2018-06-01/runtime/invocation/'
]

{ #category : #accessing }
Lambda class >> start [
	| request request_id response |
	[ self initLambda ]
		on: Exception
		do: [ :e | 
			ZnEasy
				post: self runtime_api_init_error_url
				data: (ZnEntity json: '{"error_message": "' , e messageText , '"}') ].
	[ request := ZnEasy get: self runtime_api_next_url.
	request_id := request headers at: 'Lambda-Runtime-Aws-Request-Id'.
	[ response := self action: request.
	ZnEasy
		post: (self runtime_api_reponse_url: request_id)
		data: (ZnEntity json: response) ]
		on: Exception
		do: [ :e | 
			ZnEasy
				post: (self runtime_api_error_url: request_id)
				data: (ZnEntity json: '{"error_message": "' , e messageText , '"}') ] ]
		repeat
]
