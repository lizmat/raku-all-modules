use v6;

use Test;
use lib 't/lib';
use Utils;
use Format::Lisp;

my $*fl = Format::Lisp.new;

# (def-format-test format.cond.1
#   "~[~]" (0) "")
# 
ok def-format-test( Q{~[~]}, ( 0 ), Q{} ), Q{format.cond.1};

# (def-format-test format.cond.2
#   "~[a~]" (0) "a")
# 
ok def-format-test( Q{~[a~]}, ( 0 ), Q{a} ), Q{format.cond.2};

# (def-format-test format.cond.3
#   "~[a~]" (-1) "")
# 
ok def-format-test( Q{~[a~]}, ( -1 ), Q{} ), Q{format.cond.3};

# (def-format-test format.cond.4
#   "~[a~]" ((1- most-negative-fixnum)) "")
# 
# XXX Don't think it's applicable?

# (def-format-test format.cond.5
#   "~[a~]" (1) "")
# 
ok def-format-test( Q{~[a~]}, ( 1 ), Q{} ), Q{format.cond.5};

# (def-format-test format.cond.6
#   "~[a~]" ((1+ most-positive-fixnum)) "")
# 
# XXX Don't think it's applicable?

#`(
# (deftest format.cond.7
#   (loop for i from -1 to 10
#         collect (format nil "~[a~;b~;c~;d~;e~;f~;g~;h~;i~]" i))
#   ("" "a" "b" "c" "d" "e" "f" "g" "h" "i" "" ""))
# 
ok deftest( {
	my @collected;
	for -1 .. 10 -> $i {
		@collected.append(
			$*fl.format( Q{~[a~;b~;c~;d~;e~;f~;g~;h~;i~]}, $i )
		);
	}
	@collected;
},
[ Q{}, Q{a}, Q{b}, Q{c}, Q{d}, Q{e}, Q{f}, Q{g}, Q{h}, Q{i}, Q{}, Q{} ],
), Q{format.cond.7};
)

#`(
# (deftest formatter.cond.7
#   (let ((fn (formatter "~[a~;b~;c~;d~;e~;f~;g~;h~;i~]")))
#     (loop for i from -1 to 10
#           collect (formatter-call-to-string fn i)))
#   ("" "a" "b" "c" "d" "e" "f" "g" "h" "i" "" ""))
# 
ok deftest( {
	my $fn = $*fl.formatter( Q{~[a~;b~;c~;d~;e~;f~;g~;h~;i~] );
	my @collected;
	for -1 .. 10 -> $i {
		@collected.append( formatter-call-to-string( $fn, $i ) );
	}
	@collected;
},
[ Q{}, Q{a}, Q{b}, Q{c}, Q{d}, Q{e}, Q{f}, Q{g}, Q{h}, Q{i}, Q{}, Q{} ]
), Q{format.cond.7};
)

#`(
# (def-format-test format.cond.8
#   "~0[a~;b~;c~;d~]" (3) "a" 1)
# 
ok def-format-test( Q{~0[a~;b~;c~;d~]}, ( 3 ), Q{a}, 1 ), Q{format.cond.8};
)

# (def-format-test format.cond.9
#   "~-1[a~;b~;c~;d~]" (3) "" 1)
# 
ok def-format-test( Q{~-1[a~;b~;c~;d~]}, ( 3 ), Q{}, 1 ), Q{format.cond.9};

#`(
# (def-format-test format.cond.10
#   "~1[a~;b~;c~;d~]" (3) "b" 1)
# 
ok def-format-test( Q{~1[a~;b~;c~;d~]}, ( 3 ), Q{b}, 1 ), Q{format.cond.10};
)

# (def-format-test format.cond.11
#   "~4[a~;b~;c~;d~]" (3) "" 1)
# 
ok def-format-test( Q{~4[a~;b~;c~;d~]}, ( 3 ), Q{}, 1 ), Q{format.cond.11};

# (def-format-test format.cond.12
#   "~100000000000000000000000000000000[a~;b~;c~;d~]" (3) "" 1)
# 
ok def-format-test(
	Q{~100000000000000000000000000000000[a~;b~;c~;d~]}, ( 3 ), Q{}
), Q{format.cond.12};

#`(
# (deftest format.cond.13
#   (loop for i from -1 to 10
#         collect (format nil "~v[a~;b~;c~;d~;e~;f~;g~;h~;i~]" i nil))
#   ("" "a" "b" "c" "d" "e" "f" "g" "h" "i" "" ""))
# 
ok deftest( {
	my @collected;
	for -1 .. 10 -> $i {
		@collected.append(
			$*fl.format( Q{~v[a~;b~;c~;d~;e~;f~;g~;h~;i~]}, $i, Nil )
		);
	}
	@collected;
},
[ Q{}, Q{a}, Q{b}, Q{c}, Q{d}, Q{e}, Q{f}, Q{g}, Q{h}, Q{i}, Q{}, Q{} ],
), Q{format.cond.13};
)

#`(
# (deftest formatter.cond.13
#   (let ((fn (formatter "~V[a~;b~;c~;d~;e~;f~;g~;h~;i~]")))
#     (loop for i from -1 to 10
#           collect (formatter-call-to-string fn i)))
#   ("" "a" "b" "c" "d" "e" "f" "g" "h" "i" "" ""))
# 
ok deftest( {
	my $fn = $*fl.formatter( Q{~V[a~;b~;c~;d~;e~;f~;g~;h~;i~]} );
	my @collected;
	for -1 .. 10 -> $i {
		@collected.append( formatter-call-to-string( $fn, $i ) );
	}
	@collected;
},
[ Q{}, Q{a}, Q{b}, Q{c}, Q{d}, Q{e}, Q{f}, Q{g}, Q{h}, Q{i}, Q{}, Q{} ],
),  Q{formatter.cond.13};
)

#`(
# (deftest format.cond.14
#   (loop for i from -1 to 10
#         collect (format nil "~v[a~;b~;c~;d~;e~;f~;g~;h~;i~]" nil i))
#   ("" "a" "b" "c" "d" "e" "f" "g" "h" "i" "" ""))
# 
ok deftest( {
	my @collected;
	for -1 .. 10 -> $i {
		@collected.append(
			$*fl.format( Q{~v[a~;b~;c~;d~;e~;f~;g~;h~;i~]}, Nil, $i )
		);
	}
	@collected;
},
[ Q{}, Q{a}, Q{b}, Q{c}, Q{d}, Q{e}, Q{f}, Q{g}, Q{h}, Q{i}, Q{}, Q{} ],
), Q{format.cond.13};
)

#`(
# (deftest formatter.cond.14
#   (let ((fn (formatter "~v[a~;b~;c~;d~;e~;f~;g~;h~;i~]")))
#     (loop for i from -1 to 10
#           collect (formatter-call-to-string fn nil i)))
#   ("" "a" "b" "c" "d" "e" "f" "g" "h" "i" "" ""))
#  
ok deftest( {
	my $fn = $*fl.formatter( "~v[a~;b~;c~;d~;e~;f~;g~;h~;i~]" );
	my @collected;
	for -1 .. 10 -> $i {
		@collected.append( formatter-call-to-string( $fn, Nil, $i ) );
	}
	@collected;
},
[ Q{}, Q{a}, Q{b}, Q{c}, Q{d}, Q{e}, Q{f}, Q{g}, Q{h}, Q{i}, Q{}, Q{} ],
), Q{formatter.cond.14};
)

#`(
# (def-format-test format.cond.15
#   "~#[A~;B~]" nil "A")
# 
ok def-format-test( Q{~#[A~;B~]}, ( ), Q{A} ), Q{format.cond.15};
)

#`(
# (def-format-test format.cond.16
#   "~#[A~;B~]" (nil) "B" 1)
# 
ok def-format-test( Q{~#[A~;B~]}, ( Nil ), Q{B}, 1 ), Q{format.cond.16};
)

subtest {
	1;
	#`(
	# (deftest format.cond\:.1
	#   (loop for i from -100 to 100
	#         for s = (format nil "~[~:;a~]" i)
	#         unless (or (zerop i) (string= s "a"))
	#         collect (list i s))
	#   nil)
	# 
	ok deftest( {
		my @collected;
		for -100 .. 100 -> $i {
			my $s = $*fl.format( Q{~[~:;a~]}, $i );
			unless $i == 0 or $s eq Q{a} {
				@collected.append( [ $i, $s ] );
			}
		}
		@collected;
	},
	[ ]
	), Q{format.cond:.1};
	)

	#`(
	# (deftest formatter.cond\:.1
	#   (let ((fn (formatter "~[~:;a~]")))
	#     (loop for i from -100 to 100
	#           for s = (formatter-call-to-string fn i)
	#           unless (or (zerop i) (string= s "a"))
	#           collect (list i s)))
	#   nil)
	# 
	ok deftest( {
		my $fn = $*fl.formatter( Q{~[~:;a~]} );
		my @collected;
		for -100 .. 100 -> $i {
			my $s = formatter-call-to-string( $fn, $i );
			unless $i == 0 or $s eq Q{a} {
				@collected.append( [ $i, $s ] );
			}
		}
		@collected;
	},
	[ ]
	), Q{formatter.cond:.1};
	)

	#`(
	# (def-format-test format.cond\:.2
	#   "~[a~:;b~]" (0) "a")
	# 
	ok def-format-test( Q{~[a~:;b~]}, ( 0 ), Q{a} ), Q{format.cond:.2};
	)

	# (def-format-test format.cond\:.3
	#   "~[a~:;b~]" ((1- most-negative-fixnum)) "b")
	# 
	# XXX Don't think it's applicable?

	# (def-format-test format.cond\:.4
	#   "~[a~:;b~]" ((1+ most-positive-fixnum)) "b")
	# 
	# XXX Don't think it's applicable?

	#`(
	# (deftest format.cond\:.5
	#   (loop for i from -1 to 10
	#         collect (format nil "~[a~;b~;c~;d~:;e~]" i))
	#   ("e" "a" "b" "c" "d" "e" "e" "e" "e" "e" "e" "e"))
	# 
	ok deftest( {
		my @collected;
		for -1 .. 10 -> $i {
			@collected.append(
				$*fl.format( Q{~[a~;b~;c~;d~:;e~]}, $i )
			);
		}
		@collected;
	},
	[ Q{e}, Q{a}, Q{b}, Q{c}, Q{d}, Q{e}, Q{e},
	  Q{e}, Q{e}, Q{e}, Q{e}, Q{e} ]
	), Q{format.cond.5};
	)

	#`(
	# (deftest formatter.cond\:.5
	#   (let ((fn (formatter "~[a~;b~;c~;d~:;e~]")))
	#     (loop for i from -1 to 10
	#           collect (formatter-call-to-string fn i)))
	#   ("e" "a" "b" "c" "d" "e" "e" "e" "e" "e" "e" "e"))
	# 
	ok deftest( {
		my $fn = $*fl.formatter( "~[a~;b~;c~;d~:;e~]" );
		my @collected;
		for -1 .. 10 -> $i {
			@collected.append(
				formatter-call-to-string( $fn, $i )
			);
		}
		@collected;
	},
	[ Q{e}, Q{a}, Q{b}, Q{c}, Q{d}, Q{e}, Q{e},
	  Q{e}, Q{e}, Q{e}, Q{e}, Q{e} ]
	), Q{formatter.cond.5};
	)

	#`(
	# (deftest format.cond\:.6
	#   (loop for i from -1 to 10
	#         collect (format nil "~v[a~;b~;c~;d~:;e~]" i nil))
	#   ("e" "a" "b" "c" "d" "e" "e" "e" "e" "e" "e" "e"))
	# 
	ok deftest( {
		my @collected;
		for -1 .. 10 -> $i {
			@collected.append(
				$*fl.format( Q{~v[a~;b~;c~;d~:;e~]}, $i, Nil )
			);
		}
		@collected;
	},
	[ Q{e}, Q{a}, Q{b}, Q{c}, Q{d}, Q{e}, Q{e},
	  Q{e}, Q{e}, Q{e}, Q{e}, Q{e} ]
	), Q{format.cond:.6};
	)

	#`(
	# (deftest formatter.cond\:.6
	#   (let ((fn (formatter "~v[a~;b~;c~;d~:;e~]")))
	#     (loop for i from -1 to 10
	#           collect (formatter-call-to-string fn i)))
	#   ("e" "a" "b" "c" "d" "e" "e" "e" "e" "e" "e" "e"))
	# 
	ok deftest( {
		my $fn = $*fl.formatter( "~v[a~;b~;c~;d~:;e~]" );
		my @collected;
		for -1 .. 10 -> $i {
			@collected.append(
				formatter-call-to-string( $fn, $i )
			);
		}
		@collected;
	},
	[ Q{e}, Q{a}, Q{b}, Q{c}, Q{d}, Q{e}, Q{e},
	  Q{e}, Q{e}, Q{e}, Q{e}, Q{e} ]
	), Q{formatter.cond:.6};
	)

	#`(
	# (deftest format.cond\:.7
	#   (loop for i from -1 to 10
	#         collect (format nil "~v[a~;b~;c~;d~:;e~]" nil i))
	#   ("e" "a" "b" "c" "d" "e" "e" "e" "e" "e" "e" "e"))
	# 
	ok deftest( {
		my @collected;
		for -1 .. 10 -> $i {
			@collected.append(
				$*fl.format( Q{~v[a~;b~;c~;d~:;e~]}, Nil, $i )
			);
		}
		@collected;
	},
	[ Q{e}, Q{a}, Q{b}, Q{c}, Q{d}, Q{e}, Q{e},
	  Q{e}, Q{e}, Q{e}, Q{e}, Q{e} ]
	), Q{format.cond:.7};
	)

	#`(
	# (deftest formatter.cond\:.7
	#   (let ((fn (formatter "~v[a~;b~;c~;d~:;e~]")))
	#     (loop for i from -1 to 10
	#           collect (formatter-call-to-string fn nil i)))
	#   ("e" "a" "b" "c" "d" "e" "e" "e" "e" "e" "e" "e"))
	# 
	ok deftest( {
		my $fn = $*fl.formatter( "~v[a~;b~;c~;d~:;e~]" );
		my @collected;
		for -1 .. 10 -> $i {
			@collected.append(
				formatter-call-to-string( $fn, Nil, $i )
			);
		}
		@collected;
	},
	[ Q{e}, Q{a}, Q{b}, Q{c}, Q{d}, Q{e},
	  Q{e}, Q{e}, Q{e}, Q{e}, Q{e}, Q{e} ]
	), Q{formatter.cond:.7};
	)

	#`(
	# (def-format-test format.cond\:.8
	#   "~#[A~:;B~]" nil "A")
	# 
	ok def-format-test( Q{~#[A~:;B~]}, ( ), Q{A} ), Q{format.cond:.8};
	)

	#`(
	# (def-format-test format.cond\:.9
	#   "~#[A~:;B~]" (nil nil) "B" 2) 
	# 
	ok def-format-test(
		Q{~#[A~:;B~]}, ( Nil, Nil ), Q{B}, 2
	), Q{format.cond:.9};
	)
}, Q{~[ .~:;  ~]};

subtest {
	1;
	#`(
	# (def-format-test format.\:cond.1
	#   "~:[a~;b~]" (nil) "a")
	# 
	ok def-format-test( Q{~#:a~;b~]}, ( Nil ), Q{a} ), Q{format.:cond.1};
	)

	#`(
	# (deftest format.\:cond.2
	#   (loop for x in *mini-universe*
	#         for s = (format nil "~:[a~;b~]" x)
	#         when (and x (not (string= s "b")))
	#         collect (list x s))
	#   nil)
	# 
	ok deftest( {
		die; # mini-univere isn't finished
		my @collected;
		for @mini-universe -> $x {
			my $s = $*fl.format( Q{~:[a~;b~]}, $x );
			if $x and $s ne Q{b} {
				@collected.append( [ $x, $s ] );
			}
		}
		@collected;
	},
	[ ]
	), Q{format.:cond.2};
	)

	#`(
	# (deftest formatter.\:cond.2
	#   (let ((fn (formatter "~:[a~;b~]")))
	#     (loop for x in *mini-universe*
	#           for s = (formatter-call-to-string fn x)
	#           when (and x (not (string= s "b")))
	#           collect (list x s)))
	#   nil)
	# 
	ok deftest( {
		my $fn = $*fl.formatter( "~:[a~;b~]" );
		die; # mini-univere isn't finished
		my @collected;
		for @mini-universe -> $x {
			my $s = formatter-call-to-string( $fn, $x );
			if $x and $s ne Q{b} {
				@collected.append( [ $x, $s ] );
			}
		}
		@collected;
	},
	[ ]
	), Q{format.:cond.2};
	)
}, Q{~:[...~]};

subtest {
	1;
	#`(
	# (def-format-test format.@cond.1
	#   "~@[X~]Y~A" (1) "XY1")
	# 
	ok def-format-test( Q{~@[X~]Y~A}, ( 1 ), Q{XY1}), Q{format.@cond.1};
	)

	#`(
	# (def-format-test format.@cond.2
	#   "~@[X~]Y~A" (nil 2) "Y2")
	# 
	ok def-format-test( Q{~@[X~]Y~A}, ( Nil, 2 ), Q{Y2}), Q{format.@cond.2};
	)
}, Q{~@[ ... ~]};

done-testing;

# vim: ft=perl6
