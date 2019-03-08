#!/bin/bash

test_fails_if_given_arguments_isnt_right() {
    mock some-command --with-args "one two three"

    some-command three two one > assertion_output
    assert ${?} failed

    expected_error=$(cat <<-EXP
Unexpected invocation for command 'some-command':
Got :      <"three two one">
Expected : <"one two three">
EXP
)
    assert "$(cat assertion_output)" equals "${expected_error}"
}

test_fails_if_2_with_args_argments_are_given() {
    mock some-command --with-args "a" --with-args "b" > error
    assert ${?} failed

    assert "$(cat error)" equals "Cannot expect more than 1 set of argument for an invocation, please use 'mock' multiple times"
}

test_supports_escaped_quotes_in_args() {
    mock some-command --with-args "one 'two' three"

    some-command one \'two\' three
    assert ${?} succeeded
}

test_supports_escaped_double_quotes_in_args() {
    mock some-command --with-args "one \"two\" three"

    some-command one \"two\" three
    assert ${?} succeeded
}

test_supports_escaped_double_quotes_in_single_quotes_in_args() {
    mock some-command --with-args 'one "two" three'

    some-command 'one "two" three'
    assert ${?} succeeded
}

test_mktmp_should_be_mockable() {
    mock mktemp --with-args '-d /tmp/f.XXXXXXXX' --and echo "/tmp/myfile"

    file=$(mktemp -d "/tmp/f.XXXXXXXX")
    assert ${?} succeeded
    assert "${file}" equals "/tmp/myfile"
}
