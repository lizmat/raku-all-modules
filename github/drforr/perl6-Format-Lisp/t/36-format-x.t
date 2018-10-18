use v6;

use Test;
use lib 't/lib';
use Utils;
use Format::Lisp;

my $*fl = Format::Lisp.new;

subtest {
	is $*fl.format( Q{~x}, 0xa ), Q{a}, Q{format.x.1.slice};

#`(
	is $*fl.format( Q{~@x}, 0xa ), Q{+a}, Q{format.x.2.slice};
)

	is $*fl.format( Q{~1,'xx}, 0xa ), Q{a}, Q{format.x.5.slice};

#`(
	is $*fl.format( Q{~v,Vx}, 0xa ), Q{a}, Q{format.x.6.slice};
)

#`(
	is $*fl.format( Q{~v,V@x}, 7 ), Q{7}, Q{format.x.7.slice};
)

	is $*fl.format( Q{~:X}, 0x7654 ), Q{7,654}, Q{format.x.8.slice};

#`(
	is $*fl.format( Q{~,,v:x}, 0x7654 ), Q{7,654}, Q{format.x.10.slice};
)

	is $*fl.format( Q{~,,'x:x}, 0x7654 ), Q{7x654}, Q{format.x.11.slice};

#`(
	is $*fl.format( Q{~,,V,v:X}, 0x7654 ), Q{7,654}, Q{format.x.12.slice};
)

#`(
	is $*fl.format( Q{~,,V,v@X}, 0x7654 ), Q{7,654}, Q{format.x.13.slice};
)
}, Q{missing coverage};

#`(
# (deftest format.x.1
#   (let ((fn (formatter "~x")))
#     (with-standard-io-syntax
#      (loop for x = (ash 1 (+ 2 (random 80)))
#            for i = (- (random (+ x x)) x)
#            for s1 = (format nil "~X" i)
#            for s2 = (formatter-call-to-string fn i)
#            for j = (let ((*read-base* 16)) (read-from-string s1))
#            repeat 1000
#            when (or (/= i j)
#                     (not (string= s1 s2))
#                     (find #\. s1)
#                     (find #\+ s1)
#                     (loop for c across s1
#                           thereis (and (not (eql c #\-))
#                                        (not (digit-char-p c 16)))))
#            collect (list i s1 j s2))))
#   nil)
# 
ok deftest( {
	my $fn = $*fl.formatter( Q{~x} );
	for 1 .. 1000 {
#		my $x = 2 ** ( 2 + 80.rand.Int );
#		my $i = ( ( $x + $x ).rand - $x );
#		my $s1 = $*fl.format( Q{~B}, $i );
#		my $s2 = formatter-call-to-string( $fn, $i );
#		# XXX convert $s1 to base-10
	}
}, [ ]
), Q{format.x.1};
)

#`(
# (deftest format.x.2
#   (let ((fn (formatter "~@X")))
#     (with-standard-io-syntax
#      (loop for x = (ash 1 (+ 2 (random 80)))
#            for i = (- (random (+ x x)) x)
#            for s1 = (format nil "~@x" i)
#            for s2 = (formatter-call-to-string fn i)
#            for j = (let ((*read-base* 16)) (read-from-string s1))
#            repeat 1000
#            when (or (/= i j)
#                     (not (string= s1 s2))
#                     (find #\. s1)
#                     ;; (find #\+ s1)
#                     (loop for c across s1
#                           thereis (and
#                                    (not (find c "-+"))
#                                    (not (digit-char-p c 16)))))
#            collect (list i s1 j s2))))
#   nil)
# 
ok deftest( {
	my $fn = $*fl.formatter( Q{~@X} );
	for 1 .. 1000 {
#		my $x = 2 ** ( 2 + 80.rand.Int );
#		my $i = ( ( $x + $x ).rand - $x );
#		my $s1 = $*fl.format( Q{~B}, $i );
#		my $s2 = formatter-call-to-string( $fn, $i );
#		# XXX convert $s1 to base-10
	}
}, [ ]
), Q{format.x.2};
)

#`(
# (deftest format.x.3
#   (with-standard-io-syntax
#    (loop for x = (ash 1 (+ 2 (random 80)))
#          for mincol = (random 30)
#          for i = (- (random (+ x x)) x)
#          for s1 = (format nil "~x" i)
#          for fmt = (format nil "~~~d~c" mincol (random-from-seq "xX"))
#          for s2 = (format nil fmt i)
#          for pos = (search s1 s2)
#          repeat 1000
#          when (or (null pos)
#                   (and (> mincol (length s1))
#                        (or (/= (length s2) mincol)
#                            (not (eql (position #\Space s2 :test-not #'eql)
#                                      (- (length s2) (length s1)))))))
#          collect (list i mincol s1 s2 pos)))
#   nil)
# 
ok deftest( {
	my $fn = $*fl.formatter( Q{~@X} );
	for 1 .. 1000 {
#		my $x = 2 ** ( 2 + 80.rand.Int );
#		my $i = ( ( $x + $x ).rand - $x );
#		my $s1 = $*fl.format( Q{~B}, $i );
#		my $s2 = formatter-call-to-string( $fn, $i );
#		# XXX convert $s1 to base-10
	}
}, [ ]
), Q{format.x.3};
)

#`(
# (deftest formatter.x.3
#   (with-standard-io-syntax
#    (loop for x = (ash 1 (+ 2 (random 80)))
#          for mincol = (random 30)
#          for i = (- (random (+ x x)) x)
#          for s1 = (format nil "~x" i)
#          for fmt = (format nil "~~~d~c" mincol (random-from-seq "xX"))
#          for fn = (eval `(formatter ,fmt))
#          for s2 = (formatter-call-to-string fn i)
#          for pos = (search s1 s2)
#          repeat 100
#          when (or (null pos)
#                   (and (> mincol (length s1))
#                        (or (/= (length s2) mincol)
#                            (not (eql (position #\Space s2 :test-not #'eql)
#                                      (- (length s2) (length s1)))))))
#          collect (list i mincol s1 s2 pos)))
#   nil)
# 
ok deftest( {
	my $fn = $*fl.formatter( Q{~@X} );
	for 1 .. 1000 {
#		my $x = 2 ** ( 2 + 80.rand.Int );
#		my $i = ( ( $x + $x ).rand - $x );
#		my $s1 = $*fl.format( Q{~B}, $i );
#		my $s2 = formatter-call-to-string( $fn, $i );
#		# XXX convert $s1 to base-10
	}
}, [ ]
), Q{formatter.x.3};
)

#`(
# (deftest format.x.4
#   (with-standard-io-syntax
#    (loop for x = (ash 1 (+ 2 (random 80)))
#          for mincol = (random 30)
#          for i = (- (random (+ x x)) x)
#          for s1 = (format nil "~@X" i)
#          for fmt = (format nil "~~~d@~c" mincol (random-from-seq "xX"))
#          for s2 = (format nil fmt i)
#          for pos = (search s1 s2)
#          repeat 1000
#          when (or (null pos)
#                   (and (>= i 0) (not (eql (elt s1 0) #\+)))
#                   (and (> mincol (length s1))
#                        (or (/= (length s2) mincol)
#                            (not (eql (position #\Space s2 :test-not #'eql)
#                                      (- (length s2) (length s1)))))))
#          collect (list i mincol s1 s2 pos)))
#   nil)
# 
ok deftest( {
	my $fn = $*fl.formatter( Q{~@X} );
	for 1 .. 1000 {
#		my $x = 2 ** ( 2 + 80.rand.Int );
#		my $i = ( ( $x + $x ).rand - $x );
#		my $s1 = $*fl.format( Q{~B}, $i );
#		my $s2 = formatter-call-to-string( $fn, $i );
#		# XXX convert $s1 to base-10
	}
}, [ ]
), Q{format.x.4};
)

#`(
# (deftest formatter.x.4
#   (with-standard-io-syntax
#    (loop for x = (ash 1 (+ 2 (random 80)))
#          for mincol = (random 30)
#          for i = (- (random (+ x x)) x)
#          for s1 = (format nil "~@X" i)
#          for fmt = (format nil "~~~d@~c" mincol (random-from-seq "xX"))
#          for fn = (eval `(formatter ,fmt))
#          for s2 = (formatter-call-to-string fn i)
#          for pos = (search s1 s2)
#          repeat 100
#          when (or (null pos)
#                   (and (>= i 0) (not (eql (elt s1 0) #\+)))
#                   (and (> mincol (length s1))
#                        (or (/= (length s2) mincol)
#                            (not (eql (position #\Space s2 :test-not #'eql)
#                                      (- (length s2) (length s1)))))))
#          collect (list i mincol s1 s2 pos)))
#   nil)
# 
ok deftest( {
	my $fn = $*fl.formatter( Q{~@X} );
	for 1 .. 1000 {
#		my $x = 2 ** ( 2 + 80.rand.Int );
#		my $i = ( ( $x + $x ).rand - $x );
#		my $s1 = $*fl.format( Q{~B}, $i );
#		my $s2 = formatter-call-to-string( $fn, $i );
#		# XXX convert $s1 to base-10
	}
}, [ ]
), Q{formatter.x.4};
)

#`(
# (deftest format.x.5
#   (with-standard-io-syntax
#    (loop for x = (ash 1 (+ 2 (random 80)))
#          for mincol = (random 30)
#          for padchar = (random-from-seq +standard-chars+)
#          for i = (- (random (+ x x)) x)
#          for s1 = (format nil "~x" i)
#          for fmt = (format nil "~~~d,'~c~c" mincol padchar (random-from-seq "xX"))
#          for s2 = (format nil fmt i)
#          for pos = (search s1 s2)
#          repeat 1000
#          when (or (null pos)
#                   (and (> mincol (length s1))
#                        (or (/= (length s2) mincol)
#                            (find padchar s2 :end (- (length s2) (length s1))
#                                  :test-not #'eql))))
#          collect (list i mincol s1 s2 pos)))
#   nil)
# 
ok deftest( {
	my $fn = $*fl.formatter( Q{~@X} );
	for 1 .. 1000 {
#		my $x = 2 ** ( 2 + 80.rand.Int );
#		my $i = ( ( $x + $x ).rand - $x );
#		my $s1 = $*fl.format( Q{~B}, $i );
#		my $s2 = formatter-call-to-string( $fn, $i );
#		# XXX convert $s1 to base-10
	}
}, [ ]
), Q{format.x.5};
)

#`(
# (deftest formatter.x.5
#   (with-standard-io-syntax
#    (loop for x = (ash 1 (+ 2 (random 80)))
#          for mincol = (random 30)
#          for padchar = (random-from-seq +standard-chars+)
#          for i = (- (random (+ x x)) x)
#          for s1 = (format nil "~x" i)
#          for fmt = (format nil "~~~d,'~c~c" mincol padchar (random-from-seq "xX"))
#          for fn = (eval `(formatter ,fmt))
#          for s2 = (formatter-call-to-string fn i)
#          for pos = (search s1 s2)
#          repeat 100
#          when (or (null pos)
#                   (and (> mincol (length s1))
#                        (or (/= (length s2) mincol)
#                            (find padchar s2 :end (- (length s2) (length s1))
#                                  :test-not #'eql))))
#          collect (list i mincol s1 s2 pos)))
#   nil)
# 
ok deftest( {
	my $fn = $*fl.formatter( Q{~@X} );
	for 1 .. 1000 {
#		my $x = 2 ** ( 2 + 80.rand.Int );
#		my $i = ( ( $x + $x ).rand - $x );
#		my $s1 = $*fl.format( Q{~B}, $i );
#		my $s2 = formatter-call-to-string( $fn, $i );
#		# XXX convert $s1 to base-10
	}
}, [ ]
), Q{formatter.x.5};
)

#`(
# (deftest format.x.6
#   (let ((fn (formatter "~V,vx")))
#     (with-standard-io-syntax
#      (loop for x = (ash 1 (+ 2 (random 80)))
#            for mincol = (random 30)
#            for padchar = (random-from-seq +standard-chars+)
#            for i = (- (random (+ x x)) x)
#            for s1 = (format nil "~x" i)
#            for s2 = (format nil "~v,vX" mincol padchar i)
#            for s3 = (formatter-call-to-string fn mincol padchar i)
#            for pos = (search s1 s2)
#            repeat 1000
#            when (or (null pos)
#                     (not (string= s2 s3))
#                     (and (> mincol (length s1))
#                          (or (/= (length s2) mincol)
#                              (find padchar s2 :end (- (length s2) (length s1))
#                                    :test-not #'eql))))
#            collect (list i mincol s1 s2 s3 pos))))
#   nil)
# 
ok deftest( {
	my $fn = $*fl.formatter( Q{~@X} );
	for 1 .. 1000 {
#		my $x = 2 ** ( 2 + 80.rand.Int );
#		my $i = ( ( $x + $x ).rand - $x );
#		my $s1 = $*fl.format( Q{~B}, $i );
#		my $s2 = formatter-call-to-string( $fn, $i );
#		# XXX convert $s1 to base-10
	}
}, [ ]
), Q{format.x.6};
)

#`(
# (deftest format.x.7
#   (let ((fn (formatter "~v,V@X")))
#     (with-standard-io-syntax
#      (loop for x = (ash 1 (+ 2 (random 80)))
#            for mincol = (random 30)
#            for padchar = (random-from-seq +standard-chars+)
#            for i = (- (random (+ x x)) x)
#            for s1 = (format nil "~@x" i)
#            for s2 = (format nil "~v,v@x" mincol padchar i)
#            for s3 = (formatter-call-to-string fn mincol padchar i)
#            for pos = (search s1 s2)
#            repeat 1000
#            when (or (null pos)
#                     (not (string= s2 s3))
#                     (and (>= i 0) (not (eql (elt s1 0) #\+)))
#                     (and (> mincol (length s1))
#                          (or (/= (length s2) mincol)
#                              (find padchar s2 :end (- (length s2) (length s1))
#                                    :test-not #'eql))))
#            collect (list i mincol s1 s2 s3 pos))))
#   nil)
# 
ok deftest( {
	my $fn = $*fl.formatter( Q{~@X} );
	for 1 .. 1000 {
#		my $x = 2 ** ( 2 + 80.rand.Int );
#		my $i = ( ( $x + $x ).rand - $x );
#		my $s1 = $*fl.format( Q{~B}, $i );
#		my $s2 = formatter-call-to-string( $fn, $i );
#		# XXX convert $s1 to base-10
	}
}, [ ]
), Q{format.x.7};
)

subtest {
	1;
	#`(
	# (deftest format.x.8
	#   (let ((fn (formatter "~:X")))
	#     (loop for i from -999 to 999
	#           for s1 = (format nil "~x" i)
	#           for s2 = (format nil "~:x" i)
	#           for s3 = (formatter-call-to-string fn i)
	#           unless (and (string= s1 s2) (string= s2 s3))
	#           collect (list i s1 s2 s3)))
	#   nil)
	# 
	ok deftest( {
		my $fn = $*fl.formatter( Q{~@X} );
		for 1 .. 1000 {
	#		my $x = 2 ** ( 2 + 80.rand.Int );
	#		my $i = ( ( $x + $x ).rand - $x );
	#		my $s1 = $*fl.format( Q{~B}, $i );
	#		my $s2 = formatter-call-to-string( $fn, $i );
	#		# XXX convert $s1 to base-10
		}
	}, [ ]
	), Q{format.x.8};
	)

	#`(
	# (deftest format.x.9
	#   (let ((fn (formatter "~:x")))
	#     (with-standard-io-syntax
	#      (loop for x = (ash 1 (+ 2 (random 80)))
	#            for i = (- (random (+ x x)) x)
	#            for commachar = #\,
	#            for s1 = (format nil "~x" i)
	#            for s2 = (format nil "~:X" i)
	#            for s3 = (formatter-call-to-string fn i)
	#            repeat 1000
	#            unless (and (string= s1 (remove commachar s2))
	#                        (string= s2 s3)
	#                        (not (eql (elt s2 0) commachar))
	#                        (or (>= i 0) (not (eql (elt s2 1) commachar)))
	#                        (let ((len (length s2))
	#                              (ci+1 4))
	#                          (loop for i from (if (< i 0) 2 1) below len
	#                                always (if (= (mod (- len i) ci+1) 0)
	#                                           (eql (elt s2 i) commachar)
	#                                         (find (elt s2 i) "0123456789ABCDEF" :test #'char-equal)))))
	#            collect (list x i commachar s1 s2 s3))))
	#   nil)
	# 
	ok deftest( {
		my $fn = $*fl.formatter( Q{~@X} );
		for 1 .. 1000 {
	#		my $x = 2 ** ( 2 + 80.rand.Int );
	#		my $i = ( ( $x + $x ).rand - $x );
	#		my $s1 = $*fl.format( Q{~B}, $i );
	#		my $s2 = formatter-call-to-string( $fn, $i );
	#		# XXX convert $s1 to base-10
		}
	}, [ ]
	), Q{format.x.9};
	)

	#`(
	# (deftest format.x.10
	#   (let ((fn (formatter "~,,V:x")))
	#     (with-standard-io-syntax
	#      (loop for x = (ash 1 (+ 2 (random 80)))
	#            for i = (- (random (+ x x)) x)
	#            for commachar = (random-from-seq +standard-chars+)
	#            for s1 = (format nil "~x" i)
	#            for s2 = (format nil "~,,v:X" commachar i)
	#            for s3 = (formatter-call-to-string fn commachar i)
	#            repeat 1000
	#            unless (and
	#                    (eql (elt s1 0) (elt s2 0))
	#                    (string= s2 s3)
	#                    (if (< i 0) (eql (elt s1 1) (elt s2 1)) t)
	#                    (let ((len (length s2))
	#                          (ci+1 4)
	#                          (j (if (< i 0) 1 0)))
	#                      (loop for i from (if (< i 0) 2 1) below len
	#                            always (if (= (mod (- len i) ci+1) 0)
	#                                       (eql (elt s2 i) commachar)
	#                                  (eql (elt s1 (incf j)) (elt s2 i))))))
	#            collect (list x i commachar s1 s2 s3))))
	#   nil)
	# 
	ok deftest( {
		my $fn = $*fl.formatter( Q{~@X} );
		for 1 .. 1000 {
	#		my $x = 2 ** ( 2 + 80.rand.Int );
	#		my $i = ( ( $x + $x ).rand - $x );
	#		my $s1 = $*fl.format( Q{~B}, $i );
	#		my $s2 = formatter-call-to-string( $fn, $i );
	#		# XXX convert $s1 to base-10
		}
	}, [ ]
	), Q{format.x.10};
	)

	#`(
	# (deftest format.x.11
	#   (with-standard-io-syntax
	#    (loop for x = (ash 1 (+ 2 (random 80)))
	#          for i = (- (random (+ x x)) x)
	#          for commachar = (random-from-seq +standard-chars+)
	#          for s1 = (format nil "~x" i)
	#          for fmt = (format nil "~~,,'~c:~c" commachar (random-from-seq "xX"))
	#          for s2 = (format nil fmt i)
	#          repeat 1000
	#          unless (and
	#                  (eql (elt s1 0) (elt s2 0))
	#                  (if (< i 0) (eql (elt s1 1) (elt s2 1)) t)
	#                  (let ((len (length s2))
	#                       (ci+1 4)
	#                       (j (if (< i 0) 1 0)))
	#                   (loop for i from (if (< i 0) 2 1) below len
	#                         always (if (= (mod (- len i) ci+1) 0)
	#                                    (eql (elt s2 i) commachar)
	#                                  (eql (elt s1 (incf j)) (elt s2 i))))))
	#          collect (list x i commachar s1 s2)))
	#   nil)
	# 
	ok deftest( {
		my $fn = $*fl.formatter( Q{~@X} );
		for 1 .. 1000 {
	#		my $x = 2 ** ( 2 + 80.rand.Int );
	#		my $i = ( ( $x + $x ).rand - $x );
	#		my $s1 = $*fl.format( Q{~B}, $i );
	#		my $s2 = formatter-call-to-string( $fn, $i );
	#		# XXX convert $s1 to base-10
		}
	}, [ ]
	), Q{format.x.11};
	)

	#`(
	# (deftest formatter.x.11
	#   (with-standard-io-syntax
	#    (loop for x = (ash 1 (+ 2 (random 80)))
	#          for i = (- (random (+ x x)) x)
	#          for commachar = (random-from-seq +standard-chars+)
	#          for s1 = (format nil "~x" i)
	#          for fmt = (format nil "~~,,'~c:~c" commachar (random-from-seq "xX"))
	#          for fn = (eval `(formatter ,fmt))
	#          for s2 = (formatter-call-to-string fn i)
	#          repeat 100
	#          unless (and
	#                  (eql (elt s1 0) (elt s2 0))
	#                  (if (< i 0) (eql (elt s1 1) (elt s2 1)) t)
	#                  (let ((len (length s2))
	#                       (ci+1 4)
	#                       (j (if (< i 0) 1 0)))
	#                   (loop for i from (if (< i 0) 2 1) below len
	#                         always (if (= (mod (- len i) ci+1) 0)
	#                                    (eql (elt s2 i) commachar)
	#                                  (eql (elt s1 (incf j)) (elt s2 i))))))
	#          collect (list x i commachar s1 s2)))
	#   nil)
	# 
	ok deftest( {
		my $fn = $*fl.formatter( Q{~@X} );
		for 1 .. 1000 {
	#		my $x = 2 ** ( 2 + 80.rand.Int );
	#		my $i = ( ( $x + $x ).rand - $x );
	#		my $s1 = $*fl.format( Q{~B}, $i );
	#		my $s2 = formatter-call-to-string( $fn, $i );
	#		# XXX convert $s1 to base-10
		}
	}, [ ]
	), Q{formatter.x.11};
	)

	#`(
	# (deftest format.x.12
	#   (let ((fn (formatter "~,,v,v:X")))
	#     (with-standard-io-syntax
	#      (loop for x = (ash 1 (+ 2 (random 80)))
	#            for i = (- (random (+ x x)) x)
	#            for commachar = (random-from-seq +standard-chars+)
	#            for commaint = (1+ (random 20))
	#            for s1 = (format nil "~x" i)
	#            for s2 = (format nil "~,,v,v:X" commachar commaint i)
	#            for s3 = (formatter-call-to-string fn commachar commaint i)
	#            repeat 1000
	#            unless (and
	#                    (eql (elt s1 0) (elt s2 0))
	#                    (string= s2 s3)
	#                    (if (< i 0) (eql (elt s1 1) (elt s2 1)) t)
	#                    (let ((len (length s2))
	#                          (ci+1 (1+ commaint))
	#                          (j (if (< i 0) 1 0)))
	#                      (loop for i from (if (< i 0) 2 1) below len
	#                            always (if (= (mod (- len i) ci+1) 0)
	#                                       (eql (elt s2 i) commachar)
	#                                     (eql (elt s1 (incf j)) (elt s2 i))))))
	#            collect (list x i commachar s1 s2 s3))))
	#   nil)
	# 
	ok deftest( {
		my $fn = $*fl.formatter( Q{~@X} );
		for 1 .. 1000 {
	#		my $x = 2 ** ( 2 + 80.rand.Int );
	#		my $i = ( ( $x + $x ).rand - $x );
	#		my $s1 = $*fl.format( Q{~B}, $i );
	#		my $s2 = formatter-call-to-string( $fn, $i );
	#		# XXX convert $s1 to base-10
		}
	}, [ ]
	), Q{format.x.12};
	)

	#`(
	# (deftest format.x.13
	#   (let ((fn (formatter "~,,v,V:@x")))
	#     (with-standard-io-syntax
	#      (loop for x = (ash 1 (+ 2 (random 80)))
	#            for i = (- (random (+ x x)) x)
	#            for commachar = (random-from-seq +standard-chars+)
	#            for commaint = (1+ (random 20))
	#            for s1 = (format nil "~@x" i)
	#            for s2 = (format nil "~,,v,v:@x" commachar commaint i)
	#            for s3 = (formatter-call-to-string fn commachar commaint i)
	#            repeat 1000
	#            unless (and
	#                    (eql (elt s1 0) (elt s2 0))
	#                    (eql (elt s1 1) (elt s2 1))
	#                    (string= s2 s3)
	#                    (let ((len (length s2))
	#                          (ci+1 (1+ commaint))
	#                          (j 1))
	#                      (loop for i from 2 below len
	#                            always (if (= (mod (- len i) ci+1) 0)
	#                                       (eql (elt s2 i) commachar)
	#                                     (eql (elt s1 (incf j)) (elt s2 i))))))
	#            collect (list x i commachar s1 s2 s3))))
	#   nil)
	# 
	ok deftest( {
		my $fn = $*fl.formatter( Q{~@X} );
		for 1 .. 1000 {
	#		my $x = 2 ** ( 2 + 80.rand.Int );
	#		my $i = ( ( $x + $x ).rand - $x );
	#		my $s1 = $*fl.format( Q{~B}, $i );
	#		my $s2 = formatter-call-to-string( $fn, $i );
	#		# XXX convert $s1 to base-10
		}
	}, [ ]
	), Q{format.x.13};
	)
}, Q{Comma tests};

# ;;; NIL arguments
# 
# (def-format-test format.x.14
#   "~vx" (nil #x100) "100")
# 
ok def-format-test( Q{~vx}, ( Nil, 0x100 ), Q{100} ), Q{format.x.14};

# (def-format-test format.x.15
#   "~6,vX" (nil #x100) "   100")
# 
ok def-format-test( Q{~6,vX}, ( Nil, 0x100 ), Q{   100} ), Q{format.x.15};

# (def-format-test format.x.16
#   "~,,v:x" (nil #x12345) "12,345")
# 
ok def-format-test( Q{~,,v:x}, ( Nil, 0x12345 ), Q{12,345} ), Q{format.x.16};

# (def-format-test format.x.17
#   "~,,'*,v:x" (nil #x12345) "12*345")
# 
ok def-format-test( Q{~,,'*,v:x}, ( Nil, 0x12345 ), Q{12*345} ), Q{format.x.17};

subtest {
	1;
	#`(
	# (deftest format.x.18
	#   (let ((fn (formatter "~x")))
	#     (loop for x in *mini-universe*
	#           for s1 = (format nil "~x" x)
	#           for s2 = (let ((*print-base* 16)) (format nil "~A" x))
	#           for s3 = (formatter-call-to-string fn x)
	#           unless (or (integerp x) (and (string= s1 s2) (string= s2 s3)))
	#           collect (list x s1 s2 s3)))
	#   nil)
	# 
	ok deftest( {
		my $fn = $*fl.formatter( Q{~@X} );
		for 1 .. 1000 {
	#		my $x = 2 ** ( 2 + 80.rand.Int );
	#		my $i = ( ( $x + $x ).rand - $x );
	#		my $s1 = $*fl.format( Q{~B}, $i );
	#		my $s2 = formatter-call-to-string( $fn, $i );
	#		# XXX convert $s1 to base-10
		}
	}, [ ]
	), Q{format.x.18};
	)

	#`(
	# (deftest format.x.19
	#   (let ((fn (formatter "~:x")))
	#     (loop for x in *mini-universe*
	#           for s1 = (format nil "~:x" x)
	#           for s2 = (let ((*print-base* 16)) (format nil "~A" x))
	#           for s3 = (formatter-call-to-string fn x)
	#           unless (or (integerp x) (and (string= s1 s2) (string= s2 s3)))
	#           collect (list x s1 s2 s3)))
	#   nil)
	# 
	ok deftest( {
		my $fn = $*fl.formatter( Q{~@X} );
		for 1 .. 1000 {
	#		my $x = 2 ** ( 2 + 80.rand.Int );
	#		my $i = ( ( $x + $x ).rand - $x );
	#		my $s1 = $*fl.format( Q{~B}, $i );
	#		my $s2 = formatter-call-to-string( $fn, $i );
	#		# XXX convert $s1 to base-10
		}
	}, [ ]
	), Q{format.x.19};
	)

	#`(
	# (deftest format.x.20
	#   (let ((fn (formatter "~@x")))
	#     (loop for x in *mini-universe*
	#           for s1 = (format nil "~@x" x)
	#           for s2 = (let ((*print-base* 16)) (format nil "~A" x))
	#           for s3 = (formatter-call-to-string fn x)
	#           unless (or (integerp x) (and (string= s1 s2) (string= s2 s3)))
	#           collect (list x s1 s2 s3)))
	#   nil)
	# 
	ok deftest( {
		my $fn = $*fl.formatter( Q{~@X} );
		for 1 .. 1000 {
	#		my $x = 2 ** ( 2 + 80.rand.Int );
	#		my $i = ( ( $x + $x ).rand - $x );
	#		my $s1 = $*fl.format( Q{~B}, $i );
	#		my $s2 = formatter-call-to-string( $fn, $i );
	#		# XXX convert $s1 to base-10
		}
	}, [ ]
	), Q{format.x.20};
	)

	#`(
	# (deftest format.x.21
	#   (let ((fn (formatter "~:@x")))
	#     (loop for x in *mini-universe*
	#           for s1 = (let ((*print-base* 16)) (format nil "~A" x))
	#           for s2 = (format nil "~@:x" x)
	#           for s3 = (formatter-call-to-string fn x)
	#           for s4 = (let ((*print-base* 16)) (format nil "~A" x))
	#           unless (or (string/= s1 s4)
	#                      (integerp x)
	#                      (and (string= s1 s2) (string= s2 s3)))
	#           collect (list x s1 s2 s3)))
	#   nil)
	# 
	ok deftest( {
		my $fn = $*fl.formatter( Q{~@X} );
		for 1 .. 1000 {
	#		my $x = 2 ** ( 2 + 80.rand.Int );
	#		my $i = ( ( $x + $x ).rand - $x );
	#		my $s1 = $*fl.format( Q{~B}, $i );
	#		my $s2 = formatter-call-to-string( $fn, $i );
	#		# XXX convert $s1 to base-10
		}
	}, [ ]
	), Q{format.x.21};
	)
}, Q{When the argument is not an integer, print as if using ~A and base 10};

# ;;; Must add tests for non-integers when the parameters
# ;;; are specified, but it's not clear what the meaning is.
# ;;; Does mincol apply to the ~A equivalent?  What about padchar?
# ;;; Are comma-char and comma-interval always ignored?

subtest {
	#`(
	# (deftest format.x.22
	#   (apply
	#    #'values
	#    (let ((fn (formatter "~#X"))
	#          (n #x1b3fe))
	#      (loop for i from 0 to 10
	#            for args = (make-list i)
	#            for s = (apply #Q{format nil "~#x" n args)
	#            for s2 = (with-output-to-string
	#                       (stream)
	#                       (assert (equal (apply fn stream n args) args)))
	#            do (assert (string= s s2))
	#            collect (string-upcase s))))
	#   "1B3FE"
	#   "1B3FE"
	#   "1B3FE"
	#   "1B3FE"
	#   "1B3FE"
	#   " 1B3FE"
	#   "  1B3FE"
	#   "   1B3FE"
	#   "    1B3FE"
	#   "     1B3FE"
	#   "      1B3FE")
	# 
	ok deftest( {
		my $fn = $*fl.formatter( Q{~@X} );
		for 1 .. 1000 {
	#		my $x = 2 ** ( 2 + 80.rand.Int );
	#		my $i = ( ( $x + $x ).rand - $x );
	#		my $s1 = $*fl.format( Q{~B}, $i );
	#		my $s2 = formatter-call-to-string( $fn, $i );
	#		# XXX convert $s1 to base-10
		}
	}, [ ]
	), Q{format.x.22};
	)

	#`(
	# (deftest format.x.23
	#   (apply
	#    #'values
	#    (let ((fn (formatter "~,,,#:X"))
	#          (n #x1234567890))
	#      (loop for i from 0 to 10
	#            for args = (make-list i)
	#            for s = (apply #Q{format nil "~,,,#:x" n args)
	#            for s2 = (with-output-to-string
	#                       (stream)
	#                       (assert (equal (apply fn stream n args) args)))
	#            do (assert (string= s s2))
	#            collect s)))
	#   "1,2,3,4,5,6,7,8,9,0"
	#   "12,34,56,78,90"
	#   "1,234,567,890"
	#   "12,3456,7890"
	#   "12345,67890"
	#   "1234,567890"
	#   "123,4567890"
	#   "12,34567890"
	#   "1,234567890"
	#   "1234567890"
	#   "1234567890")
	# 
	ok deftest( {
		my $fn = $*fl.formatter( Q{~@X} );
		for 1 .. 1000 {
	#		my $x = 2 ** ( 2 + 80.rand.Int );
	#		my $i = ( ( $x + $x ).rand - $x );
	#		my $s1 = $*fl.format( Q{~B}, $i );
	#		my $s2 = formatter-call-to-string( $fn, $i );
	#		# XXX convert $s1 to base-10
		}
	}, [ ]
	), Q{format.x.23};
	)

	#`(
	# (deftest format.x.24
	#   (apply
	#    #'values
	#    (let ((fn (formatter "~,,,#@:X"))
	#          (n #x1234567890))
	#      (loop for i from 0 to 10
	#            for args = (make-list i)
	#            for s = (apply #Q{format nil "~,,,#@:X" n args)
	#            for s2 = (with-output-to-string
	#                       (stream)
	#                       (assert (equal (apply fn stream n args) args)))
	#            do (assert (string= s s2))
	#            collect s)))
	#   "+1,2,3,4,5,6,7,8,9,0"
	#   "+12,34,56,78,90"
	#   "+1,234,567,890"
	#   "+12,3456,7890"
	#   "+12345,67890"
	#   "+1234,567890"
	#   "+123,4567890"
	#   "+12,34567890"
	#   "+1,234567890"
	#   "+1234567890"
	#   "+1234567890")
	# 
	ok deftest( {
		my @collected;
		my $fn = $*fl.formatter( Q{~#X} );
		my $n = ox1234567890;
		for 0 .. 10 -> $i {
	#		my @args = 
	##		my $s = $*fl.format( Q{~v,,2A}, $i, Q{ABC} );
	#		my $s2 = formatter-call-to-string( $fn, $i, Q{ABC} );
	#		is $s, $s2;
	#		@collected.append( $s );
		}
		@collected;
	}, [	Q{1,2,3,4,5,6,7,0,1,2},
		Q{12,34,56,70,12},
		Q{1,234,567,012},
		Q{12,3456,7012},
		Q{12345,67012},
		Q{1234,567012},
		Q{123,4567012},
		Q{12,34567012},
		Q{1,234567012},
		Q{1234567012},
		Q{1234567012}
	]
	), Q{format.x.24};
	)

	# (def-format-test format.x.25
	#   "~+10x" (#x1234) "      1234")
	# 
	ok def-format-test(
		Q{~+10X}, ( 0x1234 ), Q{      1234}
	), Q{format.x.25};

	# (def-format-test format.x.26
	#   "~+10@X" (#x1234) "     +1234")
	# 
	ok def-format-test(
		Q{~+10@X}, ( 0x1234 ), Q{     +1234}
	), Q{format.x.26};

	# (def-format-test format.x.27
	#   "~-1X" (#x1234) "1234")
	# 
	ok def-format-test(
		Q{~-1X}, ( 0x1234 ), Q{1234}
	), Q{format.x.27};

	# (def-format-test format.x.28
	#   "~-1000000000000000000x" (#x1234) "1234")
	# 
	ok def-format-test(
		Q{~-1000000000000000000x}, ( 0x1234 ), Q{1234}
	), Q{format.x.28};

	# (def-format-test format.x.29
	#   "~vx" ((1- most-negative-fixnum) #x1234) "1234")
	# 
	# XXX Don't think it's applicable?
}, Q{# arguments};

# ;;; Randomized test
# 
#`(
# (deftest format.x.30
#   (let ((fn (formatter "~v,v,v,vx")))
#     (loop
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
#                 (if mincol (format nil "~~~d," mincol) "~,")
#                 (if padchar (format nil "'~c," padchar) ",")
#                 (if commachar (format nil "'~c," commachar) ",")
#                 (if commaint (format nil "~dx" commaint) "x"))
#      for s1 = (format nil fmt x)
#      for s2 = (format nil "~v,v,v,vx" mincol padchar commachar commaint x)
#      for s3 = (formatter-call-to-string fn mincol padchar commachar commaint x)
#      repeat 2000
#      unless (and (string= s1 s2) (string= s2 s3))
#      collect (list mincol padchar commachar commaint fmt x s1 s2 s3)))
#   nil)
# 
)

done-testing;

# vim: ft=perl6
