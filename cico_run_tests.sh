#!/bin/bash

set -ex

. cico_setup.sh

build_image

WORKER_BASE_IMAGE=$(make get-image-name) ./tests/run_integration_tests.sh

