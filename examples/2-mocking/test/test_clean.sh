#!/bin/bash

test_clean_works() {
    mock rm --and exit-code 0

    bash ./clean.sh some-file

    assert ${?} succeeded
}

test_clean_works_fails() {
    mock rm --and exit-code 1

    bash ./clean.sh non-existing-file

    assert ${?} failed
}
