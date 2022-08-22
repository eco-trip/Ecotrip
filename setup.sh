#!/bin/bash

source .env

# CHECK OPT FOR CUSTOM AWS PROFILE TO OVERRIDE .env
while getopts ":a:" opt; do
	case $opt in
	a)
		AWS_PROFILE="$OPTARG"
		;;
	esac
done

# SET AWS REGION, PROFILE AND THE WAY THE RESPONSES ARE SHOWN FOR ALL COMMANDS
export AWS_PROFILE=$AWS_PROFILE
export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION
export AWS_PAGER=""

echo "AWS_PROFILE: ${AWS_PROFILE}"
echo "AWS_DEFAULT_REGION: ${AWS_DEFAULT_REGION}"

# GET SECRET FOR FONT AWESOME
FontAwesomeKey=$(aws secretsmanager get-secret-value --region ${AWS_DEFAULT_REGION} --profile ${AWS_PROFILE} --secret-id ${AWS_SECRETS} --cli-connect-timeout 1 | jq .SecretString | jq -rc | jq -rc '.FontAwesomeKey')
sed "s/__FontAwesomeKey__/${FontAwesomeKey}/g" ./CP/.npmrc.template >./CP/.npmrc
sed "s/__FontAwesomeKey__/${FontAwesomeKey}/g" ./App/.npmrc.template >./App/.npmrc

# NPM INSTALL
cd ./Administration
npm ci
cd ../CP
npm ci
cd ../App
npm ci

cd ..
