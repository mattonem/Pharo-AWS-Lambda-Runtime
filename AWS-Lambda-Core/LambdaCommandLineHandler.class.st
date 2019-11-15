Class {
	#name : #LambdaCommandLineHandler,
	#superclass : #CommandLineHandler,
	#instVars : [
		'httpClient'
	],
	#category : #'AWS-Lambda-Core'
}

{ #category : #accessing }
LambdaCommandLineHandler >> activate [
	| request request_id response |
	[ self initLambda ]
		on: Exception
		do: [ :e | ^ self sendInitError: e ].
	[ [ request := self getNextRequest.
	request_id := request headers at: 'Lambda-Runtime-Aws-Request-Id' ]
		on: Exception
		do: [ :e | ^ self sendInitError: e ].
	[ response := self lambdaAction: (NeoJSONReader fromString: request contents).
	self postResponse: (NeoJSONWriter toString: response) id: request_id ]
		on: Exception
		do: [ :e | self sendError: request_id id: e ] ] repeat
]

{ #category : #accessing }
LambdaCommandLineHandler >> getNextRequest [
	| request |
	request := httpClient
		url: self runtime_api_next_url;
		get;
		response.
	^ request
]

{ #category : #accessing }
LambdaCommandLineHandler >> initLambda [ 	
	httpClient := ZnClient new.

]

{ #category : #accessing }
LambdaCommandLineHandler >> lambdaAction: aRequest [ 
	^  aRequest contents	

]

{ #category : #accessing }
LambdaCommandLineHandler >> postResponse: response id: request_id [
	^ httpClient
		url: (self runtime_api_reponse_url: request_id);
		entity: (ZnEntity json: response);
		post
]

{ #category : #accessing }
LambdaCommandLineHandler >> runtime_api [
	^ OSEnvironment current at: 'AWS_LAMBDA_RUNTIME_API'
]

{ #category : #accessing }
LambdaCommandLineHandler >> runtime_api_error_url: anId [ 	
	^ self runtime_api_url , anId asString, '/error'	

]

{ #category : #accessing }
LambdaCommandLineHandler >> runtime_api_init_error_url [ 	
	^ 'http://',self runtime_api,'/2018-06-01/runtime/init/error'	

]

{ #category : #accessing }
LambdaCommandLineHandler >> runtime_api_next_url [
	^ self runtime_api_url , 'next'
]

{ #category : #accessing }
LambdaCommandLineHandler >> runtime_api_reponse_url: anId [
	^ self runtime_api_url , anId, '/response'
]

{ #category : #accessing }
LambdaCommandLineHandler >> runtime_api_url [
	^ 'http://',self runtime_api,'/2018-06-01/runtime/invocation/'
]

{ #category : #accessing }
LambdaCommandLineHandler >> sendError: request_id id: e [
	^ httpClient
		url: (self runtime_api_error_url: request_id);
		entity: (ZnEntity json: '{"error_message": "' , e messageText , '"}');
		post
]

{ #category : #accessing }
LambdaCommandLineHandler >> sendInitError: e [
	^ httpClient
		url: self runtime_api_init_error_url;
		entity: (ZnEntity json: '{"error_message": "' , e messageText , '"}');
		post
]
