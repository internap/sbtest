#!/bin/bash

test_fails_when_verifying_arguments_even_when_exit_code_is_ignored() {
    cp -aR ${TEST_ROOT_DIR}/../test-fixtures/mocking-args-strict/* .

    unset RUN_SINGLE_TEST
    actual=$(${TEST_ROOT_DIR}/../target/sbtest.sh verify_arguments_order)
    assert ${?} failed

    expected_error=$(cat <<-EXP
Unexpected invocation for command 'some-command':
Got :      <"three trois">
Expected : <"two deux">
Unexpected invocation for command 'some-command':
Got :      <"two deux">
Expected : <"three trois">
EXP
)
    assert "${actual}" contains "${expected_error}"
}

test_fails_if_2_with_args_arguments_are_given() {
    mock some-command --with-args "a" --with-args "b" > error
    assert ${?} failed

    assert "$(cat error)" equals "Cannot expect more than 1 set of argument for an invocation, please use 'mock' multiple times"
}
