use v6;

use Test;
use lib 't/lib';
use Utils;
use Format::Lisp;

my $*fl = Format::Lisp.new;

# (def-format-test format.paren.1
#   "~(XXyy~AuuVV~)" ("ABc dEF ghI") "xxyyabc def ghiuuvv")
# 
ok def-format-test(
	Q{~(XXyy~AuuVV~)}, ( Q{ABc dEF ghI} ), Q{xxyyabc def ghiuuvv}
), Q{format.paren.1};

subtest {
	#`(
	# (deftest format.paren.2
	#   (loop for i from 0 below (min char-code-limit (ash 1 16))
	#         for c = (code-char i)
	#         when (and c
	#                   (eql (char-code c) (char-int c))
	#                   (upper-case-p c)
	#                   (let ((s1 (format nil "~(~c~)" c))
	#                         (s2 (string (char-downcase c))))
	#                     (if
	#                         (or (not (eql (length s1) 1))
	#                             (not (eql (length s2) 1))
	#                             (not (eql (elt s1 0)
	#                                       (elt s2 0))))
	#                         (list i c s1 s2)
	#                       nil)))
	#         collect it)
	#   nil)
	# 
	ok deftest( {
		my @collected;
		my $fn = $*fl.formatter( Q{~#B} );
		my $bv = 0b11001;
		for 0 .. 10 -> $i {
	#		my @args = 
	##		my $s = $*fl.format( Q{~v,,2A}, $i, Q{ABC} );
	#		my $s2 = formatter-call-to-string( $fn, $i, Q{ABC} );
	#		is $s, $s2;
	#		@collected.append( $s );
		}
		@collected.elems;
	}, [ ]
	), Q{format.paren.2};
	)

	#`(
	# (deftest formatter.paren.2
	#   (let ((fn (formatter "~(~c~)")))
	#     (loop for i from 0 below (min char-code-limit (ash 1 16))
	#           for c = (code-char i)
	#           when (and c
	#                     (eql (char-code c) (char-int c))
	#                     (upper-case-p c)
	#                     (let ((s1 (formatter-call-to-string fn c))
	#                           (s2 (string (char-downcase c))))
	#                       (if
	#                           (or (not (eql (length s1) 1))
	#                               (not (eql (length s2) 1))
	#                               (not (eql (elt s1 0)
	#                                         (elt s2 0))))
	#                           (list i c s1 s2)
	#                         nil)))
	#           collect it))
	#   nil)
	# 
	ok deftest( {
		my @collected;
		my $fn = $*fl.formatter( Q{~(~c~)} );
		my $bv = 0b11001;
		for 0 .. 10 -> $i {
	#		my @args = 
	#		is $s, $s2;
	#		@collected.append( $s );
		}
		@collected;
	}, [ ]
	), Q{formatter.paren.2};
	)

	# (def-format-test format.paren.3
	#   "~@(this is a TEST.~)" nil "This is a test.")
	# 
	ok def-format-test(
		Q{~@(this is a TEST.~)}, Nil, Q{This is a test.}
	), Q{format.paren.2};

	#`(
	# (def-format-test format.paren.4
	#   "~@(!@#$%^&*this is a TEST.~)" nil "!@#$%^&*This is a test.")
	# 
	ok def-format-test(
		Q{~@(!@#$%^&*this is a TEST.~)},
		Nil,
		Q{!@#$%^&*This is a test.}
	), Q{format.paren.4};
	)

	#`(
	# (def-format-test format.paren.5
	#   "~:(this is a TEST.~)" nil "This Is A Test.")
	# 
	ok def-format-test(
		Q{~:(this is a TEST.~)}, Nil, Q{This Is A Test.}
	), Q{format.paren.5};
	)

	#`(
	# (def-format-test format.paren.6
	#   "~:(this is7a TEST.~)" nil "This Is7a Test.")
	# 
	ok def-format-test(
		Q{~:(this is7a TEST.~)}, Nil, Q{This Is7a Test.}
	), Q{format.paren.6};
	)

	# (def-format-test format.paren.7
	#   "~:@(this is AlSo A teSt~)" nil "THIS IS ALSO A TEST")
	# 
	ok def-format-test(
		Q{~:@(this is AlSo A teSt~)}, Nil, Q{THIS IS ALSO A TEST}
	), Q{format.paren.7};

	#`(
	# (deftest format.paren.8
	#   (loop for i from 0 below (min char-code-limit (ash 1 16))
	#         for c = (code-char i)
	#         when (and c
	#                   (eql (char-code c) (char-int c))
	#                   (lower-case-p c)
	#                   (let ((s1 (format nil "~@:(~c~)" c))
	#                         (s2 (string (char-upcase c))))
	#                     (if
	#                         (or (not (eql (length s1) 1))
	#                             (not (eql (length s2) 1))
	#                             (not (eql (elt s1 0)
	#                                       (elt s2 0))))
	#                         (list i c s1 s2)
	#                       nil)))
	#         collect it)
	#   nil)
	# 
	ok deftest( {
		my @collected;
		my $fn = $*fl.formatter( Q{~#B} );
		my $bv = 0b11001;
		for 0 .. 10 -> $i {
	#		my @args = 
	#		is $s, $s2;
	#		@collected.append( $s );
		}
		@collected;
	}, [ ]
	), Q{format.paren.8};
	)

	#`(
	# (deftest formatter.paren.8
	#   (let ((fn (formatter "~@:(~c~)")))
	#     (loop for i from 0 below (min char-code-limit (ash 1 16))
	#           for c = (code-char i)
	#           when (and c
	#                     (eql (char-code c) (char-int c))
	#                     (lower-case-p c)
	#                     (let ((s1 (formatter-call-to-string fn c))
	#                           (s2 (string (char-upcase c))))
	#                       (if
	#                           (or (not (eql (length s1) 1))
	#                               (not (eql (length s2) 1))
	#                               (not (eql (elt s1 0)
	#                                         (elt s2 0))))
	#                           (list i c s1 s2)
	#                         nil)))
	#           collect it))
	#   nil)
	# 
	ok deftest( {
		my @collected;
		my $fn = $*fl.formatter( Q{~@(~c~)} );
		my $bv = 0b11001;
		for 0 .. 10 -> $i {
	#		my @args = 
	#		is $s, $s2;
	#		@collected.append( $s );
		}
		@collected;
	}, [ ]
	), Q{formatter.paren.8};
	)
}, Q{Conversion of simple characters to downcase};

subtest {
	# (def-format-test format.paren.9
	#   "~(aBc ~:(def~) GHi~)" nil "abc def ghi")
	# 
	ok def-format-test(
		Q{~(aBc ~:(def~) GHi~)}, Nil, Q{abc def ghi}
	), Q{format.paren.9};

	# (def-format-test format.paren.10
	#   "~(aBc ~(def~) GHi~)" nil "abc def ghi")
	# 
	ok def-format-test(
		Q{~(aBc ~(def~) GHi~)}, Nil, Q{abc def ghi}
	), Q{format.paren.10};

	# (def-format-test format.paren.11
	#   "~@(aBc ~:(def~) GHi~)" nil "Abc def ghi")
	# 
	ok def-format-test(
		Q{~@(aBc ~:(def~) GHi~)}, Nil, Q{Abc def ghi}
	), Q{format.paren.11};

	# (def-format-test format.paren.12
	#   "~(aBc ~@(def~) GHi~)" nil "abc def ghi")
	# 
	ok def-format-test(
		Q{~(aBc ~@(def~) GHi~)}, Nil, Q{abc def ghi}
	), Q{format.paren.12};

	# (def-format-test format.paren.13
	#   "~(aBc ~:(def~) GHi~)" nil "abc def ghi")
	# 
	ok def-format-test(
		Q{~(aBc ~:(def~) GHi~)}, Nil, Q{abc def ghi}
	), Q{format.paren.13};

	#`(
	# (def-format-test format.paren.14
	#   "~:(aBc ~(def~) GHi~)" nil "Abc Def Ghi")
	# 
	ok def-format-test(
		Q{~:(aBc ~(def~) GHi~)}, Nil, Q{Abc Def Ghi}
	), Q{format.paren.14};
	)

	#`(
	# (def-format-test format.paren.15
	#   "~:(aBc ~:(def~) GHi~)" nil "Abc Def Ghi")
	# 
	ok def-format-test(
		Q{~:(aBc ~:(def~) GHi~)}, Nil, Q{Abc Def Ghi}
	), Q{format.paren.15};
	)

	#`(
	# (def-format-test format.paren.16
	#   "~:(aBc ~@(def~) GHi~)" nil "Abc Def Ghi")
	# 
	ok def-format-test(
		Q{~:(aBc ~@(def~) GHi~)}, Nil, Q{Abc Def Ghi}
	), Q{format.paren.16};
	)

	#`(
	# (def-format-test format.paren.17
	#   "~:(aBc ~@:(def~) GHi~)" nil "Abc Def Ghi")
	# 
	ok def-format-test(
		Q{~:(aBc ~@:(def~) GHi~)}, Nil, Q{Abc Def Ghi}
	), Q{format.paren.17};
	)

	# (def-format-test format.paren.18
	#   "~@(aBc ~(def~) GHi~)" nil "Abc def ghi")
	# 
	ok def-format-test(
		Q{~@(aBc ~(def~) GHi~)}, Nil, Q{Abc def ghi}
	), Q{format.paren.18};

	# (def-format-test format.paren.19
	#   "~@(aBc ~:(def~) GHi~)" nil "Abc def ghi")
	# 
	ok def-format-test(
		Q{~@(aBc ~:(def~) GHi~)}, Nil, Q{Abc def ghi}
	), Q{format.paren.19};

	# (def-format-test format.paren.20
	#   "~@(aBc ~@(def~) GHi~)" nil "Abc def ghi")
	# 
	ok def-format-test(
		Q{~@(aBc ~@(def~) GHi~)}, Nil, Q{Abc def ghi}
	), Q{format.paren.20};

	#`(
	# (def-format-test format.paren.21
	#   "~@(aBc ~@:(def~) GHi~)" nil "Abc def ghi")
	# 
	ok def-format-test(
		Q{~@(aBc ~@:(def~) GHi~)}, Nil, Q{Abc def ghi}
	), Q{format.paren.21};
	)

	# (def-format-test format.paren.22
	#   "~:@(aBc ~(def~) GHi~)" nil "ABC DEF GHI")
	# 
	ok def-format-test(
		Q{~:@(aBc ~(def~) GHi~)}, Nil, Q{ABC DEF GHI}
	), Q{format.paren.22};

	#`(
	# (def-format-test format.paren.23
	#   "~@:(aBc ~:(def~) GHi~)" nil "ABC DEF GHI")
	# 
	ok def-format-test(
		Q{~@:(aBc ~:(def~) GHi~)}, Nil, Q{ABC DEF GHI}
	), Q{format.paren.23};
	)

	# (def-format-test format.paren.24
	#   "~:@(aBc ~@(def~) GHi~)" nil "ABC DEF GHI")
	# 
	ok def-format-test(
		Q{~:@(aBc ~@(def~) GHi~)}, Nil, Q{ABC DEF GHI}
	), Q{format.paren.24};

	# (def-format-test format.paren.25
	#   "~@:(aBc ~@:(def~) GHi~)" nil "ABC DEF GHI")
	# 
	ok def-format-test(
		Q{~@:(aBc ~@(def~) GHi~)}, Nil, Q{ABC DEF GHI}
	), Q{format.paren.25};
}, Q{Nested conversion};

done-testing;

# vim: ft=perl6
