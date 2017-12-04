use v6;

use Test;
use lib 't/lib';
use Utils;
use Format::Lisp;

my $*fl = Format::Lisp.new;

subtest {
	is $*fl.format( Q{~a}, Q{abc} ), Q{abc}, Q{non-nil};

	is $*fl.format( Q{~@:a}, Nil ), Q{()}, Q{nil};

	is $*fl.format( Q{~@:a}, Q{abc} ), Q{abc}, Q{abc};

	is $*fl.format( Q{~~~d@a}, 4 ), Q{~4@a}, Q{format.a.9.slice};
	is $*fl.format( Q{~4@a}, Nil ), Q{ NIL}, Q{format.a.9.slice.2};

	is $*fl.format( Q{~4a}, Nil ), Q{NIL }, Q{format.a.10.slice};

	is $*fl.format( Q{~4@:a}, Nil ), Q{  ()}, Q{format.a.11.slice};

	is $*fl.format( Q{~4:a}, Nil ), Q{()  }, Q{format.a.12.slice};

	is $*fl.format( Q{~V:a}, 3, Nil ), Q{() }, Q{format.a.13.slice};

	is $*fl.format( Q{~V@:a}, 3, Nil ), Q{ ()}, Q{format.a.14.slice};

	is $*fl.format( Q{~v,,2a}, 3, Q{ABC} ), Q{ABC  }, Q{format.a.29.slice};
	is $*fl.format(
		Q{~v,,2A}, 4, Q{ABC}
	), Q{ABC  }, Q{format.a.29 regression};

	is $*fl.format( Q{~3,,vA}, 1, Q{ABC} ), Q{ABC }, Q{format.a.44.slice};

	is $*fl.format( Q{~3,,v@A}, 1, Q{ABC} ), Q{ ABC}, Q{format.a.44a.slice};
}, Q{missing coverage};

# (def-format-test format.a.1
#   "~a" (nil) "NIL")
# 
ok def-format-test( Q{~a}, ( Nil ), Q{NIL} ), Q{format.a.1};

# (deftest format.a.2
#   (with-standard-io-syntax
#    (let ((*print-case* :downcase))
#      (format nil "~A" nil)))
#   "nil")
# 
ok deftest( {
	my $*PRINT-CASE = Q{downcase};
	$*fl.format( Q{~A}, Nil );
}, Q{nil}
), Q{format.a.2};

# (deftest formatter.a.2
#   (with-standard-io-syntax
#    (let ((*print-case* :downcase))
#      (formatter-call-to-string (formatter "~A") nil)))
#   "nil")
# 
ok deftest( {
	my $*PRINT-CASE = Q{downcase};
	formatter-call-to-string( $*fl.formatter( Q{~A} ), Nil );
}, Q{nil}
), Q{formatter.a.2};

# (deftest format.a.3
#   (with-standard-io-syntax
#    (let ((*print-case* :capitalize))
#      (format nil "~a" nil)))
#   "Nil")
# 
ok deftest( {
	my $*PRINT-CASE = Q{capitalize};
	$*fl.format( Q{~a}, Nil );
}, Q{Nil}
), Q{format.a.3};

# (deftest formatter.a.3
#   (with-standard-io-syntax
#    (let ((*print-case* :capitalize))
#      (formatter-call-to-string (formatter "~a") nil)))
#   "Nil")
# 
ok deftest( {
	my $*PRINT-CASE = Q{capitalize};
	formatter-call-to-string( $*fl.formatter( Q{~a} ), Nil );
}, Q{Nil}
), Q{formatter.a.3};

# (def-format-test format.a.4
#   "~:a" (nil) "()")
# 
ok def-format-test( Q{~:a}, ( Nil ), Q{()} ), Q{format.a.4};

#`(
# (def-format-test format.a.5
#   "~:A" ('(nil)) "(NIL)")
# 
ok def-format-test( Q{~:A}, ( [ Nil ] ), Q{(NIL)} ), Q{format.a.5};
)

# (def-format-test format.a.6
#   "~:A" (#(nil)) "#(NIL)")
# 
# Maybe this would be []?

# (deftest format.a.7
#   (let ((fn (formatter "~a")))
#     (loop for c across +standard-chars+
#           for s1 = (string c)
#           for s2 = (format nil "~a" s1)
#           for s3 = (formatter-call-to-string fn s1)
#           unless (and (string= s1 s2) (string= s2 s3))
#           collect (list c s1 s2 s3)))
#   nil)
# 
ok deftest( {
	my $fn = $*fl.formatter( Q{~a} );
	my @collected;
	for @standard-chars -> $c {
		my $s1 = $c;
		my $s2 = $*fl.format( Q{~a}, $s1 );
		my $s3 = formatter-call-to-string( $fn, $s1 );
		unless $s1 eq $s1 and $s2 eq $s3 {
			@collected.append( [ $c, $s1, $s2, $s3 ] );
		}
	}
	@collected;
}, [ ]
), Q{format.a.7};

# (deftest format.a.8
#   (let ((fn (formatter "~A")))
#     (loop with count = 0
#           for i from 0 below (min #x10000 char-code-limit)
#           for c = (code-char i)
#           for s1 = (and c (string c))
#           for s2 = (and c (format nil "~A" s1))
#           for s3 = (and c (formatter-call-to-string fn s1))
#           unless (or (null c) (string= s1 s2) (string= s2 s3))
#           do (incf count) and collect (list c s1 s2 s3)
#           when (> count 100) collect "count limit exceeded" and do (loop-finish)))
#   nil)
# 
ok deftest( {
	my $fn = $*fl.formatter( Q{~A} );
	my @collected;
	my $i = 0;
	loop ( my $count = 0 ; ; ) {
		last if $i < 0x10000 min $CHAR-CODE-LIMIT;
		my $c = $i.chr;
		my $s1 = $c;
		my $s2 = $*fl.format( Q{~A}, $s1 );
		my $s3 = formatter-call-to-string( $fn, $s1 );
		unless $c ~~ Nil or $s1 eq $s2 or $s2 eq $s3 {
			$count++;
			@collected.append( [ $c, $s1, $s2, $s3 ] );
		}
		if $count > 100 {
			@collected.append( Q{count limit exceeded} );
			last;
		}
	}
	@collected;
}, [ ]
), Q{format.a.8};

# (deftest format.a.9
#   (with-standard-io-syntax
#    (apply
#     #'values
#     (loop for i from 1 to 10
#           for fmt = (format nil "~~~d@a" i)
#           for s = (format nil fmt nil)
#           for fn = (eval `(formatter ,fmt))
#           for s2 = (formatter-call-to-string fn nil)
#           do (assert (string= s s2))
#           collect s)))
#   "NIL"
#   "NIL"
#   "NIL"
#   " NIL"
#   "  NIL"
#   "   NIL"
#   "    NIL"
#   "     NIL"
#   "      NIL"
#   "       NIL")
# 
ok deftest( {
	my @collected;
	for 1 .. 10 -> $i {
		my $fmt = $*fl.format( Q{~~~d@a}, $i );
		my $s = $*fl.format( $fmt, Nil );
		my $fn = $*fl.formatter( $fmt );
		my $s2 = formatter-call-to-string( $fn, Nil );
		is $s, $s2;
		@collected.append( $s );
	}
	@collected;
}, [	Q{NIL},
	Q{NIL},
	Q{NIL},
	Q{ NIL},
	Q{  NIL},
	Q{   NIL},
	Q{    NIL},
	Q{     NIL},
	Q{      NIL},
	Q{       NIL}
]
), Q{format.a.9};

# (deftest format.a.10
#   (with-standard-io-syntax
#    (apply
#     #'values
#     (loop for i from 1 to 10
#           for fmt = (format nil "~~~da" i)
#           for s = (format nil fmt nil)
#           for fn = (eval `(formatter ,fmt))
#           for s2 = (formatter-call-to-string fn nil)
#           do (assert (string= s s2))
#           collect s)))
#   "NIL"
#   "NIL"
#   "NIL"
#   "NIL "
#   "NIL  "
#   "NIL   "
#   "NIL    "
#   "NIL     "
#   "NIL      "
#   "NIL       ")
# 
ok deftest( {
	my @collected;
	for 1 .. 10 -> $i {
		my $fmt = $*fl.format( Q{~~~da}, $i );
		my $s = $*fl.format( $fmt, Nil );
		my $fn = $*fl.formatter( $fmt );
		my $s2 = formatter-call-to-string( $fn, Nil );
		is $s, $s2;
		@collected.append( $s );
	}
	@collected;
}, [	Q{NIL},
	Q{NIL},
	Q{NIL},
	Q{NIL },
	Q{NIL  },
	Q{NIL   },
	Q{NIL    },
	Q{NIL     },
	Q{NIL      },
	Q{NIL       }
]
), Q{format.a.10};

# (deftest format.a.11
#   (with-standard-io-syntax
#    (apply
#     #'values
#     (loop for i from 1 to 10
#           for fmt = (format nil "~~~d@:A" i)
#           for s = (format nil fmt nil)
#           for fn = (eval `(formatter ,fmt))
#           for s2 = (formatter-call-to-string fn nil)
#           do (assert (string= s s2))
#           collect s)))
#   "()"
#   "()"
#   " ()"
#   "  ()"
#   "   ()"
#   "    ()"
#   "     ()"
#   "      ()"
#   "       ()"
#   "        ()")
# 
ok deftest( {
	my @collected;
	for 1 .. 10 -> $i {
		my $fmt = $*fl.format( Q{~~~d@:A}, $i );
		my $s = $*fl.format( $fmt, Nil );
		my $fn = $*fl.formatter( $fmt );
		my $s2 = formatter-call-to-string( $fn, Nil );
		is $s, $s2;
		@collected.append( $s );
	}
	@collected;
}, [	Q{()},
	Q{()},
	Q{ ()},
	Q{  ()},
	Q{   ()},
	Q{    ()},
	Q{     ()},
	Q{      ()},
	Q{       ()},
	Q{        ()}
]
), Q{format.a.11};

# (deftest format.a.12
#   (with-standard-io-syntax
#    (apply
#     #'values
#     (loop for i from 1 to 10
#           for fmt = (format nil "~~~d:a" i)
#           for s = (format nil fmt nil)
#           for fn = (eval `(formatter ,fmt))
#           for s2 = (formatter-call-to-string fn nil)
#           do (assert (string= s s2))
#           collect s)))
#   "()"
#   "()"
#   "() "
#   "()  "
#   "()   "
#   "()    "
#   "()     "
#   "()      "
#   "()       "
#   "()        ")
# 
ok deftest( {
	my @collected;
	for 1 .. 10 -> $i {
		my $fmt = $*fl.format( Q{~~~d:a}, $i );
		my $s = $*fl.format( $fmt, Nil );
		my $fn = $*fl.formatter( $fmt );
		my $s2 = formatter-call-to-string( $fn, Nil );
		is $s, $s2;
		@collected.append( $s );
	}
	@collected;
}, [	Q{()},
	Q{()},
	Q{() },
	Q{()  },
	Q{()   },
	Q{()    },
	Q{()     },
	Q{()      },
	Q{()       },
	Q{()        }
]
), Q{format.a.12};

# (deftest format.a.13
#   (with-standard-io-syntax
#    (apply
#     #'values
#     (let ((fn (formatter "~V:a")))
#       (loop for i from 1 to 10
#             for s = (format nil "~v:A" i nil)
#             for s2 = (formatter-call-to-string fn i nil)
#             do (assert (string= s s2))
#             collect s))))
#   "()"
#   "()"
#   "() "
#   "()  "
#   "()   "
#   "()    "
#   "()     "
#   "()      "
#   "()       "
#   "()        ")
# 
ok deftest( {
	my @collected;
	my $fn = $*fl.formatter( Q{~V:a} );
	for 1 .. 10 -> $i {
		my $s = $*fl.format( Q{~v:A}, $i, Nil );
		my $s2 = formatter-call-to-string( $fn, $i, Nil );
		is $s, $s2;
		@collected.append( $s );
	}
	@collected;
}, [	Q{()},
	Q{()},
	Q{() },
	Q{()  },
	Q{()   },
	Q{()    },
	Q{()     },
	Q{()      },
	Q{()       },
	Q{()        }
]
), Q{format.a.13};

# (deftest format.a.14
#   (with-standard-io-syntax
#    (apply
#     #'values
#     (let ((fn (formatter "~V@:A")))
#       (loop for i from 1 to 10
#             for s = (format nil "~v:@a" i nil)
#             for s2 = (formatter-call-to-string fn i nil)
#             do (assert (string= s s2))
#             collect s))))
#   "()"
#   "()"
#   " ()"
#   "  ()"
#   "   ()"
#   "    ()"
#   "     ()"
#   "      ()"
#   "       ()"
#   "        ()")
# 
ok deftest( {
	my @collected;
	my $fn = $*fl.formatter( Q{~V@:A} );
	for 1 .. 10 -> $i {
		my $s = $*fl.format( Q{~v:@A}, $i, Nil );
		my $s2 = formatter-call-to-string( $fn, $i, Nil );
		is $s, $s2;
		@collected.append( $s );
	}
	@collected;
}, [	Q{()},
	Q{()},
	Q{ ()},
	Q{  ()},
	Q{   ()},
	Q{    ()},
	Q{     ()},
	Q{      ()},
	Q{       ()},
	Q{        ()},
]
), Q{format.a.14};

# (def-format-test format.a.15
#   "~vA" (nil nil) "NIL")
# 
ok def-format-test( Q{~vA}, ( Nil, Nil ), Q{NIL} ), Q{format.a.15};

# (def-format-test format.a.16
#   "~v:A" (nil nil) "()")
# 
ok def-format-test( Q{~v:A}, ( Nil, Nil ), Q{()} ), Q{format.a.16};

# (def-format-test format.a.17
#   "~@A" (nil) "NIL")
# 
ok def-format-test( Q{~@A}, ( Nil ), Q{NIL} ), Q{format.a.17};

# (def-format-test format.a.18
#   "~v@A" (nil nil) "NIL")
# 
ok def-format-test( Q{~v@A}, ( Nil, Nil ), Q{NIL} ), Q{format.a.18};

# (def-format-test format.a.19
#   "~v:@a" (nil nil) "()")
# 
ok def-format-test( Q{~v:@a}, ( Nil, Nil ), Q{()} ), Q{format.a.19};

# (def-format-test format.a.20
#   "~v@:a" (nil nil) "()")
# 
ok def-format-test( Q{~v@:a}, ( Nil, Nil ), Q{()} ), Q{format.a.20};

subtest {
	# (def-format-test format.a.21
	#   "~3,1a" (nil) "NIL")
	# 
	ok def-format-test( Q{~3,1a}, ( Nil ), Q{NIL} ), Q{format.a.21};

	# (def-format-test format.a.22
	#   "~4,3a" (nil) "NIL   ")
	# 
	ok def-format-test( Q{~4,3a}, ( Nil ), Q{NIL   } ), Q{format.a.22};

	# (def-format-test format.a.23
	#   "~3,3@a" (nil) "NIL")
	# 
	ok def-format-test( Q{~3,3@A}, ( Nil ), Q{NIL} ), Q{format.a.23};

	# (def-format-test format.a.24
	#   "~4,4@a" (nil) "    NIL")
	# 
	ok def-format-test( Q{~4,4@A}, ( Nil ), Q{    NIL} ), Q{format.a.24};

	# (def-format-test format.a.25
	#   "~5,3@a" (nil) "   NIL")
	# 
	ok def-format-test( Q{~5,3@A}, ( Nil ), Q{   NIL} ), Q{format.a.25};

	# (def-format-test format.a.26
	#   "~5,3A" (nil) "NIL   ")
	# 
	ok def-format-test( Q{~5,3A}, ( Nil ), Q{NIL   } ), Q{format.a.26};

	# (def-format-test format.a.27
	#   "~7,3@a" (nil) "      NIL")
	# 
	ok def-format-test( Q{~7,3@A}, ( Nil ), Q{      NIL} ), Q{format.a.27};

	# (def-format-test format.a.28
	#   "~7,3A" (nil) "NIL      ")
	# 
	ok def-format-test( Q{~7,3A}, ( Nil ), Q{NIL      } ), Q{format.a.28};
}, Q{With colinc};

subtest {
	# (deftest format.a.29
	#   (let ((fn (formatter "~v,,2A")))
	#     (loop for i from -4 to 10
	#           for s = (format nil "~v,,2A" i "ABC")
	#           for s2 = (formatter-call-to-string fn i "ABC")
	#           do (assert (string= s s2))
	#           collect s))
	#   ("ABC  "
	#    "ABC  "
	#    "ABC  "
	#    "ABC  "
	#    "ABC  "
	#    "ABC  "
	#    "ABC  "
	#    "ABC  "
	#    "ABC  "
	#    "ABC  "
	#    "ABC   "
	#    "ABC    "
	#    "ABC     "
	#    "ABC      "
	#    "ABC       "))
	# 
	ok deftest( {
		my @collected;
		my $fn = $*fl.formatter( Q{~v,,2A} );
		for -4 .. 10 -> $i {
			my $s = $*fl.format( Q{~v,,2A}, $i, Q{ABC} );
			my $s2 = formatter-call-to-string( $fn, $i, Q{ABC} );
			is $s, $s2;
			@collected.append( $s );
		}
		@collected;
	}, [	Q{ABC  },
		Q{ABC  },
		Q{ABC  },
		Q{ABC  },
		Q{ABC  },
		Q{ABC  },
		Q{ABC  },
		Q{ABC  },
		Q{ABC  },
		Q{ABC  },
		Q{ABC   },
		Q{ABC    },
		Q{ABC     },
		Q{ABC      },
		Q{ABC       }
	]
	), Q{format.a.29};

	# (def-format-test format.a.30
	#   "~3,,+2A" ("ABC") "ABC  ")
	# 
	ok def-format-test( Q{~3,,+2A}, ( Q{ABC} ), Q{ABC  } ), Q{format.a.30};

	# (def-format-test format.a.31
	#   "~3,,0A" ("ABC") "ABC")
	# 
	ok def-format-test( Q{~3,,0A}, ( Q{ABC} ), Q{ABC} ), Q{format.a.31};

	# (def-format-test format.a.32
	#   "~3,,-1A" ("ABC") "ABC")
	# 
	ok def-format-test( Q{~3,,-1A}, ( Q{ABC} ), Q{ABC} ), Q{format.a.32};

	# (def-format-test format.a.33
	#   "~3,,0A" ("ABCD") "ABCD")
	# 
	ok def-format-test( Q{~3,,0A}, ( Q{ABCD} ), Q{ABCD} ), Q{format.a.33};

	# (def-format-test format.a.34
	#   "~3,,-1A" ("ABCD") "ABCD")
	# 
	ok def-format-test( Q{~3,,-1A}, ( Q{ABCD} ), Q{ABCD} ), Q{format.a.34};
}, Q{With minpad};

subtest {
	# (def-format-test format.a.35
	#   "~4,,,'XA" ("AB") "ABXX")
	# 
	ok def-format-test( Q{~4,,,'XA}, ( Q{AB} ), Q{ABXX} ), Q{format.a.35};

	# (def-format-test format.a.36
	#   "~4,,,a" ("AB") "AB  ")
	# 
	ok def-format-test( Q{~4,,,a}, ( Q{AB} ), Q{AB  } ), Q{format.a.36};

	# (def-format-test format.a.37
	#   "~4,,,'X@a" ("AB") "XXAB")
	# 
	ok def-format-test( Q{~4,,,'X@a}, ( Q{AB} ), Q{XXAB} ), Q{format.a.37};

	# (def-format-test format.a.38
	#   "~4,,,@A" ("AB") "  AB")
	# 
	ok def-format-test( Q{~4,,,@A}, ( Q{AB} ), Q{  AB} ), Q{format.a.38};

	# (def-format-test format.a.39
	#   "~10,,,vA" (nil "abcde") "abcde     ")
	# 
	ok def-format-test(
		Q{~10,,,vA}, ( Nil, Q{abcde} ), Q{abcde     }
	), Q{format.a.39};

	# (def-format-test format.a.40
	#   "~10,,,v@A" (nil "abcde") "     abcde")
	# 
	ok def-format-test(
		Q{~10,,,v@a}, ( Nil, Q{abcde} ), Q{     abcde}
	), Q{format.a.40};

	# (def-format-test format.a.41
	#   "~10,,,va" (#\* "abcde") "abcde*****")
	# 
	ok def-format-test(
		Q{~10,,,va}, ( Q{*}, Q{abcde} ), Q{abcde*****}
	), Q{format.a.41};

	# (def-format-test format.a.42
	#   "~10,,,v@a" (#\* "abcde") "*****abcde")
	# 
	ok def-format-test(
		Q{~10,,,v@a}, ( Q{*}, Q{abcde} ), Q{*****abcde}
	), Q{format.a.42};
}, Q{With padchar};

subtest {
	# (def-format-test format.a.43
	#   "~3,,vA" (nil "ABC") "ABC")
	# 
	ok def-format-test(
		Q{~3,,va}, ( Nil, Q{ABC} ), Q{ABC}
	), Q{format.a.43};

	# (deftest format.a.44
	#   (let ((fn (formatter "~3,,vA")))
	#     (loop for i from 0 to 6
	#           for s =(format nil "~3,,vA" i "ABC")
	#           for s2 = (formatter-call-to-string fn i "ABC")
	#           do (assert (string= s s2))
	#           collect s))
	#   ("ABC"
	#    "ABC "
	#    "ABC  "
	#    "ABC   "
	#    "ABC    "
	#    "ABC     "
	#    "ABC      "))
	# 
	ok deftest( {
		my @collected;
		my $fn = $*fl.formatter( Q{~3,,vA} );
		for 0 .. 6 -> $i {
			my $s = $*fl.format( Q{~3,,vA}, $i, Q{ABC} );
			my $s2 = formatter-call-to-string( $fn, $i, Q{ABC} );
			is $s, $s2;
			@collected.append( $s );
		}
		@collected;
	}, [	Q{ABC},
		Q{ABC },
		Q{ABC  },
		Q{ABC   },
		Q{ABC    },
		Q{ABC     },
		Q{ABC      }
	]
	), Q{format.a.44a};

	# (deftest format.a.44a
	#   (let ((fn (formatter "~3,,v@A")))
	#     (loop for i from 0 to 6
	#           for s = (format nil "~3,,v@A" i "ABC")
	#           for s2 = (formatter-call-to-string fn i "ABC")
	#           do (assert (string= s s2))
	#           collect s))
	#   ("ABC"
	#    " ABC"
	#    "  ABC"
	#    "   ABC"
	#    "    ABC"
	#    "     ABC"
	#    "      ABC"))
	# 
	ok deftest( {
		my @collected;
		my $fn = $*fl.formatter( Q{~3,,v@A} );
		for 0 .. 6 -> $i {
			my $s = $*fl.format( Q{~3,,v@A}, $i, Q{ABC} );
			my $s2 = formatter-call-to-string( $fn, $i, Q{ABC} );
			is $s, $s2;
			@collected.append( $s );
		}
		@collected;
	}, [	Q{ABC},
		Q{ ABC},
		Q{  ABC},
		Q{   ABC},
		Q{    ABC},
		Q{     ABC},
		Q{      ABC}
	]
	), Q{format.a.44a};

	# (def-format-test format.a.45
	#   "~4,,va" (-1 "abcd") "abcd")
	# 
	ok def-format-test(
		Q{~4,,va}, ( -1, Q{abcd} ), Q{abcd}
	), Q{format.a.45};

	# (def-format-test format.a.46
	#   "~5,vA" (nil "abc") "abc  ")
	# 
	ok def-format-test(
		Q{~5,vA}, ( Nil, Q{abc} ), Q{abc  }
	), Q{format.a.46};

	# (def-format-test format.a.47
	#   "~5,vA" (3 "abc") "abc   ")
	# 
	ok def-format-test(
		Q{~5,vA}, ( 3, Q{abc} ), Q{abc   }
	), Q{format.a.47};

	# (def-format-test format.a.48
	#   "~5,v@A" (3 "abc") "   abc")
	# 
	ok def-format-test(
		Q{~5,v@A}, ( 3, Q{abc} ), Q{   abc}
	), Q{format.a.48};
}, Q{other tests};

subtest {
	# (def-format-test format.a.49
	#   "~#A" ("abc" nil nil nil) "abc " 3)
	# 
	ok def-format-test(
		Q{~#A}, ( Q{abc}, Nil, Nil, Nil ), Q{abc }, 3
	), Q{format.a.49};

	# (def-format-test format.a.50
	#   "~#@a" ("abc" nil nil nil nil nil) "   abc" 5)
	# 
	ok def-format-test(
		Q{~#@a}, ( Q{abc}, Nil, Nil, Nil, Nil, Nil ), Q{   abc}, 5
	), Q{format.a.50};

	# (def-format-test format.a.51
	#   "~5,#a" ("abc" nil nil nil) "abc    " 3)
	# 
	ok def-format-test(
		Q{~5,#a}, ( Q{abc}, Nil, Nil, Nil ), Q{abc    }, 3
	), Q{format.a.51};

	# (def-format-test format.a.52
	#   "~5,#@A" ("abc" nil nil nil) "    abc" 3)
	# 
	ok def-format-test(
		Q{~5,#@A}, ( Q{abc}, Nil, Nil, Nil ), Q{    abc}, 3
	), Q{format.a.52};

	# (def-format-test format.a.53
	#   "~4,#A" ("abc" nil nil) "abc   " 2)
	# 
	ok def-format-test(
		Q{~4,#A}, ( Q{abc}, Nil, Nil ), Q{abc   }, 2
	), Q{format.a.53};

	# (def-format-test format.a.54
	#   "~4,#@A" ("abc" nil nil) "   abc" 2)
	# 
	ok def-format-test(
		Q{~4,#@A}, ( Q{abc}, Nil, Nil ), Q{   abc}, 2
	), Q{format.a.54};

	# (def-format-test format.a.55
	#   "~#,#A" ("abc" nil nil nil) "abc    " 3)
	# 
	ok def-format-test(
		Q{~#,#A}, ( Q{abc}, Nil, Nil, Nil ), Q{abc    }, 3
	), Q{format.a.55};

	# (def-format-test format.a.56
	#   "~#,#@A" ("abc" nil nil nil) "    abc" 3)
	# 
	ok def-format-test(
		Q{~#,#@A}, ( Q{abc}, Nil, Nil, Nil ), Q{    abc}, 3
	), Q{format.a.56};

	# (def-format-test format.a.57
	#   "~-100A" ("xyz") "xyz")
	# 
	ok def-format-test( Q{~-10@A}, ( Q{xyz} ), Q{xyz} ), Q{format.a.57};

	# (def-format-test format.a.58
	#   "~-100000000000000000000a" ("xyz") "xyz")
	#
	ok def-format-test(
		Q{~-100000000000000000000a}, ( Q{xyz} ), Q{xyz}
	), Q{format.a.58};
}, Q{# parameters};

done-testing;

# vim: ft=perl6
