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

echo '[INSTALL] Migrating Database'
export DJANGO_SUPERUSER_USERNAME=mobsf
export DJANGO_SUPERUSER_PASSWORD=mobsf
python3 -m poetry run python manage.py makemigrations
python3 -m poetry run python manage.py makemigrations StaticAnalyzer
python3 -m poetry run python manage.py migrate
python3 -m poetry run python manage.py createsuperuser --noinput --email ""
python3 -m poetry run python manage.py create_roles