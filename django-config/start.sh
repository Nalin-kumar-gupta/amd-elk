#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

# Start the Django development server
python manage.py runserver 0.0.0.0:8000