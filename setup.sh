#!/bin/bash

source .env

# CHECK OPT FOR CUSTOM AWS PROFILE TO OVERRIDE .env
while getopts ":a:r:" opt; do
	case $opt in
	h)
		echo "This script setup your development environment.
    Flags:
      -a  Specify the aws profile to use [optional]
			-r  Specify the aws default region [optional]"
		exit
		;;
	a)
		AWS_PROFILE="$OPTARG"
		;;
	r)
		AWS_DEFAULT_REGION="$OPTARG"
		;;
	\?)
		echo "Invalid option: -$OPTARG"
		;;
	esac
done

# SET AWS REGION, PROFILE AND THE WAY THE RESPONSES ARE SHOWN FOR ALL COMMANDS
export AWS_PROFILE=$AWS_PROFILE
export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION
export AWS_PAGER=""

echo "AWS_PROFILE: ${AWS_PROFILE}"
echo "AWS_DEFAULT_REGION: ${AWS_DEFAULT_REGION}"

# GET SECTRETS
Secrets=$(aws secretsmanager get-secret-value --region ${AWS_DEFAULT_REGION} --profile ${AWS_PROFILE} --secret-id ${AWS_SECRETS} --cli-connect-timeout 1)
Project=$(echo ${Secrets} | jq .SecretString | jq -rc . | jq -rc '.Project')
AWS_ACCESS_KEY_ID=$(echo ${Secrets} | jq .SecretString | jq -rc . | jq -rc '.AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY=$(echo ${Secrets} | jq .SecretString | jq -rc . | jq -rc '.AWS_SECRET_ACCESS_KEY')

# SET FONT AWESOME KEY
echo "-> SET FONT AWESOME KEY"
FontAwesomeKey=$(echo ${Secrets} | jq .SecretString | jq -rc | jq -rc '.FontAwesomeKey')
sed "s/__FontAwesomeKey__/${FontAwesomeKey}/g" ./CP/.npmrc.template >./CP/.npmrc
sed "s/__FontAwesomeKey__/${FontAwesomeKey}/g" ./App/.npmrc.template >./App/.npmrc

echo "-> [Administration] npm install"
cd ./Administration
npm ci

echo "-> [Administration] prepare env file"
cp .env .env.development
echo "" >>.env.development
echo "Project=${Project}" >>.env.development
echo "" >>.env.development
echo "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" >>.env.development
echo "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" >>.env.development

echo "-> [Cp] npm install"
cd ../CP
npm ci

echo "-> [App] npm install"
cd ../App
npm ci

# COGNITO AWS FOR GITHUB USER
echo "-> [Cognito] AWS environment setup"
cd ../Cognito/deploy
bash deploy.sh -e dev
