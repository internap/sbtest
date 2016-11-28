#!/bin/bash

test_that_fails() {
    (bash fail.sh)
    assert ${?} succeeded
}

test_that_fails_with_stderr() {
    (bash fail-with-stderr.sh)
    assert ${?} succeeded
}

test_that_works() {
    :
}
