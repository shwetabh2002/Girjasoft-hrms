#!/bin/bash
set -e

echo "=== Entrypoint starting ==="
echo "Collecting static files..."
python3 manage.py collectstatic --noinput || true
echo "=== Collectstatic done ==="

# Use PORT environment variable or default to 10000
PORT=${PORT:-10000}
echo "=== Starting gunicorn on port $PORT ==="
echo "Command: gunicorn --bind 0.0.0.0:$PORT horilla.wsgi:application"

# Keep gunicorn in foreground with logging
exec gunicorn --bind 0.0.0.0:$PORT --access-logfile - --error-logfile - --log-level info horilla.wsgi:application
