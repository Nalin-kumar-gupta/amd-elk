#!/bin/bash

set -o errexit
set -o nounset

watchfiles --filter python 'celery -A amd_core worker --loglevel=info'