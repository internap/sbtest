#!/bin/bash
set -eu

src=$(dirname $0)

include() {
    cat $1
    printf '\n'
}

include ${src}/header.sh
include ${src}/utils.sh
include ${src}/asserts.sh
include ${src}/mocking.sh
include ${src}/cli.sh
include ${src}/test-runner.sh
