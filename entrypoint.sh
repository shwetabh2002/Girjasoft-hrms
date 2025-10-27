#!/bin/bash
set -e

echo "=== Entrypoint starting ==="
echo "Waiting for database to be ready..."
python3 manage.py makemigrations
echo "=== Migrations done ==="
python3 manage.py migrate
echo "=== Migrate done ==="
python3 manage.py collectstatic --noinput || true
echo "=== Collectstatic done ==="

# Use PORT environment variable or default to 10000
PORT=${PORT:-10000}
echo "Starting gunicorn on port $PORT..."
echo "Command: gunicorn --bind 0.0.0.0:$PORT horilla.wsgi:application"
exec gunicorn --bind 0.0.0.0:$PORT --timeout 120 horilla.wsgi:application
