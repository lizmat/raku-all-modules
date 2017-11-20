use v6;

use Test;
use lib 't/lib';
use Utils;
use Format::Lisp;

my $fl = Format::Lisp.new;

#`(
# (def-format-test format.newline.1
#   (concatenate 'string "~" (string #\Newline) "   X")
#   nil "X")
# 
is $fl.format( qq{~\n   X} ), Q{X}, Q{format.newline.1};
)

#`(
# (def-format-test format.newline.2
#   (concatenate 'string "A~:" (string #\Newline) " X")
#   nil "A X")
# 
is $fl.format( qq{A~:\n X} ), Q{A X}, Q{format.newline.2};
)

#`(
# (def-format-test format.newline.3
#   (concatenate 'string "A~@" (string #\Newline) " X")
#   nil #.(concatenate 'string "A" (string #\Newline) "X"))
# 
is $fl.format( qq{A~@\n X} ), qq{A X}, Q{format.newline.2};
)

done-testing;

# vim: ft=perl6
