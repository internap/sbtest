#!/bin/bash

test_stuff() {
    assert "$(bash ./echo.sh "hello")" equals "hello"
}
