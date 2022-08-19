#!/bin/bash

source .env
>.env.development

echo rootFolder=$(pwd) >>./.env.development
source .env.development
echo gitUsername=$(echo $(git config user.name) | tr '[:upper:]' '[:lower:]') >>./.env.development

source .env.development
deamon=false

while getopts ":d:a:" opt; do
	case $opt in
	d)
		deamon=true
		;;
	a)
		AWS_PROFILE="$OPTARG"
		;;
	esac
done

# SET AWS REGION, PROFILE AND THE WAY THE RESPONSES ARE SHOWN FOR ALL COMMANDS
export AWS_PROFILE=$AWS_PROFILE
export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION
export AWS_PAGER=""

if [ $deamon == "true" ]; then
	echo "Starting deamon mode..."
	docker compose up -d
else
	docker compose up
fi
