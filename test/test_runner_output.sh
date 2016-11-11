#!/bin/bash

test_output_is_fine_when_running_a_test() {

    cp -aR ${TEST_ROOT_DIR}/../examples/1-simple-test/* .

    unset RUN_SINGLE_TEST
    actual=$(${TEST_ROOT_DIR}/../target/sbtest.sh)
    assert ${?} succeeded

    expected=$(cat <<-EXP

Running Simple Bash Tests
-------------------------

add.add...OK

-------------------------
Ran 1 test

>>> SUCCESS <<<

EXP
)
    assert "${actual}" equals "${expected}"
}

test_output_is_fine_when_running_1_file_tests() {

    cp -aR ${TEST_ROOT_DIR}/../examples/2-mocking/* .

    unset RUN_SINGLE_TEST
    actual=$(${TEST_ROOT_DIR}/../target/sbtest.sh)
    assert ${?} succeeded

    expected=$(cat <<-EXP

Running Simple Bash Tests
-------------------------

clean.clean_works...OK
clean.clean_works_fails...OK

-------------------------
Ran 2 tests

>>> SUCCESS <<<

EXP
)
    assert "${actual}" equals "${expected}"
}

test_output_is_fine_when_running_multiple_test_files() {

    cp -aR ${TEST_ROOT_DIR}/../test-fixtures/multi-test/* .

    unset RUN_SINGLE_TEST
    actual=$(${TEST_ROOT_DIR}/../target/sbtest.sh)
    assert ${?} succeeded

    expected=$(cat <<-EXP

Running Simple Bash Tests
-------------------------

one-two.1...OK
one-two.2...OK
three-four.3...OK
three-four.4...OK

-------------------------
Ran 4 tests

>>> SUCCESS <<<

EXP
)
    assert "${actual}" equals "${expected}"
}
