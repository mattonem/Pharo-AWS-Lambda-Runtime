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
Lambda class >> bootstrap: className [
	| w |
	w := WriteStream on: (String new: 100).
	w
		<< '#!/bin/sh';
		lf;
		<< 'cd $LAMBDA_TASK_ROOT';
		lf;
		<< './pharo Pharo.image --no-default-preferences eval ';
		<< className;
		<< ' start';
		lf.
	^ w contents
]

{ #category : #accessing }
Lambda class >> build [
	| workingDir |
	workingDir := self createWorkingDir.
	self zeroConfPharoInto: workingDir.
	OSSUnixSubprocess new
		shellCommand:
			'./pharo Pharo.image metacello install github://mattonem/Phlog:master BaselineOfPhlog';
		workingDirectory: workingDir absolutePath fullName;
		runAndWait.
	workingDir / 'bootstrap'
		writeStreamDo: [ :w | w << (self bootstrap: 'Phlog') ].
	OSSUnixSubprocess new
		shellCommand:
			'./pharo Pharo.image metacello install github://mattonem/Phlog:master BaselineOfPhlog';
		workingDirectory: workingDir absolutePath fullName;
		runAndWait.
	OSSUnixSubprocess new
		shellCommand:
			'zip -r function.zip *.image *.changes *.sources pharo pharo-vm bootstrap';
		workingDirectory: workingDir absolutePath fullName;
		runAndWait
]

{ #category : #accessing }
Lambda class >> buildRepo: url baseline: baseline lambdaClass: lambda [
	| workingDir |
	workingDir := self createWorkingDir.
	self zeroConfPharoInto: workingDir.
	self installProject: baseline from: url workingDir: workingDir.
	self createBootstrapInto: workingDir lambda: lambda.
	OSSUnixSubprocess new
		shellCommand:
			'zip -r function.zip ./*';
		workingDirectory: workingDir absolutePath fullName;
		runAndWait
]

{ #category : #accessing }
Lambda class >> createBootstrapInto: workingDir lambda: lambda [
	(workingDir / 'bootstrap') ensureCreateFile.
	(workingDir / 'bootstrap')
		writeStreamDo: [ :w | w << (self bootstrap: lambda). w close ].
	OSSUnixSubprocess new
		shellCommand: 'chmod +x bootstrap';
		workingDirectory: workingDir absolutePath fullName;
		runAndWait.
	(workingDir / 'bootstrap') 
]

{ #category : #accessing }
Lambda class >> createWorkingDir [
	| workingDir |
	workingDir := FileSystem workingDirectory / 'build'.
	workingDir exists
		ifTrue: [ workingDir deleteAll ].
	workingDir ensureCreateDirectory.
	^ workingDir
]

{ #category : #accessing }
Lambda class >> installProject: baseline from: url workingDir: workingDir [
	OSSUnixSubprocess new
		shellCommand: './pharo Pharo.image metacello install ' , url , ' ' , baseline;
		workingDirectory: workingDir absolutePath fullName;
		runAndWait
]

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
	| request request_id response |
	[ request := ZnEasy get: self runtime_api_next_url.
	request_id := request headers at: 'Lambda-Runtime-Aws-Request-Id'.
	response := self action: request.
	ZnEasy
		post: (self runtime_api_reponse_url: request_id)
		data: (ZnEntity json: response) ] repeat
]

{ #category : #accessing }
Lambda class >> zeroConfPharoInto: workingDir [
	OSSUnixSubprocess new
		shellCommand: 'curl https://get.pharo.org/64/70+vm | bash';
		workingDirectory: workingDir absolutePath fullName;
		runAndWait
]
