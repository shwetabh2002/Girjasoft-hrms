#!/bin/bash
set -e

echo "Waiting for database to be ready..."
python3 manage.py makemigrations
python3 manage.py migrate
python3 manage.py collectstatic --noinput || true

echo "Starting gunicorn..."
exec gunicorn --bind 0.0.0.0:8000 horilla.wsgi:application
