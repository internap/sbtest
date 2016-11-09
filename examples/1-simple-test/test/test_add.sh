#!/bin/bash

test_addition() {
    result=$(bash ./addition.sh 2 2)

    assert_int ${result} 4
}
