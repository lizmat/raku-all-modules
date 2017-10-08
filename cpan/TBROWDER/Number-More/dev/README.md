This directory contains files used to develop tests for base
conversions from 37 through 62.

Explicit results from website <http://www.numbertobase.com> were put
into file `base-conversions.dat` which was then transformed by file
`convert-examples.p6` into test file `060-auto-transform-checks.t`
which was then moved into the test directory `../t`.


Note that the website uses the alphabet "0..9 a..z A..Z" as opposed to
Perl 6's (and this module's) "0..9 A..Z a..z" so the results in the
test file were translated:

   $results .= trans( 'a'..'z' => 'A'..'Z', 'A'..'Z' => 'a'..'z' );
