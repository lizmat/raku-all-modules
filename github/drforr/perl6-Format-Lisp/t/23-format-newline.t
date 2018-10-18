use v6;

use Test;
use lib 't/lib';
use Utils;
use Format::Lisp;

my $*fl = Format::Lisp.new;

#`(
# (def-format-test format.newline.1
#   (concatenate 'string "~" (string #\Newline) "   X")
#   nil "X")
# 
ok def-format-test( qq{~\n   X}, Nil, Q{X} ), Q{format.newline.1};
)

# (def-format-test format.newline.2
#   (concatenate 'string "A~:" (string #\Newline) " X")
#   nil "A X")
# 
ok def-format-test( qq{A~:\n X}, Nil, Q{A X} ), Q{format.newline.2};

#`(
# (def-format-test format.newline.3
#   (concatenate 'string "A~@" (string #\Newline) " X")
#   nil #.(concatenate 'string "A" (string #\Newline) "X"))
# 
ok def-format-test( qq{A~@\n X}, Nil, qq{A\nX} ), Q{format.newline.2};
)

done-testing;

# vim: ft=perl6
