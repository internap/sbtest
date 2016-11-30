#!/bin/bash

test_specifying_once_fails_when_not_called() {
    cp -aR ${TEST_ROOT_DIR}/../test-fixtures/call_counts_tests/* .

    unset RUN_SINGLE_TEST
    actual=$(${TEST_ROOT_DIR}/../target/sbtest.sh call_counts.not_called_once)
    assert ${?} failed

    expected=$(cat <<-EXP

Running Simple Bash Tests
-------------------------

call_counts.not_called_once...FAILED

=========================
FAIL: call_counts.not_called_once
-------- STDOUT ---------
Test stdout
Command 'some-command' was expected to be called 1 time
Called : 0 times
-------- STDERR ---------
Test stderr
-------------------------

-------------------------
Ran 1 test

>>> FAILURE (1 problem) <<<

EXP
)
    assert "${actual}" equals "${expected}"
}

test_specifying_once_fails_when_called_twice() {
    cp -aR ${TEST_ROOT_DIR}/../test-fixtures/call_counts_tests/* .

    unset RUN_SINGLE_TEST
    actual=$(${TEST_ROOT_DIR}/../target/sbtest.sh call_counts.called_twice)
    assert ${?} failed

    expected=$(cat <<-EXP

Running Simple Bash Tests
-------------------------

call_counts.called_twice...FAILED

=========================
FAIL: call_counts.called_twice
-------- STDOUT ---------
Command 'some-command' was expected to be called 1 time
Called : 2 times
-------- STDERR ---------

-------------------------

-------------------------
Ran 1 test

>>> FAILURE (1 problem) <<<

EXP
)
    assert "${actual}" equals "${expected}"
}
