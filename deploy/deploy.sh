#!/bin/bash

source parameters

# GET SECTRETS
secrets=$(aws secretsmanager get-secret-value --secret-id ${AWS_SECRETS} --cli-connect-timeout 1)
AcmArn=$(echo ${secrets} | jq .SecretString | jq -rc . | jq -rc '.AcmArn')
SesArn=$(echo ${secrets} | jq .SecretString | jq -rc . | jq -rc '.SesArn')
HostedZoneId=$(echo ${secrets} | jq .SecretString | jq -rc . | jq -rc '.HostedZoneId')

# GET URL FROM S3 AND SET VARIABLES
aws s3 cp ${urls} ./urls.json
AuthUrl=$(cat urls.json | jq ".auth.${env}" | tr -d '"')

# COGNITO
CognitoURI=${URI}-cognito
if [ "$env" = "dev" ]; then
	CognitoUrl=$(echo ${AuthUrl/__username__/$git_username})

	# create cognito with non custom url
	# https://${CognitoUrl}.auth.${AWS_DEFAULT_REGION}.amazoncognito.com
	parameters="ParameterKey=URI,ParameterValue=${CognitoURI} ParameterKey=Url,ParameterValue=${CognitoUrl} ParameterKey=SesArn,ParameterValue=${SesArn}"
	sam build -t ./cognito.yml -b .aws-sam/cognito/ --parameter-overrides ${parameters}
	sam deploy --template-file .aws-sam/cognito/template.yaml --stack-name ${CognitoURI} --disable-rollback --resolve-s3 --parameter-overrides ${parameters} --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND --tags project=${project} env=${env} creator=${git_username}

	echo "https://${CognitoUrl}.auth.${AWS_DEFAULT_REGION}.amazoncognito.com"
else
	CognitoUrl=${AuthUrl}

	#create cognito
	parameters="ParameterKey=URI,ParameterValue=${CognitoURI} ParameterKey=Url,ParameterValue=${CognitoUrl} ParameterKey=SesArn,ParameterValue=${SesArn} ParameterKey=AcmArn,ParameterValue=${AcmArn}"
	sam build -t ./cognito.yml -b .aws-sam/cognito/ --parameter-overrides ${parameters}
	sam deploy --template-file .aws-sam/cognito/template.yaml --stack-name ${CognitoURI} --disable-rollback --resolve-s3 --parameter-overrides ${parameters} --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND --tags project=${project} env=${env} creator=${git_username}

	#get cloudfront distribution for cognito custom domain (in cloud formation can't retrive it)
	CognitoCFD=$(aws cognito-idp describe-user-pool-domain --domain ${CognitoUrl} --region ${AWS_DEFAULT_REGION} --profile ${AWS_PROFILE} | jq -r '.DomainDescription.CloudFrontDistribution')
	CognitoDnsURI=${URI}-cognito-dns

	#create dns record for cognito custom domain
	parameters="ParameterKey=Url,ParameterValue=${CognitoUrl} ParameterKey=CognitoCFD,ParameterValue=${CognitoCFD} ParameterKey=HostedZoneId,ParameterValue=${HostedZoneId}"
	sam build -t ./cognito_dns.yml -b .aws-sam/cognito_dns/ --parameter-overrides ${parameters}
	sam deploy --template-file .aws-sam/cognito_dns/template.yaml --stack-name ${CognitoDnsURI} --disable-rollback --resolve-s3 --parameter-overrides ${parameters} --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND --tags project=${project} env=${env} creator=${git_username}
fi
