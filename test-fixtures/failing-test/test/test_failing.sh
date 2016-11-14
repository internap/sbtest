#!/bin/bash

test_that_fails() {
    (bash fail.sh)
    assert ${?} succeeded
}
