#!/bin/bash -ex

mercator /tmp

"${SCANCODE_PATH}bin/scancode" --version

gofedlib-cli --help
