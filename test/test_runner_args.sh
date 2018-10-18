#!/bin/bash

test_can_specify_alternative_paths_src() {
    cp -aR ${TEST_ROOT_DIR}/../test-fixtures/unconventional-test/* .

    unset RUN_SINGLE_TEST
    actual=$(${TEST_ROOT_DIR}/../target/sbtest.sh \
                --src not-src \
                --tests not-test)
    assert ${?} succeeded

    expected=$(cat <<-EXP

Running Simple Bash Tests
-------------------------

stuff.stuff...OK

-------------------------
Ran 1 test

>>> SUCCESS <<<

EXP
)
    assert "${actual}" equals "${expected}"
}

test_can_specify_alternative_relative_paths_src() {
    cp -aR ${TEST_ROOT_DIR}/../test-fixtures/unconventional-test .

    unset RUN_SINGLE_TEST
    actual=$(${TEST_ROOT_DIR}/../target/sbtest.sh \
                --tests ./unconventional-test/not-test \
                --src ./unconventional-test/not-src)
    assert ${?} succeeded

    expected=$(cat <<-EXP

Running Simple Bash Tests
-------------------------

stuff.stuff...OK

-------------------------
Ran 1 test

>>> SUCCESS <<<

EXP
)
    assert "${actual}" equals "${expected}"
}

test_can_specify_alternative_absolute_paths_src() {
    unset RUN_SINGLE_TEST
    actual=$(${TEST_ROOT_DIR}/../target/sbtest.sh \
                --src ${TEST_ROOT_DIR}/../test-fixtures/unconventional-test/not-src \
                --tests ${TEST_ROOT_DIR}/../test-fixtures/unconventional-test/not-test)
    assert ${?} succeeded

    expected=$(cat <<-EXP

Running Simple Bash Tests
-------------------------

stuff.stuff...OK

-------------------------
Ran 1 test

>>> SUCCESS <<<

EXP
)
    assert "${actual}" equals "${expected}"
}

test_can_run_only_one_test_suite_by_name() {
    cp -aR ${TEST_ROOT_DIR}/../test-fixtures/multi-test/* .

    unset RUN_SINGLE_TEST
    actual=$(${TEST_ROOT_DIR}/../target/sbtest.sh one-two)
    assert ${?} succeeded

    expected=$(cat <<-EXP

Running Simple Bash Tests
-------------------------

one-two.1...OK
one-two.2...OK

-------------------------
Ran 2 tests

>>> SUCCESS <<<

EXP
)
    assert "${actual}" equals "${expected}"
}

test_can_run_only_one_test_by_name() {
    cp -aR ${TEST_ROOT_DIR}/../test-fixtures/multi-test/* .

    unset RUN_SINGLE_TEST
    actual=$(${TEST_ROOT_DIR}/../target/sbtest.sh one-two.1)
    assert ${?} succeeded

    expected=$(cat <<-EXP

Running Simple Bash Tests
-------------------------

one-two.1...OK

-------------------------
Ran 1 test

>>> SUCCESS <<<

EXP
)
    assert "${actual}" equals "${expected}"
}

test_refuses_invalid_arguments() {
    actual=$(${TEST_ROOT_DIR}/../target/sbtest.sh --invalid 2>&1 1>/dev/null)
    assert ${?} failed

    assert "$actual" equals "Unsupported argument --invalid"
}
