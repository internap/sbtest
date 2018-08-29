#!/bin/bash

test_fails_when_verifying_arguments_even_if_exit_code_is_ignored() {
    mock some-command --with-args "one un" --once
    mock some-command --with-args "two deux" --once
    mock some-command --with-args "three trois" --once

    ./code.sh
}