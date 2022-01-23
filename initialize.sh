#!/bin/bash
set -x
# Setup barebones python project
## Usage
### init $project_name [$python_version=3.10.0]
### init my_python_project 3.8.1
PROJECT_NAME=${1}
PYTHON_VERSION=${2:-"3.9.0"}
## Install pyenv
### assumes you have Linux based OS and permissions to run apt-get
### check if pyenv is already installed
if command -v pyenv &> /dev/null
then
    echo "pyenv installation found, updating it!"
    pyenv update
else
    ## Install dependencies
    sudo apt-get update -y
    sudo apt-get -y install make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
    ### as per https://github.com/pyenv/pyenv-installer
    curl https://pyenv.run | bash
    exec $SHELL
fi
pyenv install -v $PYTHON_VERSION --skip-existing
pyenv local $PYTHON_VERSION

## Install pipx
python -m pip install --user pipx
python -m pipx ensurepath

## Poetry to manage dependencies
pipx install poetry

## Initialize new project
poetry new $PROJECT_NAME
cp .pre-commit-config.yaml $PROJECT_NAME/.pre-commit-config.yaml
cd $PROJECT_NAME
pyenv local $PYTHON_VERSION
## Git specific setup
sudo apt-get -y install git-all
git init
## .gitignore for python (standard github version from https://github.com/github/gitignore/blob/main/Python.gitignore)
curl -o .gitignore https://raw.githubusercontent.com/github/gitignore/main/Python.gitignore

## Specify some dev libraries
poetry add --dev black flake8 pytest
## Specify pre-commit library
poetry add pre-commit
pre-commit install
