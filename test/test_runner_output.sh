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

test_output_is_fine_when_a_test_fails() {

    cp -aR ${TEST_ROOT_DIR}/../test-fixtures/failing-test/* .

    unset RUN_SINGLE_TEST
    actual=$(${TEST_ROOT_DIR}/../target/sbtest.sh failing.that_fails)
    assert ${?} failed

    expected=$(cat <<-EXP

Running Simple Bash Tests
-------------------------

failing.that_fails...FAILED

=========================
FAIL: failing.that_fails
-------- STDOUT ---------
Expected success exit code
Got: <1>
-------- STDERR ---------

-------------------------

-------------------------
Ran 1 test

>>> FAILURE (1 problem) <<<

EXP
)
    assert "${actual}" equals "${expected}"
}

test_output_also_show_stderr_when_a_test_fails() {

    cp -aR ${TEST_ROOT_DIR}/../test-fixtures/failing-test/* .

    unset RUN_SINGLE_TEST
    actual=$(${TEST_ROOT_DIR}/../target/sbtest.sh failing.that_fails_with_stderr)
    assert ${?} failed

    expected=$(cat <<-EXP

Running Simple Bash Tests
-------------------------

failing.that_fails_with_stderr...FAILED

=========================
FAIL: failing.that_fails_with_stderr
-------- STDOUT ---------
Expected success exit code
Got: <1>
-------- STDERR ---------
This is stuff
from stderr
-------------------------

-------------------------
Ran 1 test

>>> FAILURE (1 problem) <<<

EXP
)
    assert "${actual}" equals "${expected}"
}

test_with_an_error_while_running_the_test_should_show_it_is_in_error() {

    cp -aR ${TEST_ROOT_DIR}/../test-fixtures/erroring-test/* .

    unset RUN_SINGLE_TEST
    actual=$(${TEST_ROOT_DIR}/../target/sbtest.sh erroring.non_existing_command)
    assert ${?} failed

    expected=$(cat <<-EXP

Running Simple Bash Tests
-------------------------

erroring.non_existing_command...ERROR

=========================
ERROR: erroring.non_existing_command
-------- STDOUT ---------
stuff on stdout
-------- STDERR ---------
stuff on stderr
EXIT CODE : 96
-------------------------

-------------------------
Ran 1 test

>>> FAILURE (1 problem) <<<

EXP
)
    assert "${actual}" equals "${expected}"
}

test_a_failure_doesnt_impact_other_tests() {

    cp -aR ${TEST_ROOT_DIR}/../test-fixtures/failing-test/* .

    unset RUN_SINGLE_TEST
    actual=$(${TEST_ROOT_DIR}/../target/sbtest.sh failing)
    assert ${?} failed

    expected=$(cat <<-EXP

Running Simple Bash Tests
-------------------------

failing.that_fails...FAILED
failing.that_fails_with_stderr...FAILED
failing.that_works...OK

=========================
FAIL: failing.that_fails
-------- STDOUT ---------
Expected success exit code
Got: <1>
-------- STDERR ---------

-------------------------

=========================
FAIL: failing.that_fails_with_stderr
-------- STDOUT ---------
Expected success exit code
Got: <1>
-------- STDERR ---------
This is stuff
from stderr
-------------------------

-------------------------
Ran 3 tests

>>> FAILURE (2 problems) <<<

EXP
)
    assert "${actual}" equals "${expected}"
}
