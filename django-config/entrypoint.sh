#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

# Print a custom message
echo "Starting the application... Welcome to the setup process!"

# Execute the passed command
exec "$@"