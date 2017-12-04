use v6;

use Test;
use lib 't/lib';
use Utils;
use Format::Lisp;

my $*fl = Format::Lisp.new;

subtest {
	is $*fl.format( Q{~~~dR}, 27 ), Q{~27R}, Q{format.r.1};

#`(
	is $*fl.format( Q{~~~D,~DR}, 27, 42 ), Q{~27,42}, Q{format.r.4};
)
}, Q{missing coverage};

#`(
# (deftest format.r.1
#   (loop
#    for i from 2 to 36
#    for s = (format nil "~~~dR" i)
#    nconc
#    (loop for x = (let ((bound (ash 1 (+ 2 (random 40)))))
#                    (- (random (* bound 2)) bound))
#          for s1 = (format nil s x)
#          for s2 = (with-standard-io-syntax
#                    (write-to-string x :base i :readably nil))
#          repeat 100
#          unless (string= s1 s2)
#          collect (list i x s1 s2)))
#   nil)
# 
ok deftest( {
	my @collected;
	for 0 .. 10 -> $i {
#		my @args = 
#		is $s, $s2;
#		@collected.append( $s );
	}
	@collected;
}, [ ]
), Q{format.r.1};
)

#`(
# (deftest formatter.r.1
#   (loop
#    for i from 2 to 36
#    for s = (format nil "~~~dR" i)
#    for fn = (eval `(formatter ,s))
#    nconc
#    (loop for x = (let ((bound (ash 1 (+ 2 (random 40)))))
#                    (- (random (* bound 2)) bound))
#          for s1 = (formatter-call-to-string fn x)
#          for s2 = (with-standard-io-syntax
#                    (write-to-string x :base i :readably nil))
#          repeat 100
#          unless (string= s1 s2)
#          collect (list i x s1 s2)))
#   nil)
# 
ok deftest( {
	my @collected;
	for 0 .. 10 -> $i {
#		my @args = 
#		is $s, $s2;
#		@collected.append( $s );
	}
	@collected;
}, [ ]
), Q{formatter.r.1};
)

# (def-format-test format.r.2
#   "~2r" (14) "1110")
# 
ok def-format-test( Q{~2r}, ( 14 ), Q{1110} ), Q{format.r.2};

# (def-format-test format.r.3
#   "~3r" (29) "1002")
# 
ok def-format-test( Q{~3r}, ( 29 ), Q{1002} ), Q{format.r.3};

#`(
# (deftest format.r.4
#   (loop for base from 2 to 36
#         nconc
#         (loop for mincol from 0 to 20
#               for fmt = (format nil "~~~D,~DR" base mincol)
#               for s = (format nil fmt base)
#               unless (if (<= mincol 2)
#                          (string= s "10")
#                        (string= (concatenate
#                                  'string
#                                  (make-string (- mincol 2)
#                                               :initial-element #\Space)
#                                  "10")
#                                 s))
#               collect (list base mincol s)))
#   nil)
# 
ok deftest( {
	my @collected;
	for 0 .. 10 -> $i {
#		my @args = 
#		is $s, $s2;
#		@collected.append( $s );
	}
	@collected;
}, [ ]
), Q{format.r.4};
)

#`(
# (deftest formatter.r.4
#   (loop for base from 2 to 36
#         nconc
#         (loop for mincol from 0 to 20
#               for fmt = (format nil "~~~D,~DR" base mincol)
#               for fn = (eval `(formatter ,fmt))
#               for s = (formatter-call-to-string fn base)
#               unless (if (<= mincol 2)
#                          (string= s "10")
#                        (string= (concatenate
#                                  'string
#                                  (make-string (- mincol 2)
#                                               :initial-element #\Space)
#                                  "10")
#                                 s))
#               collect (list base mincol s)))
#   nil)
# 
ok deftest( {
	my @collected;
	for 0 .. 10 -> $i {
#		my @args = 
#		is $s, $s2;
#		@collected.append( $s );
	}
	@collected;
}, [ ]
), Q{formatter.r.4};
)

#`(
# (deftest format.r.5
#   (loop for base from 2 to 36
#         nconc
#         (loop for mincol from 0 to 20
#               for fmt = (format nil "~~~D,~D,'*r" base mincol)
#               for s = (format nil fmt base)
#               unless (if (<= mincol 2)
#                          (string= s "10")
#                        (string= (concatenate
#                                  'string
#                                  (make-string (- mincol 2)
#                                               :initial-element #\*)
#                                  "10")
#                                 s))
#               collect (list base mincol s)))
#   nil)
# 
ok deftest( {
	my @collected;
	for 0 .. 10 -> $i {
#		my @args = 
#		is $s, $s2;
#		@collected.append( $s );
	}
	@collected;
}, [ ]
), Q{format.r.5};
)

#`(
# (deftest formatter.r.5
#   (loop for base from 2 to 36
#         nconc
#         (loop for mincol from 0 to 20
#               for fmt = (format nil "~~~D,~D,'*r" base mincol)
#               for fn = (eval `(formatter ,fmt))
#               for s = (formatter-call-to-string fn base)
#               unless (if (<= mincol 2)
#                          (string= s "10")
#                        (string= (concatenate
#                                  'string
#                                  (make-string (- mincol 2)
#                                               :initial-element #\*)
#                                  "10")
#                                 s))
#               collect (list base mincol s)))
#   nil)
# 
ok deftest( {
	my @collected;
	for 0 .. 10 -> $i {
#		my @args = 
#		is $s, $s2;
#		@collected.append( $s );
	}
	@collected;
}, [ ]
), Q{formatter.r.5};
)

#`(
# (deftest format.r.6
#   (loop for base from 2 to 36
#         for s = (format nil "~vr" base (1+ base))
#         unless (string= s "11")
#         collect (list base s))
#   nil)
# 
ok deftest( {
	my @collected;
	for 2 .. 36 -> $i {
#		my @args = 
#		is $s, $s2;
#		@collected.append( $s );
	}
	@collected;
}, [ ]
), Q{format.r.6};
)

#`(
# (deftest formatter.r.6
#   (let ((fn (formatter "~vr")))
#     (loop for base from 2 to 36
#           for s = (formatter-call-to-string fn base (1+ base))
#           unless (string= s "11")
#           collect (list base s)))
#   nil)
# 
ok deftest( {
	my $fn = $*fl.formatter( Q{~#B} );
	my @collected;
	for 0 .. 10 -> $i {
#		my @args = 
#		is $s, $s2;
#		@collected.append( $s );
	}
	@collected;
}, [ ]
), Q{formatter.r.6};
)

#`(
# (deftest format.r.7
#   (loop for i from 0 to 100
#         for s1 = (format nil "~r" i)
#         for s2 in *english-number-names*
#         unless (string= s1 s2)
#         collect (list i s1 s2))
#   nil)
# 
ok deftest( {
	my @collected;
	for 0 .. 100 -> $i {
#		my @args = 
#		is $s, $s2;
#		@collected.append( $s );
	}
	@collected;
}, [ ]
), Q{format.r.7};
)

#`(
# (deftest formatter.r.7
#   (let ((fn (formatter "~r")))
#     (loop for i from 0 to 100
#           for s1 = (formatter-call-to-string fn i)
#           for s2 in *english-number-names*
#           unless (string= s1 s2)
#           collect (list i s1 s2)))
#   nil)
# 
ok deftest( {
	my $fn = $*fl.formatter( Q{~#B} );
	my @collected;
	for 0 .. 10 -> $i {
#		my @args = 
#		is $s, $s2;
#		@collected.append( $s );
	}
	@collected;
}, [ ]
), Q{formatter.r.7};
)

#`(
# (deftest format.r.7a
#   (loop for i from 1 to 100
#         for s1 = (format nil "~r" (- i))
#         for s2 in (cdr *english-number-names*)
#         for s3 = (concatenate 'string "negative " s2)
#         for s4 = (concatenate 'string "minus " s2)
#         unless (or (string= s1 s3) (string= s1 s4))
#         collect (list i s1 s3 s4))
#   nil)
# 
ok deftest( {
	my @collected;
	for 0 .. 100 -> $i {
#		my @args = 
#		is $s, $s2;
#		@collected.append( $s );
	}
	@collected;
}, [ ]
), Q{format.r.7a};
)

#`(
# (def-format-test format.r.8
#   "~vr" (nil 5) "five")
# 
ok def-format-test( Q{~vr}, ( Nil, 5 ), Q{five} ), Q{format.r.8};
)

# (def-format-test format.r.9
#   "~#r" (4 nil nil) "11" 2)
# 
ok def-format-test( Q{~#r}, ( 4, Nil, Nil ), Q{11}, 2 ), Q{format.r.9};

# (deftest format.r.10
#   (with-standard-io-syntax
#    (let ((*print-radix* t))
#      (format nil "~10r" 123)))
#   "123")
# 
ok deftest( {
	my $*PRINT-RADIX = True;
	$*fl.format( Q{~10r}, 123 );
}, Q{123}
), Q{format.r.10};

#`(
# (deftest formatter.r.10
#   (let ((fn (formatter "~10r")))
#     (with-standard-io-syntax
#      (let ((*print-radix* t))
#        (values
#         (format nil fn 123)
#         (formatter-call-to-string fn 123)))))
#   "123"
#   "123")
# 
ok deftest( {
	my $*PRINT-RADIX = True;
	$*fl.format( Q{~10r}, 123 );
}, Q{123}
), Q{formatter.r.10};
)

# (def-format-test format.r.11
#   "~8@R" (65) "+101")
# 
ok def-format-test( Q{~8@R}, ( 65 ), Q{+101} ), Q{format.r.11};

#`(
# (def-format-test format.r.12
#   "~2:r" (126) "1,111,110")
# 
ok def-format-test( Q{~2:r}, ( 126 ), Q{1,111,110} ), Q{format.r.12};
)

#`(
# (def-format-test format.r.13
#   "~3@:r" (#3r2120012102) "+2,120,012,102")
# 
ok def-format-test(
	Q{~3@:r}, ( :3(2120012102) ), Q{+2,120,012,102}
), Q{format.r.13};
)

#`(
# (deftest format.r.14
#   (loop
#    for i from 2 to 36
#    for s = (format nil "~~~d:R" i)
#    nconc
#    (loop for x = (let ((bound (ash 1 (+ 2 (random 40)))))
#                    (- (random (* bound 2)) bound))
#          for s1 = (remove #\, (format nil s x))
#          for y = (let ((*read-base* i)) (read-from-string s1))
#          repeat 100
#          unless (= x y)
#          collect (list i x s1 y)))
#   nil)
# 
ok deftest( {
	my @collected;
	for 0 .. 10 -> $i {
#		my @args = 
#		is $s, $s2;
#		@collected.append( $s );
	}
	@collected;
}, [ ]
), Q{format.r.14};
)

#`(
# (deftest format.r.15
#   (loop
#    for i = (+ 2 (random 35))
#    for interval = (1+ (random 20))
#    for comma = (loop for c = (random-from-seq +standard-chars+)
#                      unless (alphanumericp c)
#                      return c)
#    for s = (format nil "~~~d,,,'~c,~d:R" i comma interval)
#    for x = (let ((bound (ash 1 (+ 2 (random 40)))))
#              (- (random (* bound 2)) bound))
#    for s1 = (remove comma (format nil s x))
#    for y = (let ((*read-base* i)) (read-from-string s1))
#    repeat 1000
#    unless (or (and (eql comma #\-) (< x 0))
#               (= x y))
#    collect (list i interval comma x s1 y))
#   nil)
# 
ok deftest( {
	my @collected;
	for 0 .. 10 -> $i {
#		my @args = 
#		is $s, $s2;
#		@collected.append( $s );
	}
	@collected;
}, [ ]
), Q{format.r.15};
)

# (def-format-test format.r.16
#   "~2,,,,1000000000000000000r" (17) "10001")
# 
ok def-format-test(
	Q{~2,,,,1000000000000000000r}, ( 17 ), Q{10001}
), Q{format.r.16};

#`(
# (def-format-test format.r.17
#   "~8,10:@r" (#o526104) "  +526,104")
# 
ok def-format-test( Q{8,10:@r}, ( 0o526104), Q{+526,104} ), Q{format.r.17};
)

#`(
# (deftest format.r.18
#   (loop for i from 0 to 100
#         for s1 = (format nil "~:r" i)
#         for s2 in *english-ordinal-names*
#         unless (string= s1 s2)
#         collect (list i s1 s2))
#   nil)
# 
ok deftest( {
	my @collected;
	for 0 .. 100 -> $i {
#		my @args = 
#		is $s, $s2;
#		@collected.append( $s );
	}
	@collected;
}, [ ]
), Q{format.r.18};
)

#`(
# (deftest formatter.r.18
#   (let ((fn (formatter "~:r")))
#     (loop for i from 0 to 100
#           for s1 = (formatter-call-to-string fn i)
#           for s2 in *english-ordinal-names*
#           unless (string= s1 s2)
#           collect (list i s1 s2)))
#   nil)
# 
ok deftest( {
	my @collected;
	for 0 .. 10 -> $i {
#		my @args = 
#		is $s, $s2;
#		@collected.append( $s );
	}
	@collected;
}, [ ]
), Q{formatter.r.18};
)

#`(
# (deftest format.r.18a
#   (loop for i from 1 to 100
#         for s1 = (format nil "~:r" (- i))
#         for s2 in (cdr *english-ordinal-names*)
#         for s3 = (concatenate 'string "negative " s2)
#         for s4 = (concatenate 'string "minus " s2)
#         unless (or (string= s1 s3) (string= s1 s4))
#         collect (list i s1 s3 s4))
#   nil)
# 
ok deftest( {
	my @collected;
	for 0 .. 10 -> $i {
#		my @args = 
#		is $s, $s2;
#		@collected.append( $s );
	}
	@collected;
}, [ ]
), Q{format.r.18};
)

#`(
# (deftest format.r.19
#   (loop for i from 1
#         for s1 in *roman-numerals*
#         for s2 = (format nil "~@R" i)
#         unless (string= s1 s2)
#         collect (list i s1 s2))
#   nil)
# 
ok deftest( {
	my @collected;
	for 0 .. 10 -> $i {
#		my @args = 
#		is $s, $s2;
#		@collected.append( $s );
	}
	@collected;
}, [ ]
), Q{format.r.19};
)

#`(
# (deftest formatter.r.19
#   (let ((fn (formatter "~@r")))
#     (loop for i from 1
#           for s1 in *roman-numerals*
#           for s2 = (formatter-call-to-string fn i)
#           unless (string= s1 s2)
#           collect (list i s1 s2)))
#   nil)
# 
ok deftest( {
	my @collected;
	for 0 .. 10 -> $i {
#		my @args = 
#		is $s, $s2;
#		@collected.append( $s );
	}
	@collected;
}, [ ]
), Q{formatter.r.19};
)

subtest {
	1;
	#`(
	# (defun old-roman-numeral (x)
	#   (assert (typep x '(integer 1)))
	#   (let ((n-m 0)
	#         (n-d 0)
	#         (n-c 0)
	#         (n-l 0)
	#         (n-x 0)
	#         (n-v 0)
	#         )
	#     (loop while (>= x 1000) do (incf n-m) (decf x 1000))
	#     (when (>= x 500) (incf n-d) (decf x 500))
	#     (loop while (>= x 100) do (incf n-c) (decf x 100))
	#     (when (>= x 50) (incf n-l) (decf x 50))
	#     (loop while (>= x 10) do (incf n-x) (decf x 10))
	#     (when (>= x 5) (incf n-v) (decf x 5))
	#     (concatenate 'string
	#                  (make-string n-m :initial-element #\M)
	#                  (make-string n-d :initial-element #\D)
	#                  (make-string n-c :initial-element #\C)
	#                  (make-string n-l :initial-element #\L)
	#                  (make-string n-x :initial-element #\X)
	#                  (make-string n-v :initial-element #\V)
	#                  (make-string x   :initial-element #\I))))
	# 
	)

	#`(
	# (deftest format.r.20
	#   (loop for i from 1 to 4999
	#         for s1 = (format nil "~:@r" i)
	#         for s2 = (old-roman-numeral i)
	#         unless (string= s1 s2)
	#         collect (list i s1 s2))
	#   nil)
	# 
	ok deftest( {
		my @collected;
		for 1 .. 4999 -> $i {
	#		my @args = 
	#		is $s, $s2;
	#		@collected.append( $s );
		}
		@collected;
	}, [ ]
	), Q{format.r.20};
	)

	#`(
	# (deftest formatter.r.20
	#   (let ((fn (formatter "~@:R")))
	#     (loop for i from 1 to 4999
	#           for s1 = (formatter-call-to-string fn i)
	#           for s2 = (old-roman-numeral i)
	#           unless (string= s1 s2)
	#           collect (list i s1 s2)))
	#   nil)
	# 
	ok deftest( {
		my @collected;
		for 0 .. 10 -> $i {
	#		my @args = 
	#		is $s, $s2;
	#		@collected.append( $s );
		}
		@collected;
	}, [ ]
	), Q{formatter.r.20};
	)

	#`(
	# (deftest format.r.21
	#   (loop for i from 1 to 4999
	#         for s1 = (format nil "~:@r" i)
	#         for s2 = (format nil "~@:R" i)
	#         unless (string= s1 s2)
	#         collect (list i s1 s2))
	#   nil)
	# 
	ok deftest( {
		my @collected;
		for 0 .. 10 -> $i {
	#		my @args = 
	#		is $s, $s2;
	#		@collected.append( $s );
		}
		@collected;
	}, [ ]
	), Q{format.r.21};
	)
}, Q{Old roman numerals};

subtest {
	#`(
	# (def-format-test format.r.22
	#   "~2,12,,'*:r" (#b1011101) "   1*011*101")
	# 
	ok def-format-test(
		Q{~2,12,,'*:r}, ( 0b101*101 ), Q{1*011*101}
	), Q{format.r.22};
	)

	#`(
	# (def-format-test format.r.23
	#   "~3,14,'X,',:R" (#3r1021101) "XXXXX1,021,101")
	# 
	ok def-format-test(
		Q{~3,14,'X,',:R}, ( :3(1021101) ), Q{XXXXX1,021,101}
	), Q{format.r.23};
	)

	# ;; v directive in various positions
	# 
	# (def-format-test format.r.24
	#   "~10,vr" (nil 12345) "12345")
	# 
	ok def-format-test(
		Q{~10,vr}, ( Nil, 12345 ), Q{12345}
	), Q{format.r.24};

	#`(
	# (deftest format.r.25
	#   (loop for i from 0 to 5
	#         for s = (format nil "~10,vr" i 12345)
	#         unless (string= s "12345")
	#         collect (list i s))
	#   nil)
	# 
	ok deftest( {
		my @collected;
		for 0 .. 5 -> $i {
	#		my @args = 
	#		is $s, $s2;
	#		@collected.append( $s );
		}
		@collected;
	}, [ ]
	), Q{format.r.25};
	)

	#`(
	# (deftest formatter.r.25
	#   (let ((fn (formatter "~10,vr")))
	#     (loop for i from 0 to 5
	#           for s = (formatter-call-to-string fn i 12345)
	#           unless (string= s "12345")
	#           collect (list i s)))
	#   nil)
	# 
	ok deftest( {
		my @collected;
		for 0 .. 10 -> $i {
	#		my @args = 
	#		is $s, $s2;
	#		@collected.append( $s );
		}
		@collected;
	}, [ ]
	), Q{formatter.r.25};
	)

	# (def-format-test format.r.26
	#   "~10,#r" (12345 nil nil nil nil nil) " 12345" 5)
	# 
	ok def-format-test(
		Q{~10,#r}, ( 12345, Nil, Nil, Nil, Nil, Nil ), Q{ 12345}, 5
	), Q{format.r.26};

	#`(
	# (def-format-test format.r.27
	#   "~10,12,vr" (#\/ 123456789) "///123456789")
	# 
	ok def-format-test(
		Q{~10,12vr}, ( Q{/}, 123456789 ), Q{///123456789}
	), Q{format.r.27};
	)

	#`(
	# (def-format-test format.r.28
	#   "~10,,,v:r" (#\/ 123456789) "123/456/789")
	# 
	ok def-format-test(
		Q{~10,,,v:r}, ( Q{/}, 123456789 ), Q{123/456/789}
	), Q{format.r.28};
	)

	#`(
	# (def-format-test format.r.29
	#   "~10,,,v:r" (nil 123456789) "123,456,789")
	# 
	ok def-format-test(
		Q{~10,,,v:r}, ( Nil, 123456789 ), Q{123,456,789}
	), Q{format.r.29};
	)

	#`(
	# (def-format-test format.r.30
	#   "~8,,,,v:R" (nil #o12345670) "12,345,670")
	# 
	ok def-format-test(
		Q{~8,,,,v:R}, ( Nil, 0o12345670 ), Q{12,345,670}
	), Q{format.r.30};
	)

	#`(
	# (def-format-test format.r.31
	#   "~8,,,,v:R" (2 #o12345670) "12,34,56,70")
	# 
	ok def-format-test(
		Q{~8,,,,v:R}, ( 2, 0o12345670 ), Q{12,345,670}
	), Q{format.r.31};
	)

	#`(
	# (def-format-test format.r.32
	#   "~16,,,,#:r" (#x12345670 nil nil nil) "1234,5670" 3)
	# 
	ok def-format-test(
		Q{~16,,,,#:r}, ( 0x12345670, Nil, Nil, Nil ), Q{1234,5670}, 3
	), Q{format.r.32};
	)

	# (def-format-test format.r.33
	#   "~16,,,,1:r" (#x12345670) "1,2,3,4,5,6,7,0")
	# 
	ok def-format-test(
		Q{~16,,,,1:r}, ( 0x12345670 ), Q{1,2,3,4,5,6,7,0}
	), Q{format.r.33};
}, Q{Combinations of mincol and comma chars};

subtest {
	# (def-format-test format.r.34
	#   "~+10r" (12345) "12345")
	# 
	ok def-format-test( Q{~+10r}, ( 12345 ), Q{12345} ), Q{format.r.34};

	# (def-format-test format.r.35
	#   "~10,+8r" (12345) "   12345")
	# 
	ok def-format-test(
		Q{~10,+8r}, ( 12345 ), Q{   12345}
	), Q{format.r.35};

	# (def-format-test format.r.36
	#   "~10,0r" (12345) "12345")
	# 
	ok def-format-test( Q{~10,+0r}, ( 12345 ), Q{12345} ), Q{format.r.36};

	# (def-format-test format.r.37
	#   "~10,-1r" (12345) "12345")
	# 
	ok def-format-test( Q{~10,-1r}, ( 12345 ), Q{12345} ), Q{format.r.37};

	# (def-format-test format.r.38
	#   "~10,-1000000000000000r" (12345) "12345")
	# 
	ok def-format-test(
		Q{~10,-1000000000000000r}, ( 12345 ), Q{12345}
	), Q{format.r.38};
}, Q{Explicit signs};

# ;;; Randomized test
# 
#`(
# (deftest format.r.39
#   (let ((fn (formatter "~v,v,v,v,vr")))
#     (loop
#      for radix = (+ 2 (random 35))
#      for mincol = (and (coin) (random 50))
#      for padchar = (and (coin)
#                         (random-from-seq +standard-chars+))
#      for commachar = (and (coin)
#                           (random-from-seq +standard-chars+))
#      for commaint = (and (coin) (1+ (random 10)))
#      for k = (ash 1 (+ 2 (random 30)))
#      for x = (- (random (+ k k)) k)
#      for fmt = (concatenate
#                 'string
#                 (format nil "~~~d," radix)
#                 (if mincol (format nil "~d," mincol) ",")
#                 (if padchar (format nil "'~c," padchar) ",")
#                 (if commachar (format nil "'~c," commachar) ",")
#                 (if commaint (format nil "~dr" commaint) "r"))
#      for s1 = (format nil fmt x)
#      for s2 = (format nil "~v,v,v,v,vr" radix mincol padchar commachar commaint x)
#      for s3 = (formatter-call-to-string fn radix mincol padchar commachar commaint x)
#      repeat 2000
#      unless (and (string= s1 s2)
#                  (string= s1 s3))
#      collect (list radix mincol padchar commachar commaint fmt x s1 s2 s3)))
#   nil)
# 
ok deftest( {
	my @collected;
	for 0 .. 10 -> $i {
#		my @args = 
#		is $s, $s2;
#		@collected.append( $s );
	}
	@collected;
}, [ ]
), Q{format.0.39};
)

done-testing;

# vim: ft=perl6
