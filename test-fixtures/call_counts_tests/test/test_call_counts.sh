#!/bin/bash

test_not_called_once() {
    mock some-command --once

    echo "Test stdout"
    echo "Test stderr" 1>&2
}

test_called_twice() {
    mock some-command --once

    some-command
    assert ${?} succeeded
    some-command
    assert ${?} failed
}
