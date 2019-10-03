Class {
	#name : #Lambda,
	#superclass : #Object,
	#category : #'AWS-Lambda-Core'
}

{ #category : #accessing }
Lambda class >> runtime_api [
	^ OSEnvironment current at: 'AWS_LAMBDA_RUNTIME_API'
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
	| request request_id |
	[ request := ZnEasy get: self runtime_api_next_url.
		request_id := request headers at: 'Lambda-Runtime-Aws-Request-Id'.
		ZnEasy post: (self runtime_api_reponse_url: request_id) data:(ZnEntity json: '{"hello W"}') ]
	repeat.
]
