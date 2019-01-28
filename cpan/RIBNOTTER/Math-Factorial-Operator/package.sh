#/usr/bin/bash
#creates a tarball to be ready to upload to CPAN

version=0.1.1

git archive --prefix=Math-Factorial-Operator-$version/ -o ../Math-Factorial-Operator-$version.tar.gz HEAD
