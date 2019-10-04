Class {
	#name : #BaselineOfAwsLambda,
	#superclass : #BaselineOf,
	#category : #BaselineOfAwsLambda
}

{ #category : #baselines }
BaselineOfAwsLambda >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ spec
				baseline: 'OSSubprocess'
				with: [ spec
						repository: 'github://pharo-contributions/OSSubprocess:master/repository';
						loads: #default ].
			spec
				package: 'AWS-Lambda-Core'
					with: [ spec requires: #('OSSubprocess') ];
				group: 'default' with: #('core');
				group: 'core' with: #('AWS-Lambda-Core');
				yourself ]
]
