#!/bin/bash

test_clean_works() {
    mock rm --with-args "somewhere/some-file" --and exitcode 0

    bash ./clean.sh some-file

    assert ${?} succeeded
}

test_clean_works_fails() {
    mock rm --with-args "somewhere/non-existing-file" --and exitcode 1

    bash ./clean.sh non-existing-file

    assert ${?} failed
}
