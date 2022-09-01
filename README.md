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
```

- Retrieve secret key for FontAwesome npm packages
- Install all npm dependencies on Administration, CP and App
- Optional: you can pass argument "-a" for select your aws profile if you have multiple account configured on aws cli. Otherwise the profile used is "default"

#### 2) Deploy aws resurce for developing

```sh
cd deploy && bash deploy.sh -e dev
```

#### 3) Start docker compose

```sh
docker compose up #-d if you want daemon
```

## Prepare AWS

The following action are required for prepare AWS first time for the project

1. Create Certificate for all subdomains
2. Create Route53 zone
3. Create bucket s3 with urls
4. Create SES (Simple email service)
5. Create secret with:
   - FontAwesomeKey
   - AcmArn (Certificate ARN)
   - SesArn (SES ARN)
   - HostedZoneId (Route53 zone id)

### Deploy cognito

```sh
cd deploy && bash deploy.sh -e [ENV]
```

If "dev" env create cognito user pool with standard domain with git username:

- https://[AuthUrl].auth.$[AWS_DEFAULT_REGION].amazoncognito.com
- es: auth-ecotrip-brteo.auth.eu-west-1.amazoncognito.com

Else create cognito with custom domain name and dns record set

- [staging] auth.staging.ecotrip.meblabs.dev
- [production] auth.ecotrip.meblabs.dev
