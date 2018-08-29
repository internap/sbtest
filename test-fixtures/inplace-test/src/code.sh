#!/bin/bash
set -ex

# Use the root Makefile to ensure we have not been copied elsewhere.
test -f $(pwd)/../../../Makefile