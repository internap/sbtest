#!/bin/bash

test_clean_works() {
    mock rm --with-args "somewhere/some-file" --and exit-code 0

    bash ./clean.sh some-file

    assert ${?} succeeded
}

test_clean_works_fails() {
    mock rm --with-args "somewhere/non-existing-file" --and exit-code 1

    bash ./clean.sh non-existing-file

    assert ${?} failed
}
