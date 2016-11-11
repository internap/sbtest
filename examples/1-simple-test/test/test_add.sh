#!/bin/bash

test_add() {
    result=$(bash ./add.sh 2 2)

    assert ${result} equals 4
}
