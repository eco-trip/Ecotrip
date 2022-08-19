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

#### 2) Start local environment

```sh
bash start.sh # -d if you want docker compose like a daemon
```

- Setup your env variables
- Start docker compose
