use v6;

use Test;
use lib 't/lib';
use Utils;
use Format::Lisp;

my $fl = Format::Lisp.new;

# ;;; pprint-indent.9
# 
#`(
# (def-pprint-test format.i.1
#   (format nil "~<M~3:i~:@_M~:>" '(M M))
#   "M
#     M")
# 
is $fl.format(
	Q{~<M~3:i~:@_M~:>},
	[ Q{M}, Q{M} ]
), qq{M\n    M}, Q{format.i.1};
)

# ;;; See pprint-indent.10
#`(
# (def-pprint-test format.i.2
#   (format nil "~:<M~1:I~@:_M~:>" '(M M))
#   "(M
#    M)")
# 
is $fl.format(
	Q{~<M~1:I~:@_M~:>},
	[ Q{M}, Q{M} ]
), qq{(M\n   M)}, Q{format.i.2};
)

# ;;; See pprint-indent.11
#`(
# (def-pprint-test format.i.3
#   (format nil "~<(~;M~-1:i~:@_M~;)~:>" '(M M))
#   "(M
#  M)")
# 
is $fl.format(
	Q{~<(~;M~-1:i~:@_M~;)~:>},
	[ Q{M}, Q{M} ]
), qq[(M\n M)], Q{format.i.3};
)

#`(
# (def-pprint-test format.i.4
#   (format nil "~:<M~-1:i~:@_M~:>" '(M M))
#   "(M
#  M)")
# 
is $fl.format(
	Q{~:<M~-1:i~:@_M~:>},
	[ Q{M}, Q{M} ]
), qq{(M\n M)}, Q{format.i.4};
)

#`(
# (def-pprint-test format.i.5
#   (format nil "~<(~;M~:I~:@_M~;)~:>" '(M M))
#   "(M
#   M)")
# 
is $fl.format(
	Q{~<(~;M~:I~:@_M~;)~:>},
	[ Q{M}, Q{M} ]
), qq{(M\n  M)}, Q{format.i.5};
)

#`(
# (def-pprint-test format.i.6
#   (format nil "~<(~;M~v:i~:@_M~;)~:>" '(nil))
#   "(M
#   M)")
# 
is $fl.format(
	Q{~<(~;M~v:i~:@_M~;)~:>},
	[ Nil ]
), qq{(M\n  M)}, Q{format.i.6};
)

#`(
# (def-pprint-test format.i.7
#   (format nil "~:<M~-2:i~:@_M~:>" '(M M))
#   "(M
# M)")
# 
is $fl.format(
	Q{~:<M~-2:i~:@_M~:>},
	[ Q{M}, Q{M} ]
), qq{(M\nM)}, Q{format.i.7};
)

#`(
# (def-pprint-test format.i.8
#   (format nil "~<M~:i~:@_M~:>" '(M M))
#   "M
#  M")
# 
is $fl.format(
	Q{~<M~:i~:@_M~:>},
	[ Q{M}, Q{M} ]
), qq{(M\n M)}, Q{format.i.8};
)

# ;;; See pprint-indent.13
#`(
# (def-pprint-test format.i.9
#   (format nil "~<MMM~I~:@_MMMMM~:>" '(M M))
#   "MMM
# MMMMM")
# 
is $fl.format(
	Q{~<MMM~I~:@_MMMMM~:>},
	[ Q{M}, Q{M} ]
), qq{(MMM\nMMMMM)}, Q{format.i.9};
)

#`(
# (def-pprint-test format.i.10
#   (format nil "~:<MMM~I~:@_MMMMM~:>" '(M M))
#   "(MMM
#  MMMMM)")
# 
is $fl.format(
	Q{~:<MMM~I~:@_MMMMM~:>},
	[ Q{M}, Q{M} ]
), qq{(MMM\nMMMMM)}, Q{format.i.10};
)

#`(
# (def-pprint-test format.i.11
#   (format nil "~<MMM~1I~:@_MMMMM~:>" '(M M))
#   "MMM
#  MMMMM")
# 
is $fl.format(
	Q{~<MMM~1I~:@_MMMMM~:>},
	[ Q{M}, Q{M} ]
), qq{(MMM\n MMMMM)}, Q{format.i.11};
)

#`(
# (def-pprint-test format.i.12
#   (format nil "XXX~<MMM~1I~:@_MMMMM~:>" '(M M))
#   "XXXMMM
#     MMMMM")
# 
is $fl.format(
	Q{XXX~<MMM~1I~:@_MMMMM~:>},
	[ Q{M}, Q{M} ]
), qq{(XXXMMM\n    MMMMM)}, Q{format.i.12};
)

#`(
# (def-pprint-test format.i.13
#   (format nil "XXX~<MMM~I~:@_MMMMM~:>" '(M M))
#   "XXXMMM
#    MMMMM")
# 
is $fl.format(
	Q{XXX~<MMM~I~:@_MMMMM~:>},
	[ Q{M}, Q{M} ]
), qq{(XXXMMM\n   MMMMM)}, Q{format.i.13};
)

#`(
# (def-pprint-test format.i.14
#   (format nil "XXX~<MMM~-1I~:@_MMMMM~:>" '(M M))
#   "XXXMMM
#   MMMMM")
# 
is $fl.format(
	Q{XXX~<MMM~-1I~:@_MMMMM~:>},
	[ Q{M}, Q{M} ]
), qq{(XXXMMM\n  MMMMM)}, Q{format.i.14};
)

#`(
# (def-pprint-test format.i.15
#   (format nil "XXX~<MMM~vI~:@_MMMMM~:>" '(nil))
#   "XXXMMM
#    MMMMM")
# 
is $fl.format(
	Q{XXX~<MMM~vI~:@_MMMMM~:>},
	[ Nil ]
), qq{(XXXMMM\n   MMMMM)}, Q{format.i.15};
)

#`(
# (def-pprint-test format.i.16
#   (format nil "XXX~<MMM~vI~:@_MMMMM~:>" '(2))
#   "XXXMMM
#      MMMMM")
# 
is $fl.format(
	Q{XXX~<MMM~vI~:@_MMMMM~:>},
	[ 2 ]
), qq{(XXXMMM\n     MMMMM)}, Q{format.i.16};
)

done-testing;

# vim: ft=perl6
