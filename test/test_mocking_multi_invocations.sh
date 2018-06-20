#!/bin/bash

test_mocking_a_command_with_a_success_exit_code() {
    mock some-command --and exit-code 0

    some-command
    assert ${?} succeeded
}

test_mocking_a_command_with_a_failure_exit_code() {
    mock some-command --and exit-code 1

    some-command
    assert ${?} failed
}

test_mocking_a_command_to_return_a_value_and_exit_success() {
    mock some-command --and echo "hello" --and exit-code 0

    result=$(some-command)
    assert ${?} succeeded

    assert "${result}" equals "hello"
}

test_mocking_a_command_to_return_a_value_and_exit_failure() {
    mock some-command --and echo "hello" --and exit-code 1

    result=$(some-command)
    assert ${?} failed

    assert "${result}" equals "hello"
}

test_mocking_a_command_to_return_a_value_on_stderr() {
    mock some-command --and echo-stderr "hello"

    result=$(some-command 2>&1 1>/dev/null)

    assert "${result}" equals "hello"
}

test_mocking_a_command_to_return_content_from_missing_file_should_fail() {
    mock some-command --and cat /missing/file
    some-command
    assert ${?} failed
}

test_mocking_a_command_to_return_content_from_stdin() {
    mock some-command --and cat -
    result=$(echo "yes" | some-command)
    assert ${?} succeeded

    assert "${result}" equals "yes"
}

test_mocking_a_command_to_return_content_from_file() {
    temp_file=$(mktemp ${TMPDIR:-"/tmp/"}/sbtest.XXXXXXXX)
    echo "yes yes" > ${temp_file}

    mock some-command --and cat ${temp_file}
    result=$(some-command)
    assert ${?} succeeded

    assert "${result}" equals "yes yes"
    rm -f ${temp_file}
}

test_mocking_a_command_to_return_content_from_file_in_test_root() {
    mock some-command --and cat $TEST_ROOT_DIR/data-fixtures/letter.txt
    result=$(some-command)
    assert ${?} succeeded

    assert "${result}" equals "Hello world."
}

test_mocking_a_command_to_return_content_from_missing_file_on_stderr_should_fail() {
    mock some-command --and cat-stderr /missing/file
    some-command
    assert ${?} failed
}

test_mocking_a_command_to_return_content_from_stdin_on_stderr() {
    mock some-command --and cat-stderr -
    result=$(echo "yes" | some-command 2>&1 1>/dev/null)
    assert ${?} succeeded

    assert "${result}" equals "yes"
}

test_mocking_a_command_to_return_content_from_file_on_stderr() {
    temp_file=$(mktemp ${TMPDIR:-"/tmp/"}/sbtest.XXXXXXXX)
    echo "yes yes" > ${temp_file}

    mock some-command --and cat-stderr ${temp_file}
    result=$(some-command 2>&1 1>/dev/null)
    assert ${?} succeeded

    assert "${result}" equals "yes yes"
    rm -f ${temp_file}
}

test_mocking_a_command_to_return_content_from_file_in_test_root_on_stderr() {
    mock some-command --and cat-stderr $TEST_ROOT_DIR/data-fixtures/letter.txt
    result=$(some-command 2>&1 1>/dev/null)
    assert ${?} succeeded

    assert "${result}" equals "Hello world."
}

test_mocking_several_times_the_same_command() {
    mock some-command --and exit-code 0
    mock some-command --and exit-code 1
    mock some-command --and exit-code 0

    some-command
    assert ${?} succeeded

    some-command
    assert ${?} failed

    some-command
    assert ${?} succeeded
}

test_no_mock_count_mocks_all_the_calls() {
    mock some-command --and exit-code 0

    some-command
    assert ${?} succeeded

    some-command
    assert ${?} succeeded
}

test_mocking_a_second_time_assume_the_first_was_a_one_time_and_mocks_all_other_calls() {
    mock some-command --and exit-code 1
    mock some-command --and exit-code 0

    some-command
    assert ${?} failed

    some-command
    assert ${?} succeeded

    some-command
    assert ${?} succeeded
}
