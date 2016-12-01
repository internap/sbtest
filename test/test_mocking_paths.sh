#!/bin/bash

test_mocking_a_relative_path_works() {
    mock some/path/to/a/file --and echo "Hello"

    result=$(some/path/to/a/file)
    assert ${?} succeeded
    assert "${result}" equals "Hello"
}

test_mocking_a_file_path_works() {
    mock file.exe --and echo "Hello"

    result=$(file.exe)
    assert ${?} succeeded
    assert "${result}" equals "Hello"
}

test_mocking_a_relative_file_path_works() {
    mock path/file.exe --and echo "Hello"

    result=$(path/file.exe)
    assert ${?} succeeded
    assert "${result}" equals "Hello"
}
