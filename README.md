[![Build Status](https://travis-ci.org/internap/sbtest.svg?branch=master)](https://travis-ci.org/internap/sbtest)

SBTEST: Simple Bash Tests
=========================

Simple library for bash script unit testing with mocks and asserts

Project structure
-----------------
Place your source files in a src/ folder and tests in a test/ folder
with filenames starting by "test_".  Runner can be invoked with

    ./sbtest.sh

in the base directory

Writing your first test
-----------------------

[examples/1-simple-test](examples/1-simple-test)

add.sh

    echo $(($1 + $2))

test 

    test_add() {
        result=$(bash ./add.sh 2 2)
    
        assert ${result} equals 4
    }

Using mocks
-----------

[examples/2-mocking](examples/2-mocking)

clean.sh

    rm somewhere/$1

test

    test_clean_works() {
        mock rm --and exit-code 0
    
        bash ./clean.sh some-file
    
        assert ${?} succeeded
    }
    

Contributing
============

Feel free to add stuff in here :)

Running the tests:

    make test
    
you can run only one suite/test with

    make test TEST=suite.test
