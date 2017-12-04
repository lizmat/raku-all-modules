use v6;

use Test;
use lib 't/lib';
use Utils;
use Format::Lisp;

my $*fl = Format::Lisp.new;

# (def-pprint-test format.justify.1
#   (format nil "~<~>")
#   "")
# 
is $*fl.format( Q{~<~>}, Nil ), Q{}, Q{format.justify.1};

#`(
# (def-pprint-test format.justify.2
#   (loop for i from 1 to 20
#         for s1 = (make-string i :initial-element #\x)
#         for s2 = (format nil "~<~A~>" s1)
#         unless (string= s1 s2)
#         collect (list i s1 s2))
#   nil)
# 
is do {
	my @collected;
	for 1 .. 20 -> $i {
		my $s1 = Q{x} xx $i - 1;
		my $s2 = $*fl.format( Q{~<~A~>}, $s1 );
		unless $s1 eq $s2 {
			@collected.append( [ $i, $s1, $s2 ] );
		}
	}
	@collected.elems;
}, 0, Q{format.justify.2};
)

#`(
# (def-pprint-test format.justify.3
#   (loop for i from 1 to 20
#         for s1 = (make-string i :initial-element #\x)
#         for s2 = (format nil "~<~A~;~A~>" s1 s1)
#         unless (string= s2 (concatenate 'string s1 s1))
#         collect (list i s1 s2))
#   nil)
# 
is do {
	my @collected;
	for 1 .. 20 -> $i {
		my $s1 = Q{x} xx $i - 1;
		my $s2 = $*fl.format( Q{~<~A~;~A~>}, $s1, $s1 );
		unless $s2 eq $s1 ~ $s1 {
			@collected.append( [ $i, $s1, $s2 ] );
		}
	}
	@collected.elems;
}, 0, Q{format.justify.3};
)

#`(
# (def-pprint-test format.justify.4
#   (loop for i from 1 to 20
#         for s1 = (make-string i :initial-element #\x)
#         for expected = (concatenate 'string s1 " " s1)
#         for s2 = (format nil "~,,1<~A~;~A~>" s1 s1)
#         unless (string= s2 expected)
#         collect (list i expected s2))
#   nil)
# 
is do {
	my @collected;
	for 1 .. 20 -> $i {
		my $s1 = Q{x} xx $i - 1;
		my $expected = $s1 ~ ' ' ~ $s1;
		my $s2 = $*fl.format( Q{~,,1<~A~;~A~>}, $s1, $s1 );
		unless $s2 eq $expected {
			@collected.append( [ $i, $expected, $s2 ] );
		}
	}
	@collected.elems;
}, 0, Q{format.justify.4};
)

#`(
# (def-pprint-test format.justify.5
#   (loop for i from 1 to 20
#         for s1 = (make-string i :initial-element #\x)
#         for expected = (concatenate 'string s1 "," s1)
#         for s2 = (format nil "~,,1,',<~A~;~A~>" s1 s1)
#         unless (string= s2 expected)
#         collect (list i expected s2))
#   nil)
# 
is do {
	my @collected;
	for 1 .. 20 -> $i {
		my $s1 = Q{x} xx $i - 1;
		my $expected = $s1 ~ Q{,} ~ $s1;
		my $s2 = $*fl.format( Q{~,,1,',<~A~;~A~>}, $s1, $s1 );
		unless $s2 eq $expected {
			@collected.append( [ $i, $expected, $s2 ] );
		}
	}
	@collected.elems;
}, 0, Q{format.justify.5};
)

#`(
# (def-pprint-test format.justify.6
#   (loop for i from 1 to 20
#         for s1 = (make-string i :initial-element #\x)
#         for expected = (concatenate 'string s1 "  " s1)
#         for s2 = (format nil "~,,2<~A~;~A~>" s1 s1)
#         unless (string= s2 expected)
#         collect (list i expected s2))
#   nil)
# 
is do {
	my @collected;
	for 1 .. 20 -> $i {
		my $s1 = Q{x} xx $i - 1;
		my $expected = $s1 ~ Q{  } ~ $s1;
		my $s2 = $*fl.format( Q{~,,2<~A~;~A~>}, $s1, $s1 );
		unless $s2 eq $expected {
			@collected.append( [ $i, $expected, $s2 ] );
		}
	}
	@collected.elems;
}, 0, Q{format.justify.6};
)

#`(
# (def-pprint-test format.justify.7
#   (loop for mincol = (random 50)
#         for len = (random 50)
#         for s1 = (make-string len :initial-element #\x)
#         for s2 = (format nil "~v<~A~>" mincol s1)
#         for expected = (if (< len mincol)
#                            (concatenate 'string
#                                         (make-string (- mincol len) :initial-element #\Space)
#                                         s1)
#                          s1)
#         repeat 100
#         unless (string= s2 expected)
#         collect (list mincol len s1 s2 expected))
#   nil)
# 
is do {
	my @collected;
	for 1 .. 100 {
#		my $s1 = Q{x} xx $i - 1;
#		my $expected = $s1 ~ Q{  } ~ $s1;
#		my $s2 = $*fl.format( Q{~,,2<~A~;~A~>}, $s1, $s1 );
#		unless $s2 eq $expected {
#			@collected.append( [ $i, $expected, $s2 ] );
#		}
	}
	@collected.elems;
}, 0, Q{format.justify.7};
)

#`(
# (def-pprint-test format.justify.8
#   (loop for mincol = (random 50)
#         for minpad = (random 10)
#         for len = (random 50)
#         for s1 = (make-string len :initial-element #\x)
#         for s2 = (format nil "~v,,v<~A~>" mincol minpad s1)
#         for expected = (if (< len mincol)
#                            (concatenate 'string
#                                         (make-string (- mincol len) :initial-element #\Space)
#                                         s1)
#                          s1)
#         repeat 100
#         unless (string= s2 expected)
#         collect (list mincol minpad len s1 s2 expected))
#   nil)
# 
is do {
	my @collected;
	for 1 .. 100 {
#		my $s1 = Q{x} xx $i - 1;
#		my $expected = $s1 ~ Q{  } ~ $s1;
#		my $s2 = $*fl.format( Q{~,,2<~A~;~A~>}, $s1, $s1 );
#		unless $s2 eq $expected {
#			@collected.append( [ $i, $expected, $s2 ] );
#		}
	}
	@collected.elems;
}, 0, Q{format.justify.8};
)

#`(
# (def-pprint-test format.justify.9
#   (loop for mincol = (random 50)
#         for padchar = (random-from-seq +standard-chars+)
#         for len = (random 50)
#         for s1 = (make-string len :initial-element #\x)
#         for s2 = (format nil "~v,,,v<~A~>" mincol padchar s1)
#         for expected = (if (< len mincol)
#                            (concatenate 'string
#                                         (make-string (- mincol len) :initial-element padchar)
#                                         s1)
#                          s1)
#         repeat 100
#         unless (string= s2 expected)
#         collect (list mincol padchar len s1 s2 expected))
#   nil)
# 
is do {
	my @collected;
	for 1 .. 100 {
#		my $s1 = Q{x} xx $i - 1;
#		my $expected = $s1 ~ Q{  } ~ $s1;
#		my $s2 = $*fl.format( Q{~,,2<~A~;~A~>}, $s1, $s1 );
#		unless $s2 eq $expected {
#			@collected.append( [ $i, $expected, $s2 ] );
#		}
	}
	@collected.elems;
}, 0, Q{format.justify.9};
)

#`(
# (def-pprint-test format.justify.10
#   (loop for mincol = (random 50)
#         for padchar = (random-from-seq +standard-chars+)
#         for len = (random 50)
#         for s1 = (make-string len :initial-element #\x)
#         for s2 = (format nil (format nil "~~~d,,,'~c<~~A~~>" mincol padchar) s1)
#         for expected = (if (< len mincol)
#                            (concatenate 'string
#                                         (make-string (- mincol len) :initial-element padchar)
#                                         s1)
#                          s1)
#         repeat 500
#         unless (string= s2 expected)
#         collect (list mincol padchar len s1 s2 expected))
#   nil)
# 
is do {
	my @collected;
	for 1 .. 500 {
#		my $s1 = Q{x} xx $i - 1;
#		my $expected = $s1 ~ Q{  } ~ $s1;
#		my $s2 = $*fl.format( Q{~,,2<~A~;~A~>}, $s1, $s1 );
#		unless $s2 eq $expected {
#			@collected.append( [ $i, $expected, $s2 ] );
#		}
	}
	@collected.elems;
}, 0, Q{format.justify.10};
)

#`(
# (def-pprint-test format.justify.11
#   (loop for i = (1+ (random 20))
#         for colinc = (1+ (random 10))
#         for s1 = (make-string i :initial-element #\x)
#         for s2 = (format nil "~,v<~A~>" colinc s1)
#         for expected-len = (* colinc (ceiling i colinc))
#         for expected = (concatenate 'string
#                                     (make-string (- expected-len i) :initial-element #\Space)
#                                     s1)
#         repeat 10
#         unless (string= expected s2)
#         collect (list i colinc expected s2))
#   nil)
# 
is do {
	my @collected;
	for 1 .. 10 {
#		my $s1 = Q{x} xx $i - 1;
#		my $expected = $s1 ~ Q{  } ~ $s1;
#		my $s2 = $*fl.format( Q{~,,2<~A~;~A~>}, $s1, $s1 );
#		unless $s2 eq $expected {
#			@collected.append( [ $i, $expected, $s2 ] );
#		}
	}
	@collected.elems;
}, 0, Q{format.justify.11};
)

#`(
# (def-pprint-test format.justify.12
#   (format nil "~<XXXXXX~^~>")
#   "")
# 
is $*fl.format( Q{~<XXXXXX~^~>} ), Q{}, Q{format.justify.12};
)

#`(
# (def-pprint-test format.justify.13
#   (format nil "~<XXXXXX~;YYYYYYY~^~>")
#   "XXXXXX")
# 
is $*fl.format( Q{~<XXXXXX~;YYYYYYY~^~>} ), Q{XXXXXX}, Q{format.justify.13};
)

#`(
# (def-pprint-test format.justify.13a
#   (format nil "~<~<XXXXXX~;YYYYYYY~^~>~>")
#   "XXXXXX")
# 
is $*fl.format( Q{~<~<XXXXXX~;YYYYYYY~^~>~>} ), Q{XXXXXX}, Q{format.justify.13a};
)

#`(
# (def-pprint-test format.justify.14
#   (format nil "~<XXXXXX~;YYYYYYY~^~;ZZZZZ~>")
#   "XXXXXX")
# 
is $*fl.format(
	Q{~<~<XXXXXX~;YYYYYYY~^~;ZZZZZ~>~>}
), Q{XXXXXX}, Q{format.justify.14};
)

#`(
# (def-pprint-test format.justify.15
#   (format nil "~13,,2<aaa~;bbb~;ccc~>")
#   "aaa  bbb  ccc")
# 
is $*fl.format(
	Q{~13,,2<aaa~;bbb~;ccc~>}
), Q{aaa  bbb  ccc}, Q{format.justify.15};
)

#`(
# (def-pprint-test format.justify.16
#   (format nil "~10@<abcdef~>")
#   "abcdef    ")
# 
is $*fl.format( Q{~10@<abcdef~>} ), Q{abcdef    }, Q{format.justify.16};
)

#`(
# (def-pprint-test format.justify.17
#   (format nil "~10:@<abcdef~>")
#   "  abcdef  ")
# 
is $*fl.format( Q{~10:@<abcdef~>} ), Q{  abcdef  }, Q{format.justify.17};
)

#`(
# (def-pprint-test format.justify.18
#   (format nil "~10:<abcdef~>")
#   "    abcdef")
# 
is $*fl.format( Q{~10:<abcdef~>} ), Q{    abcdef}, Q{format.justify.18};
)

#`(
# (def-pprint-test format.justify.19
#   (format nil "~4@<~>")
#   "    ")
# 
is $*fl.format( Q{~4@<~>} ), Q{    }, Q{format.justify.19};
)

#`(
# (def-pprint-test format.justify.20
#   (format nil "~5:@<~>")
#   "     ")
is $*fl.format( Q{~5:@<~>} ), Q{     }, Q{format.justify.20};
# 
)

#`(
# (def-pprint-test format.justify.21
#   (format nil "~6:<~>")
#   "      ")
# 
is $*fl.format( Q{~6:<~>} ), Q{      }, Q{format.justify.21};
)

#`(
# (def-pprint-test format.justify.22
#   (format nil "~v<~A~>" nil "XYZ")
#   "XYZ")
# 
is $*fl.format( Q{~v:<~A~>}, Nil, Q{XYZ} ), Q{XYZ}, Q{format.justify.22};
)

#`(
# (def-pprint-test format.justify.23
#   (format nil "~,v<~A~;~A~>" nil "ABC" "DEF")
#   "ABCDEF")
# 
is $*fl.format(
	Q{~,v:<~A~;~A~>},
	Nil, Q{ABC}, Q{DEF}
), Q{ABCDEF}, Q{format.justify.23};
)

#`(
# (def-pprint-test format.justify.24
#   (format nil "~,,v<~A~;~A~>" nil "ABC" "DEF")
#   "ABCDEF")
# 
is $*fl.format(
	Q{~,,v:<~A~;~A~>},
	Nil, Q{ABC}, Q{DEF}
), Q{ABCDEF}, Q{format.justify.24};
)

#`(
# (def-pprint-test format.justify.25
#   (format nil "~,,1,v<~A~;~A~>" nil "ABC" "DEF")
#   "ABC DEF")
# 
is $*fl.format(
	Q{~,,1,v<~A~;~A~>},
	Nil, Q{ABC}, Q{DEF}
), Q{ABC DEF}, Q{format.justify.25};
)

#`(
# (def-pprint-test format.justify.26
#   (format nil "~,,1,v<~A~;~A~>" #\, "ABC" "DEF")
#   "ABC,DEF")
# 
is $*fl.format(
	Q{~,,1,v<~A~;~A~>},
	Q{.}, Q{ABC}, Q{DEF}
), Q{ABC,DEF}, Q{format.justify.26};
)

#`(
# (def-pprint-test format.justify.27
#   (format nil "~6<abc~;def~^~>")
#   "   abc")
# 
is $*fl.format(
	Q{~6<abc~;def~^~>},
	Q{.}, Q{ABC}, Q{DEF}
), Q{   abc}, Q{format.justify.27};
)

#`(
# (def-pprint-test format.justify.28
#   (format nil "~6@<abc~;def~^~>")
#   "abc   ")
# 
is $*fl.format(
	Q{~6@<abc~;def~^~>},
	Q{.}, Q{ABC}, Q{DEF}
), Q{abc   }, Q{format.justify.28};
)

# ;;; ~:; tests
# 
#`(
# (def-pprint-test format.justify.29
#   (format nil "~%X ~,,1<~%X ~:;AAA~;BBB~;CCC~>")
#   "
# X AAA BBB CCC")
# 
is $*fl.format(
	Q{~%X ~,,1<~%X ~:;AAA~;BBB~;CCC~>},
	Q{.}, Q{ABC}, Q{DEF}
), qq{\nX AAA BBB CCC}, Q{format.justify.29};
)

#`(
# (def-pprint-test format.justify.30
#   (format nil "~%X ~<~%X ~0,3:;AAA~>~<~%X ~0,3:;BBB~>~<~%X ~0,3:;CCC~>")
#   "
# X 
# X AAA
# X BBB
# X CCC")
# 
is $*fl.format(
	Q{~%X ~<~%X ~0,3:;AAA~>~<~%X ~0,3:;BBB~>~<~%X ~0,3:;CCC~>}
), qq{\nX \nX AAA\nX BBB\nX CCC}, Q{format.justify.30};
)

#`(
# (def-pprint-test format.justify.31
#   (format nil "~%X ~<~%X ~0,30:;AAA~>~<~%X ~0,30:;BBB~>~<~%X ~0,30:;CCC~>")
#   "
# X AAABBBCCC")
# 
is $*fl.format(
	Q{~%X ~<~%X ~0,30:;AAA~>~<~%X ~0,30:;BBB~>~<~%X ~0,30:;CCC~>}
), qq{\nX AAABBBCCC}, Q{format.justify.31};
)

#`(
# (def-pprint-test format.justify.32
#   (format nil "~%X ~<~%X ~0,3:;AAA~>,~<~%X ~0,3:;BBB~>,~<~%X ~0,3:;CCC~>")
#   "
# X 
# X AAA,
# X BBB,
# X CCC")
# 
is $*fl.format(
	Q{~%X ~<~%X ~0,3:;AAA~>,~<~%X ~0,3:;BBB~>,~<~%X ~0,3:;CCC~>}
), qq{\nX \nX AAA\nX BBB\nX CCC}, Q{format.justify.32};
)

# ;;; Error cases
# 
# ;;; See 22.3.5.2
# 
# ;;; Interaction with ~W
# 
#`(
# (deftest format.justify.error.w.1
#   (signals-error-always (format nil "~< ~W ~>" nil) error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~< ~W ~>}, Nil );
}, X::Error, Q{format.justify.error.w.1};
)

#`(
# (deftest format.justify.error.w.2
#   (signals-error-always (format nil "~<X~:;Y~>~W" nil) error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~<X~:;Y~>~W}, Nil );
}, X::Error, Q{format.justify.error.w.2};
)

#`(
# (deftest format.justify.error.w.3
#   (signals-error-always (format nil "~w~<X~:;Y~>" nil) error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~w~<X~:;Y~>}, Nil );
}, X::Error, Q{format.justify.error.w.3};
)

# ;;; Interaction with ~_
# 
#`(
# (deftest format.justify.error._.1
#   (signals-error-always (format nil "~< ~_ ~>") error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~< ~_ ~>} );
}, X::Error, Q{format.justify.error._.1};
)

#`(
# (deftest format.justify.error._.2
#   (signals-error-always (format nil "~<X~:;Y~>~_") error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~<X~:;Y~>~_} );
}, X::Error, Q{format.justify.error._.2};
)

#`(
# (deftest format.justify.error._.3
#   (signals-error-always (format nil "~_~<X~:;Y~>") error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~_~<X~:;Y~>} );
}, X::Error, Q{format.justify.error._.3};
)

# ;;; Interaction with ~I
# 
#`(
# (deftest format.justify.error.i.1
#   (signals-error-always (format nil "~< ~i ~>") error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~< ~i ~>} );
}, X::Error, Q{format.justify.error.i.1};
)

#`(
# (deftest format.justify.error.i.2
#   (signals-error-always (format nil "~<X~:;Y~>~I") error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~<X~:;Y~>~I} );
}, X::Error, Q{format.justify.error.i.2};
)

#`(
# (deftest format.justify.error.i.3
#   (signals-error-always (format nil "~i~<X~:;Y~>") error)
#   t t)
# 
throws-like {
	$*fl.format( Q{~i~<X~:;Y~>} );
}, X::Error, Q{format.justify.error.i.2};
)

done-testing;

# vim: ft=perl6
