#!/bin/bash

# Collect static files
echo "Collect static files"
python3 manage.py collectstatic --noinput --settings=ispeak_crmm.settings.prod

# Make database migrations
echo "Make database migrations"
python3 manage.py makemigrations --settings=ispeak_crmm.settings.prod

# Apply database migrations
echo "Apply database migrations"
python3 manage.py migrate --settings=ispeak_crmm.settings.prod

# Start server
echo "Starting server"
gunicorn ispeak_crmm.wsgi_prod:application --bind 0.0.0.0:8000