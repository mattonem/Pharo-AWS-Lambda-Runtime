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
				baseline: 'NeoJSON'
				with: [ spec
						repository: 'github://svenvc/NeoJSON/repository';
						loads: #core ].
			spec
				package: 'AWS-Lambda-Core' with: [ spec requires: #(NeoJSON) ];
				package: 'AWS-Lambda-Build'
					with: [ spec requires: #('AWS-Lambda-Core' 'OSSubprocess') ];
				group: 'default' with: #('core' 'build');
				group: 'build' with: #('AWS-Lambda-Build');
				group: 'core' with: #('AWS-Lambda-Core');
				yourself ]
]
