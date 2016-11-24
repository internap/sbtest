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
