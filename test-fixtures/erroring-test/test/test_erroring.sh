#!/bin/bash

test_non_existing_command() {
    echo "stuff on stdout"
    echo "stuff on stderr" 1>&2
    return 96
}
