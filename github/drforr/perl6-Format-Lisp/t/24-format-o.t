use v6;

use Test;
use lib 't/lib';
use Utils;
use Format::Lisp;

my $*fl = Format::Lisp.new;

subtest {
	is $*fl.format( Q{~o}, 7 ), Q{7}, Q{format.o.1.slice};

	is $*fl.format( Q{~@o}, 7 ), Q{+7}, Q{format.o.2.slice};

	is $*fl.format( Q{~1o}, 7 ), Q{7}, Q{format.o.3.slice};

	is $*fl.format( Q{~1@o}, 7 ), Q{+7}, Q{format.o.3.slice};

	is $*fl.format( Q{~1,'xo}, 7 ), Q{7}, Q{format.o.5.slice};

#`(
	is $*fl.format( Q{~v,Vo}, 7 ), Q{7}, Q{format.o.6.slice};
)

#`(
	is $*fl.format( Q{~v,V@o}, 7 ), Q{7}, Q{format.o.7.slice};
)

	is $*fl.format( Q{~:O}, 0o7654 ), Q{7,654}, Q{format.o.8.slice};

#`(
	is $*fl.format( Q{~,,v:o}, 0o7654 ), Q{7,654}, Q{format.o.10.slice};
)

	is $*fl.format( Q{~,,'x:o}, 0o7654 ), Q{7x654}, Q{format.o.11.slice};

#`(
	is $*fl.format( Q{~,,V,v:O}, 0o7654 ), Q{7,654}, Q{format.o.12.slice};
)

#`(
	is $*fl.format( Q{~,,V,v@O}, 0o7654 ), Q{7,654}, Q{format.o.13.slice};
)
}, Q{missing coverage};

#`(
# (deftest format.o.1
#   (let ((fn (formatter "~o")))
#     (with-standard-io-syntax
#      (loop for x = (ash 1 (+ 2 (random 80)))
#            for i = (- (random (+ x x)) x)
#            for s1 = (format nil "~O" i)
#            for j = (let ((*read-base* 8)) (read-from-string s1))
#            for s2 = (formatter-call-to-string fn i)
#            repeat 1000
#            when (or (/= i j)
#                     (not (string= s1 s2))
#                     (find #\. s1)
#                     (find #\+ s1)
#                   (find-if #'alpha-char-p s1))
#            collect (list i s1 j s2))))
#   nil)
# 
ok deftest( {
	my $fn = $*fl.formatter( Q{~o} );
	for 1 .. 1000 {
#		my $x = 2 ** ( 2 + 80.rand.Int );
#		my $i = ( ( $x + $x ).rand - $x );
#		my $s1 = $*fl.format( Q{~B}, $i );
#		my $s2 = formatter-call-to-string( $fn, $i );
#		# XXX convert $s1 to base-10
	}
}, [ ]
), Q{format.o.1};
)

#`(
# (deftest format.o.2
#   (let ((fn (formatter "~@O")))
#     (with-standard-io-syntax
#      (loop for x = (ash 1 (+ 2 (random 80)))
#            for i = (- (random (+ x x)) x)
#            for s1 = (format nil "~@o" i)
#            for j = (let ((*read-base* 8)) (read-from-string s1))
#            for s2 = (formatter-call-to-string fn i)
#            repeat 1000
#            when (or (/= i j)
#                     (not (string= s1 s2))
#                     (find #\. s1)
#                     ;; (find #\+ s1)
#                     (find-if #'alpha-char-p s1))
#            collect (list i s1 j s2))))
#   nil)
# 
ok deftest( {
	my $fn = $*fl.formatter( Q{~@O} );
	for 1 .. 1000 {
#		my $x = 2 ** ( 2 + 80.rand.Int );
#		my $i = ( ( $x + $x ).rand - $x );
#		my $s1 = $*fl.format( Q{~B}, $i );
#		my $s2 = formatter-call-to-string( $fn, $i );
#		# XXX convert $s1 to base-10
	}
}, [ ]
), Q{format.o.1};
)

#`(
# (deftest format.o.3
#   (with-standard-io-syntax
#    (loop for x = (ash 1 (+ 2 (random 80)))
#          for mincol = (random 30)
#          for i = (- (random (+ x x)) x)
#          for s1 = (format nil "~o" i)
#          for fmt = (format nil "~~~do" mincol)
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
	for 1 .. 1000 {
#		my $x = 2 ** ( 2 + 80.rand.Int );
#		my $i = ( ( $x + $x ).rand - $x );
#		my $s1 = $*fl.format( Q{~B}, $i );
#		my $s2 = formatter-call-to-string( $fn, $i );
#		# XXX convert $s1 to base-10
	}
}, [ ]
), Q{format.o.2};
)

#`(
# (deftest formatter.o.3
#   (with-standard-io-syntax
#    (loop for x = (ash 1 (+ 2 (random 80)))
#          for mincol = (random 30)
#          for i = (- (random (+ x x)) x)
#          for s1 = (format nil "~o" i)
#          for fmt = (format nil "~~~do" mincol)
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
	for 1 .. 1000 {
#		my $x = 2 ** ( 2 + 80.rand.Int );
#		my $i = ( ( $x + $x ).rand - $x );
#		my $s1 = $*fl.format( Q{~B}, $i );
#		my $s2 = formatter-call-to-string( $fn, $i );
#		# XXX convert $s1 to base-10
	}
}, [ ]
), Q{format.o.3};
)

#`(
# (deftest format.o.4
#   (with-standard-io-syntax
#    (loop for x = (ash 1 (+ 2 (random 80)))
#          for mincol = (random 30)
#          for i = (- (random (+ x x)) x)
#          for s1 = (format nil "~@O" i)
#          for fmt = (format nil "~~~d@o" mincol)
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
	for 1 .. 1000 {
#		my $x = 2 ** ( 2 + 80.rand.Int );
#		my $i = ( ( $x + $x ).rand - $x );
#		my $s1 = $*fl.format( Q{~B}, $i );
#		my $s2 = formatter-call-to-string( $fn, $i );
#		# XXX convert $s1 to base-10
	}
}, [ ]
), Q{format.o.4};
)

#`(
# (deftest formatter.o.4
#   (with-standard-io-syntax
#    (loop for x = (ash 1 (+ 2 (random 80)))
#          for mincol = (random 30)
#          for i = (- (random (+ x x)) x)
#          for s1 = (format nil "~@O" i)
#          for fmt = (format nil "~~~d@o" mincol)
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
	for 1 .. 1000 {
#		my $x = 2 ** ( 2 + 80.rand.Int );
#		my $i = ( ( $x + $x ).rand - $x );
#		my $s1 = $*fl.format( Q{~B}, $i );
#		my $s2 = formatter-call-to-string( $fn, $i );
#		# XXX convert $s1 to base-10
	}
}, [ ]
), Q{formatter.o.4};
)

#`(
# (deftest format.o.5
#   (with-standard-io-syntax
#    (loop for x = (ash 1 (+ 2 (random 80)))
#          for mincol = (random 30)
#          for padchar = (random-from-seq +standard-chars+)
#          for i = (- (random (+ x x)) x)
#          for s1 = (format nil "~o" i)
#          for fmt = (format nil "~~~d,'~c~c" mincol padchar
#                            (random-from-seq "oO"))
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
	for 1 .. 1000 {
#		my $x = 2 ** ( 2 + 80.rand.Int );
#		my $i = ( ( $x + $x ).rand - $x );
#		my $s1 = $*fl.format( Q{~B}, $i );
#		my $s2 = formatter-call-to-string( $fn, $i );
#		# XXX convert $s1 to base-10
	}
}, [ ]
), Q{format.o.5};
)

#`(
# (deftest formatter.o.5
#   (with-standard-io-syntax
#    (loop for x = (ash 1 (+ 2 (random 80)))
#          for mincol = (random 30)
#          for padchar = (random-from-seq +standard-chars+)
#          for i = (- (random (+ x x)) x)
#          for s1 = (format nil "~o" i)
#          for fmt = (format nil "~~~d,'~c~c" mincol padchar
#                            (random-from-seq "oO"))
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
	for 1 .. 1000 {
#		my $x = 2 ** ( 2 + 80.rand.Int );
#		my $i = ( ( $x + $x ).rand - $x );
#		my $s1 = $*fl.format( Q{~B}, $i );
#		my $s2 = formatter-call-to-string( $fn, $i );
#		# XXX convert $s1 to base-10
	}
}, [ ]
), Q{formatter.o.5};
)

#`(
# (deftest format.o.6
#   (let ((fn (formatter "~V,Vo")))
#     (with-standard-io-syntax
#      (loop for x = (ash 1 (+ 2 (random 80)))
#            for mincol = (random 30)
#            for padchar = (random-from-seq +standard-chars+)
#            for i = (- (random (+ x x)) x)
#            for s1 = (format nil "~o" i)
#            for s2 = (format nil "~v,vO" mincol padchar i)
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
	for 1 .. 1000 {
#		my $x = 2 ** ( 2 + 80.rand.Int );
#		my $i = ( ( $x + $x ).rand - $x );
#		my $s1 = $*fl.format( Q{~B}, $i );
#		my $s2 = formatter-call-to-string( $fn, $i );
#		# XXX convert $s1 to base-10
	}
}, [ ]
), Q{format.o.6};
)

#`(
# (deftest format.o.7
#   (let ((fn (formatter "~v,V@O")))
#     (with-standard-io-syntax
#      (loop for x = (ash 1 (+ 2 (random 80)))
#            for mincol = (random 30)
#            for padchar = (random-from-seq +standard-chars+)
#            for i = (- (random (+ x x)) x)
#            for s1 = (format nil "~@o" i)
#            for s2 = (format nil "~v,v@o" mincol padchar i)
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
	for 1 .. 1000 {
#		my $x = 2 ** ( 2 + 80.rand.Int );
#		my $i = ( ( $x + $x ).rand - $x );
#		my $s1 = $*fl.format( Q{~B}, $i );
#		my $s2 = formatter-call-to-string( $fn, $i );
#		# XXX convert $s1 to base-10
	}
}, [ ]
), Q{format.o.7};
)

subtest {
	1;
	#`(
	# (deftest format.o.8
	#   (let ((fn (formatter "~:O")))
	#     (loop for i from #o-777 to #o777
	#           for s1 = (format nil "~o" i)
	#           for s2 = (format nil "~:o" i)
	#           for s3 = (formatter-call-to-string fn i)
	#           unless (and (string= s1 s2) (string= s2 s3))
	#           collect (list i s1 s2 s3)))
	#   nil)
	# 
	ok deftest( {
		for 1 .. 1000 {
	#		my $x = 2 ** ( 2 + 80.rand.Int );
	#		my $i = ( ( $x + $x ).rand - $x );
	#		my $s1 = $*fl.format( Q{~B}, $i );
	#		my $s2 = formatter-call-to-string( $fn, $i );
	#		# XXX convert $s1 to base-10
		}
	}, [ ]
	), Q{format.o.8};
	)

	#`(
	# (deftest format.o.9
	#   (let ((fn (formatter "~:o")))
	#     (with-standard-io-syntax
	#      (loop for x = (ash 1 (+ 2 (random 80)))
	#            for i = (- (random (+ x x)) x)
	#            for commachar = #\,
	#            for s1 = (format nil "~o" i)
	#            for s2 = (format nil "~:O" i)
	#             for s3 = (formatter-call-to-string fn i)
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
	#                                         (find (elt s2 i) "01234567")))))
	#            collect (list x i commachar s1 s2 s3))))
	#   nil)
	# 
	ok deftest( {
		for 1 .. 1000 {
	#		my $x = 2 ** ( 2 + 80.rand.Int );
	#		my $i = ( ( $x + $x ).rand - $x );
	#		my $s1 = $*fl.format( Q{~B}, $i );
	#		my $s2 = formatter-call-to-string( $fn, $i );
	#		# XXX convert $s1 to base-10
		}
	}, [ ]
	), Q{format.o.9};
	)

	#`(
	# (deftest format.o.10
	#   (let ((fn (formatter "~,,v:o")))
	#     (with-standard-io-syntax
	#      (loop for x = (ash 1 (+ 2 (random 80)))
	#            for i = (- (random (+ x x)) x)
	#            for commachar = (random-from-seq +standard-chars+)
	#            for s1 = (format nil "~o" i)
	#            for s2 = (format nil "~,,v:o" commachar i)
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
	#                                     (eql (elt s1 (incf j)) (elt s2 i))))))
	#            collect (list x i commachar s1 s2 s3))))
	#   nil)
	# 
	ok deftest( {
		for 1 .. 1000 {
	#		my $x = 2 ** ( 2 + 80.rand.Int );
	#		my $i = ( ( $x + $x ).rand - $x );
	#		my $s1 = $*fl.format( Q{~B}, $i );
	#		my $s2 = formatter-call-to-string( $fn, $i );
	#		# XXX convert $s1 to base-10
		}
	}, [ ]
	), Q{format.o.10};
	)

	#`(
	# (deftest format.o.11
	#   (with-standard-io-syntax
	#    (loop for x = (ash 1 (+ 2 (random 80)))
	#          for i = (- (random (+ x x)) x)
	#          for commachar = (random-from-seq +standard-chars+)
	#          for s1 = (format nil "~o" i)
	#          for fmt = (format nil "~~,,'~c:~c" commachar (random-from-seq "oO"))
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
		for 1 .. 1000 {
	#		my $x = 2 ** ( 2 + 80.rand.Int );
	#		my $i = ( ( $x + $x ).rand - $x );
	#		my $s1 = $*fl.format( Q{~B}, $i );
	#		my $s2 = formatter-call-to-string( $fn, $i );
	#		# XXX convert $s1 to base-10
		}
	}, [ ]
	), Q{format.o.11};
	)

	#`(
	# (deftest formatter.o.11
	#   (with-standard-io-syntax
	#    (loop for x = (ash 1 (+ 2 (random 80)))
	#          for i = (- (random (+ x x)) x)
	#          for commachar = (random-from-seq +standard-chars+)
	#          for s1 = (format nil "~o" i)
	#          for fmt = (format nil "~~,,'~c:~c" commachar (random-from-seq "oO"))
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
		for 1 .. 1000 {
	#		my $x = 2 ** ( 2 + 80.rand.Int );
	#		my $i = ( ( $x + $x ).rand - $x );
	#		my $s1 = $*fl.format( Q{~B}, $i );
	#		my $s2 = formatter-call-to-string( $fn, $i );
	#		# XXX convert $s1 to base-10
		}
	}, [ ]
	), Q{formatter.o.11};
	)

	#`(
	# (deftest format.o.12
	#   (let ((fn (formatter "~,,V,v:O")))
	#     (with-standard-io-syntax
	#      (loop for x = (ash 1 (+ 2 (random 80)))
	#            for i = (- (random (+ x x)) x)
	#            for commachar = (random-from-seq +standard-chars+)
	#            for commaint = (1+ (random 20))
	#            for s1 = (format nil "~o" i)
	#            for s2 = (format nil "~,,v,v:O" commachar commaint i)
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
		for 1 .. 1000 {
	#		my $x = 2 ** ( 2 + 80.rand.Int );
	#		my $i = ( ( $x + $x ).rand - $x );
	#		my $s1 = $*fl.format( Q{~B}, $i );
	#		my $s2 = formatter-call-to-string( $fn, $i );
	#		# XXX convert $s1 to base-10
		}
	}, [ ]
	), Q{format.o.12};
	)

	#`(
	# (deftest format.o.13
	#   (let ((fn (formatter "~,,v,V@:O")))
	#     (with-standard-io-syntax
	#      (loop for x = (ash 1 (+ 2 (random 80)))
	#            for i = (- (random (+ x x)) x)
	#            for commachar = (random-from-seq +standard-chars+)
	#            for commaint = (1+ (random 20))
	#            for s1 = (format nil "~@o" i)
	#            for s2 = (format nil "~,,v,v:@o" commachar commaint i)
	#            for s3 = (formatter-call-to-string fn commachar commaint i)
	#            repeat 1000
	#            unless (and
	#                    (string= s2 s3)
	#                    (eql (elt s1 0) (elt s2 0))
	#                    (eql (elt s1 1) (elt s2 1))
	#                    (let ((len (length s2))
	#                          (ci+1 (1+ commaint))
	#                          (j 1))
	#                      (loop for i from 2 below len
	#                            always (if (= (mod (- len i) ci+1) 0)
	#                                       (eql (elt s2 i) commachar)
	#                                   (eql (elt s1 (incf j)) (elt s2 i))))))
	#            collect (list x i commachar s1 s2 s3))))
	#   nil)
	# 
	ok deftest( {
		my $f = $*fl.formatter( Q{~,,v,V@:O} );
		for 1 .. 1000 {
	#		my $x = 2 ** ( 2 + 80.rand.Int );
	#		my $i = ( ( $x + $x ).rand - $x );
	#		my $s1 = $*fl.format( Q{~B}, $i );
	#		my $s2 = formatter-call-to-string( $fn, $i );
	#		# XXX convert $s1 to base-10
		}
	}, [ ]
	), Q{format.o.13};
	)
}, Q{Comma tests};

subtest {
	# (def-format-test format.o.14
	#   "~vO" (nil #o100) "100")
	# 
	ok def-format-test( Q{~vO}, ( Nil, 0o100 ), Q{100} ), Q{format.o.14};

	#`(
	# (def-format-test format.o.15
	#   "~6,vO" (nil #o100) "   100")
	# 
	ok def-format-test(
		Q{~6,vO}, ( Nil, 0o100 ), Q{   100}
	), Q{format.o.15};
	)

	#`(
	# (def-format-test format.o.16
	#   "~,,v:o" (nil #o12345) "12,345")
	# 
	ok def-format-test(
		Q{~,,v:o}, ( Nil, 0o12345 ), Q{12,345}
	), Q{format.o.16};
	)

	#`(
	# (def-format-test format.o.17
	#   "~,,'*,v:o" (nil #o12345) "12*345")
	# 
	ok def-format-test(
		Q{~,,'*,v:o}, ( Nil, 0o12345 ), Q{12*345}
	), Q{format.o.17};
	)
}, Q{NIL arguments};

# ;;; When the argument is not an integer, print as if using ~A and base 10
# 
#`(
# (deftest format.o.18
#   (let ((fn (formatter "~o")))
#     (loop for x in *mini-universe*
#           for s1 = (format nil "~o" x)
#           for s2 = (let ((*print-base* 8)) (format nil "~A" x))
#           for s3 = (formatter-call-to-string fn x)
#           unless (or (integerp x) (and (string= s1 s2) (string= s2 s3)))
#           collect (list x s1 s2 s3)))
#   nil)
# 
ok deftest( {
	my $fn = $*fl.formatter( Q{~o} );
	for 1 .. 1000 {
#		my $x = 2 ** ( 2 + 80.rand.Int );
#		my $i = ( ( $x + $x ).rand - $x );
#		my $s1 = $*fl.format( Q{~B}, $i );
#		my $s2 = formatter-call-to-string( $fn, $i );
#		# XXX convert $s1 to base-10
	}
}, [ ]
), Q{format.o.18};
)

#`(
# (deftest format.o.19
#   (let ((fn (formatter "~:o")))
#     (loop for x in *mini-universe*
#           for s1 = (format nil "~:o" x)
#           for s2 = (let ((*print-base* 8)) (format nil "~A" x))
#           for s3 = (formatter-call-to-string fn x)
#           unless (or (integerp x) (and (string= s1 s2) (string= s2 s3)))
#           collect (list x s1 s2 s3)))
#   nil)
# 
ok deftest( {
	my $fn = $*fl.formatter( Q{~:o} );
	for 1 .. 1000 {
#		my $x = 2 ** ( 2 + 80.rand.Int );
#		my $i = ( ( $x + $x ).rand - $x );
#		my $s1 = $*fl.format( Q{~B}, $i );
#		my $s2 = formatter-call-to-string( $fn, $i );
#		# XXX convert $s1 to base-10
	}
	@collected;
}, [ ]
), Q{format.o.19};
)

#`(
# (deftest format.o.20
#   (let ((fn (formatter "~@o")))
#     (loop for x in *mini-universe*
#           for s1 = (format nil "~@o" x)
#           for s2 = (let ((*print-base* 8)) (format nil "~A" x))
#           for s3 = (formatter-call-to-string fn x)
#           unless (or (integerp x) (and (string= s1 s2) (string= s2 s3)))
#           collect (list x s1 s2 s3)))
#   nil)
# 
ok deftest( {
	my $fn = $*fl.formatter( Q{~@o} );
	for 1 .. 1000 {
#		my $x = 2 ** ( 2 + 80.rand.Int );
#		my $i = ( ( $x + $x ).rand - $x );
#		my $s1 = $*fl.format( Q{~B}, $i );
#		my $s2 = formatter-call-to-string( $fn, $i );
#		# XXX convert $s1 to base-10
	}
}, [ ]
), Q{format.o.20};
)

#`(
# (deftest format.o.21
#   (let ((fn (formatter "~:@o")))
#     (loop for x in *mini-universe*
#           for s1 = (let ((*print-base* 8)) (format nil "~A" x))
#           for s2 = (format nil "~@:o" x)
#           for s3 = (formatter-call-to-string fn x)
#           for s4 = (let ((*print-base* 8)) (format nil "~A" x))
#           unless (or (integerp x) (and (string= s1 s2) (string= s2 s3))
#                      (string/= s1 s4))
#           collect (list x s1 s2 s3)))
#   nil)
# 
ok deftest( {
	my $fn = $*fl.formatter( Q{~:@o} );
	for 1 .. 1000 {
#		my $x = 2 ** ( 2 + 80.rand.Int );
#		my $i = ( ( $x + $x ).rand - $x );
#		my $s1 = $*fl.format( Q{~B}, $i );
#		my $s2 = formatter-call-to-string( $fn, $i );
#		# XXX convert $s1 to base-10
	}
}, [ ]
), Q{format.o.20};
)

# ;;; Must add tests for non-integers when the parameters
# ;;; are specified, but it's not clear what the meaning is.
# ;;; Does mincol apply to the ~A equivalent?  What about padchar?
# ;;; Are comma-char and comma-interval always ignored?
# 
# ;;; # arguments
# 
#`(
# (deftest format.o.22
#   (apply
#    #'values
#    (let ((fn (formatter "~#o"))
#          (n #o12345))
#      (loop for i from 0 to 10
#            for args = (make-list i)
#            for s = (apply #Q{format nil "~#o" n args)
#            for s2 = (with-output-to-string
#                       (stream)
#                       (assert (equal (apply fn stream n args) args)))
#            do (assert (string= s s2))
#            collect s)))
#   "12345"
#   "12345"
#   "12345"
#   "12345"
#   "12345"
#   " 12345"
#   "  12345"
#   "   12345"
#   "    12345"
#   "     12345"
#   "      12345")
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
	@collected;
},
[	Q{12345},
	Q{12345},
	Q{12345},
	Q{12345},
	Q{12345},
	Q{ 12345},
	Q{  12345},
	Q{   12345},
	Q{    12345},
	Q{     12345},
	Q{      12345}
]
), Q{format.o.22};
)

#`(
# (deftest format.o.23
#   (apply
#    #'values
#    (let ((fn (formatter "~,,,#:o"))
#          (n #o1234567012))
#      (loop for i from 0 to 10
#            for args = (make-list i)
#            for s = (apply #Q{format nil "~,,,#:o" n args)
#            for s2 = (with-output-to-string
#                       (stream)
#                       (assert (equal (apply fn stream n args) args)))
#            do (assert (string= s s2))
#            collect s)))
#   "1,2,3,4,5,6,7,0,1,2"
#   "12,34,56,70,12"
#   "1,234,567,012"
#   "12,3456,7012"
#   "12345,67012"
#   "1234,567012"
#   "123,4567012"
#   "12,34567012"
#   "1,234567012"
#   "1234567012"
#   "1234567012")
# 
ok deftest( {
	my @collected;
	my $fn = $*fl.formatter( Q{~#O} );
	my $n = 0o1234567012;
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
), Q{format.o.23};
)

#`(
# (deftest format.o.24
#   (apply
#    #'values
#    (let ((fn (formatter "~,,,#:@o"))
#          (n #o1234567012))
#      (loop for i from 0 to 10
#            for args = (make-list i)
#            for s = (apply #Q{format nil "~,,,#@:O" n args)
#            for s2 = (with-output-to-string
#                       (stream)
#                       (assert (equal (apply fn stream n args) args)))
#            do (assert (string= s s2))
#            collect s)))
#   "+1,2,3,4,5,6,7,0,1,2"
#   "+12,34,56,70,12"
#   "+1,234,567,012"
#   "+12,3456,7012"
#   "+12345,67012"
#   "+1234,567012"
#   "+123,4567012"
#   "+12,34567012"
#   "+1,234567012"
#   "+1234567012"
#   "+1234567012")
# 
ok deftest( {
	my @collected;
	my $fn = $*fl.formatter( Q{~#B} );
	my $n = 0o1234567012;
	for 0 .. 10 -> $i {
#		my @args = 
##		my $s = $*fl.format( Q{~v,,2A}, $i, 'ABC' );
#		my $s2 = formatter-call-to-string( $fn, $i, 'ABC' );
#		is $s, $s2;
#		@collected.append( $s );
	}
	@collected;
}, [	Q{+1,2,3,4,5,6,7,0,1,2},
	Q{+12,34,56,70,12},
	Q{+1,234,567,012},
	Q{+12,3456,7012},
	Q{+12345,67012},
	Q{+1234,567012},
	Q{+123,4567012},
	Q{+12,34567012},
	Q{+1,234567012},
	Q{+1234567012},
	Q{+1234567012},
]
), Q{format.o.24};
)

#`(
# (def-format-test format.o.25
#   "~+10o" (#o1234) "      1234")
# 
ok def-format-test( Q{~+10o}, ( 0o1234 ), Q{      1234} ), Q{format.o.25};
)

#`(
# (def-format-test format.o.26
#   "~+10@O" (#o1234) "     +1234")
# 
ok def-format-test( Q{~+10@o}, ( 0o1234 ), Q{     +1234} ), Q{format.o.26};
)

#`(
# (def-format-test format.o.27
#   "~-1O" (#o1234) "1234")
# 
ok def-format-test( Q{~-1O}, ( 0o1234 ), Q{1234} ), Q{format.o.27};
)

#`(
# (def-format-test format.o.28
#   "~-1000000000000000000o" (#o1234) "1234")
# 
ok def-format-test(
	Q{~-1000000000000000000o}, ( 0o1234 ), Q{1234}
), Q{format.o.28};
)

# (def-format-test format.o.29
#   "~vo" ((1- most-negative-fixnum) #o1234) "1234")
# 
# XXX Don't think it's applicable?

# ;;; Randomized test
# 
#`(
# (deftest format.o.30
#   (let ((fn (formatter "~v,v,v,vo")))
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
#                 (if commaint (format nil "~do" commaint) "o"))
#      for s1 = (format nil fmt x)
#      for s2 = (format nil "~v,v,v,vo" mincol padchar commachar commaint x)
#      for s3 = (formatter-call-to-string fn mincol padchar commachar commaint x)
#      repeat 2000
#      unless (and (string= s1 s2) (string= s2 s3))
#      collect (list mincol padchar commachar commaint fmt x s1 s2 s3)))
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
	@collected;
}, [ ]
), Q{format.o.30};
)

done-testing;

# vim: ft=perl6
