use v6;

use Test;
use lib 't/lib';
use Utils;
use Format::Lisp;

my $fl = Format::Lisp.new;

# (def-format-test format.{.1
#   (concatenate 'string "~{~" (string #\Newline) "~}")
#   (nil) "")
# 
is $fl.format( qq[~\{~\n~\}], Nil ), Q[], Q[format.{.1];

# (def-format-test format.{.1a
#   "~{~}" ("" nil) "")
# 
is $fl.format( Q[~{~}], Q[], Nil ), Q[], Q[format.{.1a];

# (def-format-test format.{.1b
#   "~0{~}" ("" '(1 2 3)) "")
# 
is $fl.format( Q[~0{~}], Q[], [ 1, 2, 3 ] ), Q[], Q[format.{.1b];

# (def-format-test format.{.2
#   "~{ ~}" (nil) "")
# 
is $fl.format( Q[~{ ~}], Nil ), Q[], Q[format.{.2];

# (def-format-test format.{.3
#   "~{X Y Z~}" (nil) "")
# 
is $fl.format( Q[~{X Y Z~}], Nil ), Q[], Q[format.{.3];

# (def-format-test format.{.4
#   "~{~A~}" ('(1 2 3 4)) "1234")
# 
is $fl.format( Q[~{~A~}], [ 1, 2, 3, 4 ] ), Q[1234], Q[format.{.4];

#`(
# (def-format-test format.{.5
#   "~{~{~A~}~}" ('((1 2 3)(4 5)(6 7 8))) "12345678")
# 
is $fl.format(
	Q[~{~{~A~}~}],
	[ [ 1, 2, 3 ], [ 4, 5 ], [ 6, 7, 8 ] ],
), Q[12345678], Q[format.{.5];
)

#`(
# (def-format-test format.{.6
#   "~{~1{~A~}~}" ('((1 2 3)(4 5)(6 7 8))) "146")
# 
is $fl.format(
	Q[~{~1{~A~}~}],
	[ [ 1, 2, 3 ], [ 4, 5 ], [ 6, 7, 8 ] ]
), Q[146], Q[format.{.6];
)

# (def-format-test format.{.7
#   (concatenate 'string "~1{~" (string #\Newline) "~}") (nil) "")
# 
is $fl.format( qq{~1\{~\n~\}}, Nil ), Q[], Q[format.{.7];

#`(
# (deftest format.{.8
#   (loop for i from 0 to 10
#         for s = (format nil "~v{~A~}" i '(1 2 3 4 5 6 7 8 9 0))
#         unless (string= s (subseq "1234567890" 0 i))
#         collect (list i s))
#   nil)
# 
is do {
	my @collected;
	for 0 .. 10 -> $i {
		my $s = $fl.format(
			Q[~v{~A~}],
			$i, [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 0 ]
		);
		unless $s eq Q[1234567890].substr( 0, $i ) {
			@collected.append( [ $i, $s ] );
		}
	}
	@collected.elems;
}, 0, Q[format.{.8];
)

#`(
# (deftest formatter.{.8
#   (let ((fn (formatter "~V{~A~}")))
#     (loop for i from 0 to 10
#           for s = (formatter-call-to-string fn i '(1 2 3 4 5 6 7 8 9 0))
#           unless (string= s (subseq "1234567890" 0 i))
#           collect (list i s)))
#   nil)
# 
is do {
	my $fn = $fl.formatter( Q[~V{~A~}] );
	my @collected;
	for 0 .. 10 -> $i {
		my $s = $fl.formatter-call-to-string(
			$fn,
			$i,
			[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 0 ]
		);
		unless $s eq Q[1234567890].substr( 0, $i ) {
			@collected.append( [ $i, $s ] );
		}
	}
	@collected.elems;
}, 0, Q[formatter.{.8];
)

#`(
# (def-format-test format.{.9
#   "~#{~A~}" ('(1 2 3 4 5 6 7) nil nil nil) "1234" 3)
# 
is $fl.format(
	Q[~#{~A~}],
	[ 1, 2, 3, 4, 5, 6, 7 ], Nil, Nil, Nil
), Q[1234], Q[format.{.9];
)

# ;;; (missing tests involved ~^ and have been moved to format-circumflex.lsp
# ;;;  and renamed.)
# 
# (def-format-test format.{.15
#   "~0{~}" ("~A" '(1 2 3)) "")
# 
is $fl.format( Q[~0{~}], Q[~A], [ 1, 2, 3 ] ), Q[], Q[format.{.15];

#`(
# (def-format-test format.{.16
#   "~1{~}" ("~A" '(4 5 6)) "4")
# 
is $fl.format( Q[~1{~}], Q[~A], [ 4, 5, 6 ] ), Q[4], Q[format.{.16];
)

#`(
# (deftest format.{.17
#   (format nil "~{~}" (formatter "") nil)
#   "")
# 
is $fl.format(
	Q[~{~}],
	$fl.formatter( Q[] ),
), Q[], Q[format.{.17];
)

# (deftest format.{.18
#   (format nil "~1{~}" (formatter "") '(1 2 3 4))
#   "")
# 
is $fl.format(
	Q[~1{~}],
	$fl.formatter( Q[] ), [ 1, 2, 3, 4 ]
), Q[], Q[format.{.18];

# (deftest format.{.19
#   (format nil "~{~}" (formatter "~A") '(1 2 3 4))
#   "1234")
# 
is $fl.format(
	Q[~{~}],
	$fl.formatter( Q[~A] ), [ 1, 2, 3, 4 ]
), Q[1234], Q[format.{.19];

#`(
# (deftest format.{.20
#   (format nil "~3{~}" (formatter "~A") '(1 2 3 4))
#   "123")
# 
is $fl.format(
	Q[~3{~}],
	$fl.formatter( Q[~A] ), [ 1, 2, 3, 4 ]
), Q[123], Q[format.{.20];
)

#`(
# (def-format-test format.{.21
#   "~V{~}" (2 "~A" '(1 2 3 4 5)) "12")
# 
is $fl.format( Q[~V{~}], 2, Q[~A], [ 1, 2, 3, 4, 5 ] ), Q[12], Q[format.{.21];
)

#`(
# (def-format-test format.{.22
#   "~#{~}" ("~A" '(1 2 3 4 5)) "12")
# 
is $fl.format( Q[~#{~}], Q[~A], [ 1, 2, 3, 4, 5 ] ), Q[12], Q[format.{.22];
)

#`(
# (def-format-test format.{.23
#   "~{FOO~:}" (nil) "FOO")
# 
is $fl.format( Q[~{FOO~:}], Nil ), Q[FOO], Q[format.{.23];
)

# (def-format-test format.{.24
#   "~{~A~:}" ('(1)) "1")
# 
is $fl.format( Q[~{~A~:}], [ 1 ] ), Q[1], Q[format.{.24];

# (def-format-test format.{.25
#   "~{~A~:}" ('(1 2)) "12")
# 
is $fl.format( Q[~{~A~:}], [ 1, 2 ] ), Q[12], Q[format.{.25];

# (def-format-test format.{.26
#   "~{~A~:}" ('(1 2 3)) "123")
# 
is $fl.format( Q[~{~A~:}], [ 1, 2, 3 ] ), Q[123], Q[format.{.26];

#`(
# (def-format-test format.{.27
#   "~0{FOO~:}" (nil) "")
# 
is $fl.format( Q[~0{FOO~:}], Nil ), Q[], Q[format.{.27];
)

#`(
# (def-format-test format.{.28
#   "~V{FOO~:}" (0 nil) "")
# 
is $fl.format( Q[~V{FOO~:}], 0, Nil ), Q[], Q[format.{.28];
)

#`(
# (def-format-test format.{.29
#   "~1{FOO~:}" (nil) "FOO")
# 
is $fl.format( Q[~1{FOO~:}], Nil ), Q[FOO], Q[format.{.29];
)

#`(
# (def-format-test format.{.30
#   "~2{FOO~:}" (nil) "FOO")
# 
is $fl.format( Q[~2{FOO~:}], Nil ), Q[FOO], Q[format.{.30];
)

# (def-format-test format.{.31
#   (concatenate 'string "~2{~" (string #\Newline) "~:}")
#   (nil) "")
# 
is $fl.format( qq[~2\{~\n~:\}], Nil ), Q[], Q[format.{.30];

# (def-format-test format.{.32
#   "~2{FOO~}" (nil) "")
# 
is $fl.format( Q[~2{FOO~}], Nil ), Q[], Q[format.{.32];

#`(
# (def-format-test format.{.33
#   "~v{~a~}" (nil '(1 2 3 4 5 6 7)) "1234567")
# 
is $fl.format(
	Q[~v{~a~}],
	Nil, [ 1, 2, 3, 4, 5, 6, 7 ]
), Q[1234567], Q[format.{.32];
)

# ;;; ~:{ ... ~}
# 
# (def-format-test format.\:{.1
#   "~:{(~A ~A)~}" ('((1 2 3)(4 5)(6 7 8))) "(1 2)(4 5)(6 7)")
# 
is $fl.format(
	Q[~:{(~A ~A)~}],
	[ [ 1, 2, 3 ], [ 4, 5 ], [ 6, 7, 8 ] ]
), Q[(1 2)(4 5)(6 7)], Q[format.:{.1];

# (def-format-test format.\:{.2
#   (concatenate 'string "~:{~" (string #\Newline) "~}")
#   (nil) "")
# 
is $fl.format( qq[~:\{~\n~\}], Nil ), Q[], Q[format.:{.2];

# (def-format-test format.\:{.3
#   "~:{~}" ("" nil) "")
# 
is $fl.format( Q[~:{~}], Q[], Nil ), Q[], Q[format.:{.3];

# (def-format-test format.\:{.4
#   "~:{~}" ("~A" nil) "")
# 
is $fl.format( Q[~:{~}], Q[~A], Nil ), Q[], Q[format.:{.4];

#`(
# (def-format-test format.\:{.5
#   "~:{~}" ("X" '(nil (1 2) (3))) "XXX")
# 
is $fl.format(
	Q[~:{~}],
	Q[X], [ Nil, [ 1, 2 ], [ 3 ] ]
), Q[XXX], Q[format.:{.5];
)

#`(
# (deftest format.\:{.6
#   (format nil "~:{~}" (formatter "~A") '((1 2) (3) (4 5 6)))
#   "134")
# 
is $fl.format(
	Q[~:{~}],
	$fl.formatter( Q[~A] ),
	[ [ 1, 2 ], [ 3 ], [ 4, 5, 6 ] ]
), Q[134], Q[format.:{.6];
)

#`(
# (def-format-test format.\:{.7
#   "~0:{XYZ~}" ('((1))) "")
# 
is $fl.format( Q[~0:{XYZ~}], [ [ 1 ] ] ), Q[], Q[format.:{.7];
)

# (def-format-test format.\:{.8
#   "~2:{XYZ~}" ('((1))) "XYZ")
# 
is $fl.format( Q[~2:{XYZ~}], [ [ 1 ] ] ), Q[XYZ], Q[format.:{.7];

# (def-format-test format.\:{.9
#   "~2:{~A~}" ('((1) (2))) "12")
# 
is $fl.format( Q[~2:{~A~}], [ [ 1 ], [ 2 ] ] ), Q[12], Q[format.:{.9];

#`(
# (def-format-test format.\:{.10
#   "~2:{~A~}" ('((1 X) (2 Y) (3 Z))) "12")
# 
is $fl.format(
	Q[~2:{~A~}],
	[ [ 1, Q[X] ], [ 2, Q[V] ], [ 3, Q[Z] ] ]
), Q[12], Q[format.:{.10];
)

#`(
# (deftest format.\:{.11
#   (loop for i from 0 to 10 collect
#         (format nil "~v:{~A~}" i '((1) (2) (3 X) (4 Y Z) (5) (6))))
#   ("" "1" "12" "123" "1234" "12345"
#    "123456" "123456" "123456" "123456" "123456"))
# 
is do {
	my @collected;
	for 0 .. 10 -> $i {
		@collected.append(
			$fl.format(
				Q[~v:{~A~}],
				$i, [ [ 1 ], [ 2 ], [ 3, Q[X] ],
				      [ 4, Q[Y], Q[Z] ], [ 5 ], [ 6 ] ]
			)
		);
	}
	@collected;
}, [
	Q[],
	Q[1],
	Q[12],
	Q[123],
	Q[1234],
	Q[12345],
	Q[123456],
	Q[123456],
	Q[123456],
	Q[123456],
	Q[123456],
], Q[format.:{.11];
)

#`(
# (deftest formatter.\:{.11
#   (let ((fn (formatter "~v:{~A~}")))
#     (loop for i from 0 to 10 collect
#           (formatter-call-to-string fn i '((1) (2) (3 X) (4 Y Z) (5) (6)))))
#   ("" "1" "12" "123" "1234" "12345"
#    "123456" "123456" "123456" "123456" "123456"))
# 
)

#`(
# (def-format-test format.\:{.12
#   "~V:{X~}" (nil '((1) (2) (3) nil (5))) "XXXXX")
# 
is $fl.format(
	Q[~V:{X~}],
	Nil, [ [ 1 ], [ 2 ], [ 3 ], Nil, [ 5 ] ]
), Q[XXXXX], Q[format.:{.12];
)

# 'foo and 'bar
#`(
# (def-format-test format.\:{.13
#   "~#:{~A~}" ('((1) (2) (3) (4) (5)) 'foo 'bar) "123" 2)
# 
is $fl.format(
	Q[~#:{~A~}],
	[ [ 1 ], [ 2 ], [ 3 ], [ 4 ], [ 5 ] ], Q[foo], Q[bar]
), Q[123], Q[format.:{.13];
)

# (def-format-test format.\:{.14
#   "~:{~A~:}" ('((1 X) (2 Y) (3) (4 A B))) "1234")
# 
is $fl.format(
	Q[~:{~A~}],
	[ [ 1, Q[X] ], [ 2, Q[Y] ], [ 3 ], [ 4, Q[A], Q[B] ] ]
), Q[1234], Q[format.:{.14];

#`(
# (deftest format.\:{.15
#   (loop for i from 0 to 10 collect
#         (format nil "~v:{~A~:}" i '((1 X) (2 Y) (3) (4 A B))))
#   ("" "1" "12" "123" "1234" "1234"
#    "1234" "1234" "1234" "1234" "1234"))
# 
is-deeply do {
	my @collected;
	for 0 .. 10 -> $i {
		@collected.append(
			$fl.format(
				Q[~v:{~A~:}],
				[ [ 1, Q[X] ], [ 2, Q[Y] ],
				  [ 3 ], [ 4, Q[A], Q[B] ] ]
			)
		);
	}
	@collected;
}, [
	Q[],
	Q[1],
	Q[12],
	Q[12]],
	Q[1234],
	Q[1234],
	Q[1234],
	Q[1234],
	Q[1234],
	Q[1234],
	Q[1234],
], Q[format.:{.15];
)

#`(
# (deftest formatter.\:{.15
#   (let ((fn (formatter "~v:{~A~:}")))
#     (loop for i from 0 to 10 collect
#           (formatter-call-to-string fn i '((1 X) (2 Y) (3) (4 A B)))))
#   ("" "1" "12" "123" "1234" "1234"
#    "1234" "1234" "1234" "1234" "1234"))
# 
)

# (def-format-test format.\:{.16
#   "~:{ABC~:}" ('(nil)) "ABC")
# 
is $fl.format( Q[~:{ABC~:}], [ Nil ] ), Q[ABC], Q[format.:{.16];

#`(
# (def-format-test format.\:{.17
#   "~v:{ABC~:}" (nil '(nil)) "ABC")
# 
is $fl.format( Q[~v:{ABC~:}], Nil, [ Nil ] ), Q[ABC], Q[format.:{.17];
)

# ;;; Tests of ~@{ ... ~}
# 
# (def-format-test format.@{.1
#   (concatenate 'string "~@{~" (string #\Newline) "~}")
#   nil "")
# 
is $fl.format( qq[~@\{~\n~\}] ), Q[], Q[format.@{.1];

# (def-format-test format.@{.1A
#   "~@{~}" ("") "")
# 
is $fl.format( Q[~@{~}], Q[] ), Q[], Q[format.@{.1A];

# (def-format-test format.@{.2
#   "~@{ ~}" nil "")
# 
is $fl.format( Q[~@{ ~}] ), Q[], Q[format.@{.2];

#`(
# (def-format-test format.@{.3
#   "~@{X ~A Y Z~}" (nil) "X NIL Y Z")
# 
is $fl.format( Q[~@{X ~A Y Z~}], Nil ), Q[X NIL Y Z], Q[format.@{.3];
)

#`(
# (def-format-test format.@{.4
#   "~@{~A~}" (1 2 3 4) "1234")
# 
is $fl.format( Q[~@{~A~}], 1, 2, 3, 4 ), Q[1234], Q[format.@{.4];
)

#`(
# (def-format-test format.@{.5
#   "~@{~{~A~}~}" ('(1 2 3) '(4 5) '(6 7 8)) "12345678")
# 
is $fl.format(
	Q[~@{~{~A~}~}],
	[ 1, 2, 3 ], [ 4, 5 ], [ 6, 7, 8 ]
), Q[12345678], Q[format.@{.5];
)

#`(
# (def-format-test format.@{.6
#   "~@{~1{~A~}~}" ('(1 2 3) '(4 5) '(6 7 8)) "146")
# 
is $fl.format(
	Q[~@{~1{~A~}~}],
	[ 1, 2, 3 ], [ 4, 5 ], [ 6, 7, 8 ]
), Q[146], Q[format.@{.6];
)

# (def-format-test format.@{.7
#   "~1@{FOO~}" nil "")
# 
is $fl.format( Q[~1@{FOO~}] ), Q[], Q[format.@{.7];

#`(
# (def-format-test format.@{.8
#   "~v@{~A~}" (nil 1 4 7) "147")
# 
is $fl.format( Q[~v@{~A~}], Nil, 1, 4, 7 ), Q[147], Q[format.@{.8];
)

#`(
# (def-format-test format.@{.9
#   "~#@{~A~}" (1 2 3) "123")
# 
is $fl.format( Q[~#@{~A~}], 1, 2, 3 ), Q[123], Q[format.@{.9];
)

#`(
# (deftest format.@{.10
#   (loop for i from 0 to 10
#         for x = nil then (cons i x)
#         collect (apply #Q[format nil "~v@{~A~}" i (reverse x)))
#   ("" "1" "12" "123" "1234" "12345"
#    "123456" "1234567" "12345678" "123456789" "12345678910"))
# 
)

#`(
# (deftest formatter.@{.10
#   (let ((fn (formatter "~v@{~A~}")))
#     (loop for i from 0 to 10
#           for x = nil then (cons i x)
#           for rest = (list 'a 'b 'c)
#           collect
#           (with-output-to-string
#             (s)
#             (assert (equal (apply fn s i (append (reverse x) rest)) rest)))))
#   ("" "1" "12" "123" "1234" "12345"
#    "123456" "1234567" "12345678" "123456789" "12345678910"))
# 
)

#`(
# (def-format-test format.@{.11
#   "~@{X~:}" nil "X")
# 
is $fl.format( Q[~@{X~:}] ), Q[X], Q[format.@{.11];
)

#`(
# (def-format-test format.@{.12
#   "~@{~}" ((formatter "X~AY") 1) "X1Y")
# 
is $fl.format(
	Q[~@{~}],
	$fl.formatter( Q[X~AY] ), 1
), Q[X1Y], Q[format.@{.12];
)

#`(
# (def-format-test format.@{.13
#   "~v@{~}" (1 (formatter "X") 'foo) "X" 1)
# 
is $fl.format(
	Q[~@{~}],
	1, $fl.formatter( Q[X~AY] ), 'foo'
), Q[X], Q[format.@{.13];
)

# ;;; ~:@{
# 
# (def-format-test format.\:@{.1
#   (concatenate 'string "~:@{~" (string #\Newline) "~}")
#   nil "")
# 
is $fl.format( qq[~:@\{~\n~\}] ), Q[], Q[format.:@{.1];

#`(
# (def-format-test format.\:@{.2
#   "~:@{~A~}" ('(1 2) '(3) '(4 5 6)) "134")
# 
is $fl.format(
	Q[~:@{~A~}],
	[ 1, 2 ], [ 3 ], [ 4, 5, 6 ]
), Q[134], Q[format.:@.3];
)

#`(
# (def-format-test format.\:@{.3
#   "~:@{(~A ~A)~}" ('(1 2 4) '(3 7) '(4 5 6)) "(1 2)(3 7)(4 5)")
# 
is $fl.format(
	Q[~:@{(~A ~A)~}],
	[ 1, 2, 4 ], [ 3, 7 ], [ 4, 5, 6 ]
), Q[(1 2)(3 7)(4 5)], Q[format.:@.3];
)

#`(
# (def-format-test format.\:@{.4
#   "~:@{~}" ("(~A ~A)" '(1 2 4) '(3 7) '(4 5 6)) "(1 2)(3 7)(4 5)")
# 
is $fl.format(
	Q[~:@{~}],
	Q[(~A ~A)], [ 1, 2, 4 ], [ 3, 7 ], [ 4, 5, 6 ]
), Q[(1 2)(3 7)(4 5)], Q[format.:@.4];
)

#`(
# (def-format-test format.\:@{.5
#   "~:@{~}" ((formatter "(~A ~A)") '(1 2 4) '(3 7) '(4 5 6)) "(1 2)(3 7)(4 5)")
# 
is $fl.format(
	Q[~:@{~}],
	1, $fl.formatter( Q[(~A ~A)] ), 'foo'
), Q[X], Q[format.@{.13];
)

#`(
# (def-format-test format.\:@.6
#   "~:@{~A~:}" ('(1 A) '(2 B) '(3) '(4 C D)) "1234")
# 
is $fl.format(
	Q[~:@{~A~:}],
	[ 1, Q[A] ], [ 2, Q[B] ], [ 3 ], [ 4, Q[C], Q[D] ]
), Q[1234], Q[format.:@.6];
)

#`(
# (def-format-test format.\:@.7
#   "~0:@{~A~:}" ('(1 A) '(2 B) '(3) '(4 C D)) "" 4)
# 
is $fl.format(
	Q[~0:@{~A~:}],
	[ 1, Q[A] ], [ 2, Q[B] ], [ 3 ], [ 4, Q[C], Q[D] ]
), Q[], Q[format.:@.7];
)

#`(
# (def-format-test format.\:@.8
#   "~#:@{A~:}" (nil nil nil) "AAA")
# 
is $fl.format( Q[~#:@{A~:}], Nil, Nil, Nil ), Q[AAA], Q[format.:@.8];
)

#`(
# (def-format-test format.\:@.9
#   "~v:@{~A~}" (nil '(1) '(2) '(3)) "123")
# 
is $fl.format( Q[~v:@{~A~}], Nil, [ 1 ], [ 2 ], [ 3 ] ), Q[123], Q[format.:@.9];
)

#`(
# (deftest format.\:@.10
#   (loop for i from 0 to 10
#         for x = nil then (cons (list i) x)
#         collect
#         (apply #Q[format nil "~V:@{~A~}" i (reverse x)))
#   ("" "1" "12" "123" "1234" "12345" "123456" "1234567" "12345678"
#    "123456789" "12345678910"))
# 
is-deeply do {
	my @collected;
	my @x;
	for 0 .. 10 -> $i {
		@x.append( $i );
		@collected.append(
			$fl.format( Q[~V:@{~A~}], $i, @x.reverse )
		);
	}
	@collected;
}, [	Q[],
	Q[1],
	Q[12],
	Q[123],
	Q[1234],
	Q[12345],
	Q[123456],
	Q[1234567],
	Q[12345678],
	Q[123456789],
	Q[12345678910]
], Q[format.:@.10];
)

#`(
# (deftest formatter.\:@.10
#   (let ((fn (formatter "~V@:{~A~}")))
#     (loop for i from 0 to 10
#           for x = nil then (cons (list i) x)
#           for rest = (list 'a 'b)
#           collect
#           (with-output-to-string
#             (s)
#             (assert (equal (apply fn s i (append (reverse x) rest)) rest)))))
#   ("" "1" "12" "123" "1234" "12345" "123456" "1234567" "12345678"
#    "123456789" "12345678910"))
# 
is-deeply do {
	my @collected;
	my @x;
	for 0 .. 10 -> $i {
		@x.append( $i );
		@collected.append(
#			$fl.format( Q[~V:@{~A~}], $i, @x.reverse )
		);
	}
	@collected;
}, [	Q[],
	Q[1],
	Q[12],
	Q[123],
	Q[1234],
	Q[12345],
	Q[123456],
	Q[1234567],
	Q[12345678],
	Q[123456789],
	Q[12345678910]
], Q[formatter.:@.10];
)

# ;;; Error tests
# 
#`(
# (deftest format.{.error.1
#   (signals-type-error x 'A (format nil "~{~A~}" x))
#   t)
# 
throws-like {
	my $x = :A; # XXX Not sure...
	$fl.format( Q[~{~A~}], $x );
}, X::Type-Error, Q[format.{.error.1];
)

#`(
# (deftest format.{.error.2
#   (signals-type-error x 1 (format nil "~{~A~}" x))
#   t)
# 
throws-like {
	my $x = 1; # XXX Not sure...
	$fl.format( Q[~{~A~}], $x );
}, X::Type-Error, Q[format.{.error.2];
)

#`(
# (deftest format.{.error.3
#   (signals-type-error x "foo" (format nil "~{~A~}" x))
#   t)
# 
throws-like {
	my $x = Q[foo]; # XXX Not sure...
	$fl.format( Q[~{~A~}], $x );
}, X::Type-Error, Q[format.{.error.3];
)

#`(
# (deftest format.{.error.4
#   (signals-type-error x #*01101 (format nil "~{~A~}" x))
#   t)
# 
throws-like {
	my $x = 0b01101; # XXX Not sure...
	$fl.format( Q[~{~A~}], $x );
}, X::Type-Error, Q[format.{.error.4];
)

#`(
# (deftest format.{.error.5
#   (signals-error (format nil "~{~A~}" '(x y . z)) type-error)
#   t)
# 
throws-like {
	my $x = :x; # XXX symbol
	$fl.format( Q[~{~A~}], $x );
}, X::Error, Q[format.{.error.5];
)

#`(
# (deftest format.\:{.error.1
#   (signals-error (format nil "~:{~A~}" '(x)) type-error)
#   t)
# 
throws-like {
	my $x = :x; # XXX symbol
	$fl.format( Q[~:{~A~}], $x );
}, X::Error, Q[format.:{.error.1];
)

#`(
# (deftest format.\:{.error.2
#   (signals-type-error x 'x (format nil "~:{~A~}" x))
#   t)
# 
throws-like {
	my $x = :x; # XXX symbol
	$fl.format( Q[~:{~A~}], $x );
}, X::Type-Error, Q[format.:{.error.2];
)

#`(
# (deftest format.\:{.error.3
#   (signals-error (format nil "~:{~A~}" '((x) . y)) type-error)
#   t)
# 
throws-like {
	my $x = :x; # XXX symbol
	$fl.format( Q[~:{~A~}], $x );
}, X::Error, Q[format.:{.error.3];
)

#`(
# (deftest format.\:{.error.4
#   (signals-error (format nil "~:{~A~}" '("X")) type-error)
#   t)
# 
throws-like {
	my $x = :x; # XXX symbol
	$fl.format( Q[~:{~A~}], $x );
}, X::Error, Q[format.:{.error.4];
)

#`(
# (deftest format.\:{.error.5
#   (signals-error (format nil "~:{~A~}" '(#(X Y Z))) type-error)
#   t)
# 
throws-like {
	my $x = :x; # XXX symbol
	$fl.format( Q[~:{~A~}], $x );
}, X::Error, Q[format.:{.error.5];
)

#`(
# (deftest format.\:@{.error.1
#   (signals-type-error x 'x (format nil "~:@{~A~}" x))
#   t)
# 
throws-like {
	my $x = :x; # XXX symbol
	$fl.format( Q[~:@{~A~}], $x );
}, X::Type-Error, Q[format.:@{.error.1];
)

#`(
# (deftest format.\:@{.error.2
#   (signals-type-error x 0 (format nil "~:@{~A~}" x))
#   t)
# 
throws-like {
	my $x = 0;
	$fl.format( Q[~:@{~A~}], $x );
}, X::Type-Error, Q[format.:@{.error.2];
)

#`(
# (deftest format.\:@{.error.3
#   (signals-type-error x #*01101 (format nil "~:@{~A~}" x))
#   t)
# 
throws-like {
	my $x = 0b01101;
	$fl.format( Q[~:@{~A~}], $x );
}, X::Type-Error, Q[format.:@{.error.3];
)

#`(
# (deftest format.\:@{.error.4
#   (signals-type-error x "abc" (format nil "~:@{~A~}" x))
#   t)
# 
throws-like {
	my $x = Q[abc];
	$fl.format( Q[~:@{~A~}], $x );
}, X::Type-Error, Q[format.:@{.error.4];
)

#`(
# (deftest format.\:@{.error.5
#   (signals-error (format nil "~:@{~A ~A~}" '(x . y)) type-error)
#   t)
# 
throws-like {
	my $x = Q[abc];
	$fl.format( Q[~:@{~A ~A~}], $x );
}, X::Type-Error, Q[format.:@{.error.5];
)

done-testing;

# vim: ft=perl6
