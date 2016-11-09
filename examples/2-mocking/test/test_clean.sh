#!/bin/bash

test_clean_works() {
    mock rm --with-args "somewhere/some-file" --and exitcode 0

    bash ./clean.sh some-file

    assert_int $? 0
}

test_clean_works_fails() {
    mock rm --with-args "somewhere/some-file" --and exitcode 1

    bash ./clean.sh non-existing-file

    assert_int $? 1
}
