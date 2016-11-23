#!/bin/bash
set -eu

src=$(dirname $0)

cat ${src}/header.sh
cat ${src}/utils.sh
cat ${src}/asserts.sh
cat ${src}/mocking.sh
cat ${src}/cli.sh
cat ${src}/test-runner.sh
