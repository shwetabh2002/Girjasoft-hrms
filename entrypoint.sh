#!/bin/bash
set -e

echo "=== Entrypoint starting ==="
echo "Waiting for database to be ready..."

# Only run makemigrations if there are any changes (silently fail if nothing to create)
python3 manage.py makemigrations 

echo "=== Running migrations ==="
python3 manage.py migrate
echo "=== Migrations done ==="

echo "=== Collecting static files ==="
python3 manage.py collectstatic --noinput || true
echo "=== Collectstatic done ==="

# Use PORT environment variable or default to 10000
PORT=${PORT:-10000}
echo "=== Starting gunicorn on port $PORT ==="
echo "Command: gunicorn --bind 0.0.0.0:$PORT horilla.wsgi:application"

# Keep gunicorn in foreground with logging
python3 manage.py createhorillauser --first_name admin --last_name admin --username admin --password admin --email admin@example.com --phone 1234567890
gunicorn --bind 0.0.0.0:8000 horilla.wsgi:application
#!/bin/bash

# echo "Waiting for database to be ready..."
# python3 manage.py makemigrations
# python3 manage.py migrate
# python3 manage.py collectstatic --noinput
# python3 manage.py createhorillauser --first_name admin --last_name admin --username admin --password admin --email admin@example.com --phone 1234567890
# gunicorn --bind 0.0.0.0:8000 horilla.wsgi:application
