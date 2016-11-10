#!/bin/bash

test_asset_equals_with_integer_passing() {
    (assert 1 equals 1)

    assert ${?} succeeded
}

test_asset_equals_with_integer_failing() {
    (assert 1 equals 0)

    assert ${?} failed
}
