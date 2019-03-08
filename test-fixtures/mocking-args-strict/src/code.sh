#!/bin/bash
# N.B. no `set -e` here!

some-command one un
some-command three trois || true # Failure here doesnt matter to the actual code.
some-command two deux

exit 0