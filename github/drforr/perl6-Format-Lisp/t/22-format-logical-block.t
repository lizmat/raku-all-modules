use v6;

use Test;
use lib 't/lib';
use Utils;
use Format::Lisp;

my $*fl = Format::Lisp.new;

# ;;; Error cases
# 
# ;;; Prefix and suffix cannot contain format directives
# 
#`(
# (deftest format.logical-block.error.1
#   (signals-error-always (format nil "~<foo~A~;~A~;bar~:>" '(X) '(Y)) error)
#   t t)
#I 
throws-like {
	$*fl.format( Q{~<foo~A~;~A~;bar~:>}, [ Q{X} ], [ Q{Y} ] );
}, X::Error, Q{format.logical-block.error.1};
)

#`(
# (deftest format.logical-block.error.2
#   (signals-error-always (format nil "~<foo~A~@;~A~;bar~:>" '(X) '(Y)) error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~<foo~A~@;~A~;bar~:>}, [ Q{X} ], [ Q{Y} ] );
}, X::Error, Q{format.logical-block.error.2};
)

#`(
# (deftest format.logical-block.error.3
#   (signals-error-always (format nil "~<foo~;~A~;bar~A~:>" '(X) '(Y)) error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~<foo~;~A~;bar~A~:>}, [ Q{X} ], [ Q{Y} ] );
}, X::Error, Q{format.logical-block.error.3};
)

#`(
# (deftest format.logical-block.error.4
#   (signals-error-always (format nil "~<foo~@;~A~;bar~A~:>" '(X) '(Y)) error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~<foo~@;~A~;bar~A~:>}, [ Q{X} ], [ Q{Y} ] );
}, X::Error, Q{format.logical-block.error.4};
)

#`(
# (deftest format.logical-block.error.5
#   (signals-error-always (format nil "~<foo~A~;~A~:>" '(X) '(Y)) error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~<foo~A~;~A~:>}, [ Q{X} ], [ Q{Y} ] );
}, X::Error, Q{format.logical-block.error.5};
)

#`(
# (deftest format.logical-block.error.6
#   (signals-error-always (format nil "~<foo~A~@;~A~:>" '(X) '(Y)) error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~<foo~A~@;~A~:>}, [ Q{X} ], [ Q{Y} ] );
}, X::Error, Q{format.logical-block.error.6};
)

#`(
# (deftest format.logical-block.error.7
#   (signals-error-always (format nil "~<~;~A~;bar~A~:>" '(X) '(Y)) error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~<~;~A~;bar~A~:>}, [ Q{X} ], [ Q{Y} ] );
}, X::Error, Q{format.logical-block.error.7};
)

#`(
# (deftest format.logical-block.error.8
#   (signals-error-always (format nil "~<~@;~A~;bar~A~:>" '(X) '(Y)) error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~<~@;~A~;bar~A~:>}, [ Q{X} ], [ Q{Y} ] );
}, X::Error, Q{format.logical-block.error.8};
)

#`(
# (deftest format.logical-block.error.9
#   (signals-error-always (format nil "~:<foo~A~;~A~;bar~:>" '(X) '(Y)) error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~:<foo~A~;~A~;bar~:>}, [ Q{X} ], [ Q{Y} ] );
}, X::Error, Q{format.logical-block.error.9};
)

#`(
# (deftest format.logical-block.error.10
#   (signals-error-always (format nil "~:<foo~A~@;~A~;bar~:>" '(X) '(Y)) error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~:<foo~A~@;~A~;bar~:>}, [ Q{X} ], [ Q{Y} ] );
}, X::Error, Q{format.logical-block.error.10};
)

#`(
# (deftest format.logical-block.error.11
#   (signals-error-always (format nil "~:<foo~;~A~;bar~A~:>" '(X) '(Y)) error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~:<foo~;~A~;bar~A~:>}, [ Q{X} ], [ Q{Y} ] );
}, X::Error, Q{format.logical-block.error.11};
)

#`(
# (deftest format.logical-block.error.12
#   (signals-error-always (format nil "~:<foo~@;~A~;bar~A~:>" '(X) '(Y)) error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~:<foo~@;~A~;bar~A~:>}, [ Q{X} ], [ Q{Y} ] );
}, X::Error, Q{format.logical-block.error.12};
)

#`(
# (deftest format.logical-block.error.13
#   (signals-error-always (format nil "~:<foo~A~;~A~:>" '(X) '(Y)) error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~:<foo~A~;~A~:>}, [ Q{X} ], [ Q{Y} ] );
}, X::Error, Q{format.logical-block.error.13};
)

#`(
# (deftest format.logical-block.error.14
#   (signals-error-always (format nil "~:<foo~A~@;~A~:>" '(X) '(Y)) error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~:<foo~A~@;~A~:>}, [ Q{X} ], [ Q{Y} ] );
}, X::Error, Q{format.logical-block.error.14};
)

#`(
# (deftest format.logical-block.error.15
#   (signals-error-always (format nil "~:<~;~A~;bar~A~:>" '(X) '(Y)) error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~:<~;~A~;bar~A~:>}, [ Q{X} ], [ Q{Y} ] );
}, X::Error, Q{format.logical-block.error.15};
)

#`(
# (deftest format.logical-block.error.16
#   (signals-error-always (format nil "~:<~@;~A~;bar~A~:>" '(X) '(Y)) error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~:<~@;~A~;bar~A~:>}, [ Q{X} ], [ Q{Y} ] );
}, X::Error, Q{format.logical-block.error.16};
)

#`(
# (deftest format.logical-block.error.17
#   (signals-error-always (format nil "~@<foo~A~;~A~;bar~:>" '(X) '(Y)) error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~@<foo~A~;~A~;bar~:>}, [ Q{X} ], [ Q{Y} ] );
}, X::Error, Q{format.logical-block.error.17};
)

#`(
# (deftest format.logical-block.error.18
#   (signals-error-always (format nil "~@<foo~A~@;~A~;bar~:>" '(X) '(Y)) error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~@<foo~A~@;~A~;bar~:>}, [ Q{X} ], [ Q{Y} ] );
}, X::Error, Q{format.logical-block.error.18};
)

#`(
# (deftest format.logical-block.error.19
#   (signals-error-always (format nil "~@<foo~;~A~;bar~A~:>" '(X) '(Y)) error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~@<foo~;~A~;bar~:>}, [ Q{X} ], [ Q{Y} ] );
}, X::Error, Q{format.logical-block.error.19};
)

#`(
# (deftest format.logical-block.error.20
#   (signals-error-always (format nil "~@<foo~@;~A~;bar~A~:>" '(X) '(Y)) error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~@<foo~@;~A~;bar~A~:>}, [ Q{X} ], [ Q{Y} ] );
}, X::Error, Q{format.logical-block.error.20};
)

#`(
# (deftest format.logical-block.error.21
#   (signals-error-always (format nil "~@<foo~A~;~A~:>" '(X) '(Y)) error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~@<foo~A~;~A~:>}, [ Q{X} ], [ Q{Y} ] );
}, X::Error, Q{format.logical-block.error.21};
)

#`(
# (deftest format.logical-block.error.22
#   (signals-error-always (format nil "~@<foo~A~@;~A~:>" '(X) '(Y)) error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~@<foo~A~@;~A~:>}, [ Q{X} ], [ Q{Y} ] );
}, X::Error, Q{format.logical-block.error.22};
)

#`(
# (deftest format.logical-block.error.23
#   (signals-error-always (format nil "~@<~;~A~;bar~A~:>" '(X) '(Y)) error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~@<~;~A~;bar~A~:>}, [ Q{X} ], [ Q{Y} ] );
}, X::Error, Q{format.logical-block.error.23};
)

#`(
# (deftest format.logical-block.error.24
#   (signals-error-always (format nil "~@<~@;~A~;bar~A~:>" '(X) '(Y)) error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~@<~@;~A~;bar~A~:>}, [ Q{X} ], [ Q{Y} ] );
}, X::Error, Q{format.logical-block.error.24};
)

#`(
# (deftest format.logical-block.error.25
#   (signals-error-always (format nil "1~<X~<Y~:>Z~>2" nil nil nil) error)
#   t t)
# 
throws-like {
	$*fl.format( Q{1~<X~<Y~:>Z~>2}, [ Q{X} ], [ Q{Y} ] );
}, X::Error, Q{format.logical-block.error.25};
)

# ;;; "an error is also signaled if the ~<...~:;...~> form of ~<...~> is used
# ;;; in the same format string with ~W, ~_, ~<...~:>, ~I, or ~:T."
# 
#`(
# (deftest format.logical-block.error.26
#   (signals-error-always (format nil "~<~:;~>~<~:>" nil nil nil) error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~<~:;~>~<~:>}, [ Q{X} ], [ Q{Y} ] );
}, X::Error, Q{format.logical-block.error.26};
)

#`(
# (deftest format.logical-block.error.27
#   (signals-error-always (format nil "~<~:>~<~:;~>" nil nil nil) error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~<~:>~<~:;~>}, [ Q{X} ], [ Q{Y} ] );
}, X::Error, Q{format.logical-block.error.27};
)

# ;;; Non-error tests
# 
# (def-pprint-test format.logical-block.1
#   (format nil "~<~A~:>" '(nil))
#   "NIL")
# 
is $*fl.format( Q{~<~A~:>}, [ Nil ] ), Q{NIL}, Q{format.logical-block.1};

# (def-pprint-test format.logical-block.2
#   (format nil "~@<~A~:>" nil)
#   "NIL")
# 
is $*fl.format( Q{~@<~A~:>} ), Q{NIL}, Q{format.logical-block.2};

#`(
# (def-pprint-test format.logical-block.3
#   (format nil "~:<~A~:>" '(nil))
#   "(NIL)")
# 
is $*fl.format( Q{~:<~A~:>}, [ Nil ] ), Q{(NIL)}, Q{format.logical-block.3};
)

#`(
# (def-pprint-test format.logical-block.4
#   (format nil "~:@<~A~:>" nil)
#   "(NIL)")
# 
is $*fl.format( Q{~:@<~A~:>}, Nil ), Q{(NIL)}, Q{format.logical-block.4};
)

#`(
# (def-pprint-test format.logical-block.5
#   (format nil "~@:<~A~:>" nil)
#   "(NIL)")
# 
is $*fl.format( Q{~@:<~A~:>}, Nil ), Q{(NIL)}, Q{format.logical-block.5};
)

#`(
# (def-pprint-test format.logical-block.6
#   (format nil "~<~@{~A~^*~}~:>" '(1 2 3))
#   "1*2*3")
# 
is $*fl.format(
	Q{~<~@{~A~^*~}~:>},
	1, 2, 3
), Q{1*2*3}, Q{format.logical-block.6};
)

#`(
# (def-pprint-test format.logical-block.7
#   (format nil "~:<~@{~A~^*~}~:>" '(1 2 3))
#   "(1*2*3)")
# 
is $*fl.format(
	Q{~:<~@{~A~^*~}~:>},
	1, 2, 3
), Q{(1*2*3)}, Q{format.logical-block.7};
)

#`(
# (def-pprint-test format.logical-block.8
#   (format nil "~:<~@{~A~^*~}~:>" 1)
#   "1")
# 
is $*fl.format( Q{~:<~@{~A~^*~}~:>}, 1 ), Q{1}, Q{format.logical-block.8};
)

#`(
# (def-pprint-test format.logical-block.9
#   (format nil "~<~;~A~;~:>" '(1 2 3))
#   "1")
# 
is $*fl.format( Q{~<~;~A~;~:>}, 1, 2, 3 ), Q{1}, Q{format.logical-block.9};
)

#`(
# (def-pprint-test format.logical-block.10
#   (format nil "~<~;~A~:>" '(1 2 3))
#   "1")
# 
is $*fl.format( Q{~<~;~A~:>}, 1, 2, 3 ), Q{1}, Q{format.logical-block.10};
)

#`(
# (def-pprint-test format.logical-block.11
#   (format nil "~@<~;~A~;~:>" '(1 2 3))
#   "(1 2 3)")
# 
is $*fl.format(
	Q{~@<~;~A~;~:>},
	1, 2, 3
), Q{(1 2 3)}, Q{format.logical-block.11};
)

#`(
# (def-pprint-test format.logical-block.12
#   (format nil "~@<~;~A~:>" '(1 2 3))
#   "(1 2 3)")
# 
is $*fl.format(
	Q{~@<~;~A~:>},
	1, 2, 3
), Q{(1 2 3)}, Q{format.logical-block.12};
)

#`{
# (def-pprint-test format.logical-block.13
#   (format nil "~:<[~;~@{~A~^/~}~:>" '(1 2 3))
#   "[1/2/3)")
# 
is $*fl.format(
	Q{~:<[~;~@{~A~^/~}~:>},
	1, 2, 3
), Q{[1/2/3)}, Q{format.logical-block.13};
}

#`(
# (def-pprint-test format.logical-block.14
#   (format nil "~:<~;~@{~A~^/~}~;]~:>" '(1 2 3))
#   "1/2/3]")
# 
is $*fl.format(
	Q{~:<~;~@{~A~^/~}~;]~:>},
	1, 2, 3
), Q{1/2/3]}, Q{format.logical-block.14};
)

#`(
# (def-pprint-test format.logical-block.15
#   (format nil "~:<[~;~@{~A~^/~}~;]~:>" '(1 2 3))
#   "[1/2/3]")
# 
is $*fl.format(
	Q{~:<[~;~@{~A~^/~}~;]~:>},
	1, 2, 3
), Q{[1/2/3]}, Q{format.logical-block.15};
)

#`(
# (def-pprint-test format.logical-block.16
#   (format nil "~@<~@{~A~^*~}~:>" 1 2 3)
#   "1*2*3")
# 
is $*fl.format(
	Q{~@<~@{~A~^*~}~:>},
	1, 2, 3
), Q{1*2*3}, Q{format.logical-block.16};
)

#`(
# (def-pprint-test format.logical-block.17
#   (format nil "~@<~@{~A~^ ~_~}~:>" 1 2 3)
#   "1 2 3")
# 
is $*fl.format(
	Q{~@<~@{~A~^ ~_~}~:>},
	1, 2, 3
), Q{1 2 3}, Q{format.logical-block.17};
)

#`(
# (def-pprint-test format.logical-block.18
#   (format nil "~@<~@{~A~^ ~_~}~:>" 1 2 3)
#   "1
# 2
# 3"
#   :margin 2)
# 
is $*fl.format(
	Q{~@<~@{~A~^ ~_~}~:>},
	1, 2, 3
), qq{1\n2\n3}, Q{format.logical-block.18};
)

#`(
# (def-pprint-test format.logical-block.19
#   (format nil "~:@<~@{~A~^ ~_~}~:>" 1 2 3)
#   "(1
#  2
#  3)"
#   :margin 2)
# 
is $*fl.format(
	Q{~:@<~@{~A~^ ~_~}~:>},
	1, 2, 3
), qq{(1\n2\n3)}, Q{format.logical-block.19};
)

#`(
# (def-pprint-test format.logical-block.20
#   (format nil "~@:<~@{~A~^ ~}~:>" 1 2 3)
#   "(1 2 3)"
#   :margin 2)
# 
is $*fl.format(
	Q{~@:<~@{~A~^ ~}~:>},
	1, 2, 3
), Q{(1 2 3)}, Q{format.logical-block.20};
)

#`(
# (def-pprint-test format.logical-block.21
#   (format nil "~@:<~@{~A~^ ~:_~}~:>" 1 2 3)
#   "(1
#  2
#  3)"
#   :margin 2)
# 
is $*fl.format(
	Q{~@:<~@{~A~^ ~:_~}~:>},
	1, 2, 3
), qq{(1\n 2\n 3)}, Q{format.logical-block.21};
)

#`(
# (def-pprint-test format.logical-block.22
#   (format nil "~:@<~@{~A~^ ~}~:@>" 1 2 3)
#   "(1
#  2
#  3)"
#   :margin 2)
# 
is $*fl.format(
	Q{~:@<~@{~A~^ ~}~:@>},
	1, 2, 3
), qq{(1\n 2\n 3)}, Q{format.logical-block.22};
)

#`(
# (def-pprint-test format.logical-block.23
#   (format nil "~:@<~@{~A~^/~
#                    ~}~:@>" 1 2 3)
#   "(1/2/3)"
#   :margin 2)
# 
is $*fl.format(
	qq{~:@<~@{~A~^/~\n~}~:@>},
	1, 2, 3
), Q{(1/2/3)}, Q{format.logical-block.23};
)

#`(
# (def-pprint-test format.logical-block.24
#   (format nil "~:@<~@{~A~^            ~:_~}~:>" 1 2 3)
#   "(1
#  2
#  3)"
#   :margin 2)
# 
is $*fl.format(
	Q{~:@<~@{~A~^            ~:_~}~:>},
	1, 2, 3
), qq{(1\n 2\n 3)}, Q{format.logical-block.24};
)

#`(
# (def-pprint-test format.logical-block.25
#   (format nil "~:@<~@{~A~^            ~}~:@>" 1 2 3)
#   "(1
#  2
#  3)"
#   :margin 2)
# 
is $*fl.format(
	Q{~:@<~@{~A~^            ~}~:@>},
	1, 2, 3
), qq{(1\n 2\n 3)}, Q{format.logical-block.25};
)

#`(
# (def-pprint-test format.logical-block.26
#   (format nil "~:@<~@{~A~^~}~:@>" "1 2 3")
#   "(1 2 3)"
#   :margin 2)
# 
is $*fl.format(
	Q{~:@<~@{~A~^~}~:@>},
	"1 2 3"
), Q{(1 2 3)}, Q{format.logical-block.26};
)

#`(
# (def-pprint-test format.logical-block.27
#   (format nil "~@<**~@;~@{~A~^       ~}~:@>" 1 2 3)
#   "**1
# **2
# **3"
#   :margin 3)
# 
is $*fl.format(
	Q{~@<**~@;~@{~A~^       ~}~:@>},
	1, 2, 3
), qq{**1\n**2\n**3}, Q{format.logical-block.27};
)

#`(
# (def-pprint-test format.logical-block.28
#   (format nil "~@<**~@;~@{~A~^       ~}~;XX~:@>" 1 2 3)
#   "**1
# **2
# **3XX"
#   :margin 3)
# 
is $*fl.format(
	Q{~@<**~@;~@{~A~^       ~}~;XX~:@>},
	1, 2, 3
), qq{**1\n**2\n**3XX}, Q{format.logical-block.28};
)

#`[
# (def-pprint-test format.logical-block.29
#   (format nil "~:@<**~@;~@{~A~^       ~}~:@>" 1 2 3)
#   "**1
# **2
# **3)"
#   :margin 3)
# 
is $*fl.format(
	Q{~:@<**~@;~@{~A~^       ~}~:@>},
	1, 2, 3
), qq{**1\n**2\n**3}, Q{format.logical-block.29};
]

# ;;; Circularity detection
# 
#`(
# (def-pprint-test format.logical-block.circle.1
#   (format nil "~:<~@{~A~^ ~}~:>" (let ((x (list 0))) (list x x)))
#   "(#1=(0) #1#)"
#   :circle t)
# 
)

#`(
# (def-pprint-test format.logical-block.circle.2
#   (format nil "~:<~@{~A~^ ~}~:>" (let ((x (list 0))) (cons x x)))
#   "(#1=(0) . #1#)"
#   :circle t)
# 
)

#`(
# (def-pprint-test format.logical-block.circle.3
#   (format nil "~:<~@{~A~^ ~}~:>" (let ((x (list 0)))
#                                    (setf (cdr x) x)
#                                    x))
#   "#1=(0 . #1#)"
#   :circle t
#   :len 500)
# 
)

#`(
# (def-pprint-test format.logical-block.circle.4
#   (format nil "~:<~@{~A~^ ~}~:>" (let ((x (list 0))) (list x x)))
#   "((0) (0))")
# 
)

#`(
# (def-pprint-test format.logical-block.circle.5
#   (format nil "~:<~@{~A~^ ~}~:>" (let ((x (list 0))) (cons x x)))
#   "((0) 0)")
# 
)

# ;;; ~^ terminates a logical block
# 
#`(
# (def-pprint-test format.logical-block.escape.1
#   (format nil "~<~A~^xxxx~:>" '(1))
#   "1")
# 
is $*fl.format(
	Q{~<~A~^xxxx~:>},
	[ 1 ]
), Q{1}, Q{format.logical-block.escape.1};
)

#`(
# (def-pprint-test format.logical-block.escape.2
#   (format nil "~<~<~A~^xxx~:>yyy~:>" '((1)))
#   "1yyy")
# 
is $*fl.format(
	Q{~<~<~A~^xxx~:>yyy~:>},
	[ [ 1 ] ]
), Q{1yyy}, Q{format.logical-block.escape.2};
)

done-testing;

# vim: ft=perl6
