#!/bin/sh

# want current zef
git clone https://github.com/ugexe/zef.git

cd ./zef

# the following two lines are for added info in the travis build log"
D=`pwd`
echo "=== now working in dir '$D' ==="
echo "=== current path: '$PATH' ==="
# the coup de grace:
#perl6 -Ilib bin/zef --debug install .
panda install zef
