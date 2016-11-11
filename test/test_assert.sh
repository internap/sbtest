#!/bin/bash

test_assert_equals_with_integers() {
    (assert 1 equals 1)

    assert ${?} succeeded
}

test_assert_equals_with_integer_failing() {
    (assert 1 equals 0)

    assert ${?} failed
}

test_assert_equals_with_strings_passing() {
    (assert "yes" equals "yes")

    assert ${?} succeeded
}

test_assert_equals_with_strings_failing() {
    (assert "no" equals "yes")

    assert ${?} failed
}

test_assert_multiworks_string_works() {
    (assert "yes but no" equals "yes but no")

    assert ${?} succeeded
}
