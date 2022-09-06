# Ecotrip

Main repository

## Requirements

- Node, Npm, Docker
- [aws cli configured](https://docs.aws.amazon.com/it_it/translate/latest/dg/setup-awscli.html)
- [aws sam](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html)
- [jq](https://stedolan.github.io/jq/download/)

## Git

Clone with submodules

```sh
git clone --recurse-submodules <URL>
```

Recursively updates all submbodules

Update submodules, pulling does not update submodules by default

```sh
git submodule update --remote --recursive
```

Pull all submodules

```sh
git submodule foreach git pull
```

## Install

#### 1) Setup your environment:

```sh
bash setup.sh
# Optional: you can pass argument to override .env file
# - "-a" for select your aws profile if you have multiple account configured on aws cli.
# - "-r" for select aws region
```

This script will do:

- Retrieve secret key for FontAwesome npm packages
- Install all npm dependencies on Administration, CP and App
- Deploy cognito environment for your github user

#### 2) Start docker compose

```sh
docker compose up # -d if you want daemon
```

## Prepare AWS

The following action are required for prepare AWS first time for the project

1. Create Certificate for all subdomains
2. Create Route53 zone
3. Create bucket s3 with urls.json file
4. Create SES (Simple email service)
5. Create secret with:
   - Project (The name of project)
   - Urls (The S3 url with urls.json file)
   - FontAwesomeKey
   - AcmArn (Certificate ARN)
   - SesArn (SES ARN)
   - HostedZoneId (Route53 zone id)
6. Set secret ARN into .env file for root repo and all submnodules
