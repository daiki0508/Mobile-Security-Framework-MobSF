#!/bin/bash

# Python3 Check
unamestr=$(uname)
if ! [ -x "$(command -v python3)" ]; then
    echo '[ERROR] python3 is not installed.' >&2
    exit 1
fi

# Python3 Version Check
python_version="$(python3 --version 2>&1 | awk '{print $2}')"
py_major=$(echo "$python_version" | cut -d'.' -f1)
py_minor=$(echo "$python_version" | cut -d'.' -f2)
if [ "$py_major" -eq "3" ] && [ "$py_minor" -gt "9" ] && [ "$py_minor" -lt "13" ]; then
    echo "[INSTALL] Found Python ${python_version}"
else
    echo "[ERROR] MobSF dependencies require Python 3.10 - 3.12. You have Python version ${python_version} or python3 points to Python ${python_version}."
    exit 1
fi

# Pipの仮想環境の確認
if [ -z "$VIRTUAL_ENV" ]; then
    echo "You are not in a pipenv virtual environment."
    exit 1
else
    echo "You are in a pipenv virtual environment: $VIRTUAL_ENV"
fi

# Pip Check and Upgrade
python3 -m pip -V
if [ $? -eq 0 ]; then
    echo '[INSTALL] Found pip'
    if [[ $unamestr == 'Darwin' ]]; then
        python3 -m pip install --no-cache-dir --upgrade pip
    else
        python3 -m pip install --no-cache-dir --upgrade pip --user
    fi
else
    echo '[ERROR] python3-pip not installed'
    exit 1
fi

# macOS Specific Checks
if [[ $unamestr == 'Darwin' ]]; then
    # Check if xcode is installed
    xcode-select -v
    if ! [ $? -eq 0 ]; then
        echo 'Please install command-line tools'
        echo 'xcode-select --install'
        exit 1
    else
        echo '[INSTALL] Found Xcode'
	  fi    
fi

echo '[Update] Update Requirements'
poetry update

echo '[INSTALL] Migrating Database'
python3 -m poetry run python manage.py makemigrations
python3 -m poetry run python manage.py makemigrations StaticAnalyzer
python3 -m poetry run python manage.py migrate
python3 -m poetry run python manage.py create_roles

poetry run python mobsf/MobSF/tools_download.py ~/.MobSF
DJANGO_SUPERUSER_PASSWORD=mobsf poetry run python manage.py createsuperuser --noinput --username "mobsf" --email ""