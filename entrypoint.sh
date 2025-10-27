#!/bin/bash
set -e

echo "Waiting for database to be ready..."
python3 manage.py makemigrations
python3 manage.py migrate
python3 manage.py collectstatic --noinput || true

# Use PORT environment variable or default to 10000
PORT=${PORT:-10000}
echo "Starting gunicorn on port $PORT..."
exec gunicorn --bind 0.0.0.0:$PORT horilla.wsgi:application
