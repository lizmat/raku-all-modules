use v6;

use Test;
use lib 't/lib';
use Utils;
use Format::Lisp;

my $*fl = Format::Lisp.new;

# (deftest format.s.1
#   (let ((*print-readably* nil)
#         (*print-case* :upcase))
#     (format nil "~s" nil))
#   "NIL")
# 
ok deftest( {
	my $*PRINT-READABLY = False;
	my $*PRINT-CASE = Q{upcase};
	$*fl.format( Q{~s}, Nil );
}, Q{NIL}
), Q{format.s.1};

#`(
# (deftest formatter.s.1
#   (let ((*print-readably* nil)
#         (*print-case* :upcase))
#     (formatter-call-to-string (formatter "~s") nil))
#   "NIL")
# 
ok deftest( {
#	my $*PRINT-READABLY = False;
#	my $*PRINT-CASE = Q{upcase};
#	$*fl.format( Q{~s}, Nil );
}, Q{NIL}
), Q{formatter.s.1};
)

# (def-format-test format.s.2
#   "~:s" (nil) "()")
# 
ok def-format-test( Q{~:s}, ( Nil ), Q{()} ), Q{format.s.2};

# (deftest format.s.3
#   (let ((*print-readably* nil)
#         (*print-case* :upcase))
#     (format nil "~:s" '(nil)))
#   "(NIL)")
# 
ok deftest( {
	my $*PRINT-READABLY = Nil;
	my $*PRINT-CASE = Q{upcase};
	$*fl.format( Q{~:s}, [ Nil ] );
}, Q{(NIL)}
), Q{format.s.3};

#`(
# (deftest formatter.s.3
#   (let ((*print-readably* nil)
#         (*print-case* :upcase))
#     (formatter-call-to-string (formatter "~:s") '(nil)))
#   "(NIL)")
# 
ok deftest( {
#	my $*PRINT-READABLY = Nil;
#	my $*PRINT-CASE = Q{upcase};
#	$*fl.format( Q{~:s}, [ Nil ] );
}, Q{(NIL)}
), Q{formatter.s.3};
)

# (deftest format.s.4
#   (let ((*print-readably* nil)
#         (*print-case* :downcase))
#     (format nil "~s" 'nil))
#   "nil")
# 
ok deftest( {
	my $*PRINT-READABLY = Nil;
	my $*PRINT-CASE = Q{downcase};
	$*fl.format( Q{~s}, Nil );
}, Q{nil}
), Q{format.s.4};

#`(
# (deftest formatter.s.4
#   (let ((*print-readably* nil)
#         (*print-case* :downcase))
#     (formatter-call-to-string (formatter "~s") 'nil))
#   "nil")
# 
ok deftest( {
#	my $*PRINT-READABLY = Nil;
#	my $*PRINT-CASE = Q{downcase};
#	$*fl.format( Q{~s}, Nil );
}, Q{nil}
), Q{formatter.s.4};
)

# (deftest format.s.5
#   (let ((*print-readably* nil)
#         (*print-case* :capitalize))
#     (format nil "~s" 'nil))
#   "Nil")
# 
ok deftest( {
	my $*PRINT-READABLY = Nil;
	my $*PRINT-CASE = Q{capitalize};
	$*fl.format( Q{~s}, Nil );
}, Q{Nil}
), Q{format.s.5};

#`(
# (deftest formatter.s.5
#   (let ((*print-readably* nil)
#         (*print-case* :capitalize))
#     (formatter-call-to-string (formatter "~s") 'nil))
#   "Nil")
# 
ok deftest( {
#	my $*PRINT-READABLY = Nil;
#	my $*PRINT-CASE = Q{capitalize};
#	$*fl.format( Q{~s}, Nil );
}, Q{Nil}
), Q{formatter.s.5};
)

#`(
# (def-format-test format.s.6
#   "~:s" (#(nil)) "#(NIL)")
# 
# Doesn't really work in Perl?
)

#`(
# (deftest format.s.7
#   (let ((fn (formatter "~S")))
#     (with-standard-io-syntax
#      (let ((*print-readably* nil))
#        (loop for c across +standard-chars+
#              for s = (format nil "~S" c)
#              for s2 = (formatter-call-to-string fn c)
#              for c2 = (read-from-string s)
#              unless (and (eql c c2) (string= s s2))
#              collect (list c s c2 s2)))))
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
), Q{format.s.7};
)

#`(
# (deftest format.s.8
#   (let ((fn (formatter "~s")))
#     (with-standard-io-syntax
#      (let ((*print-readably* nil))
#        (loop with count = 0
#              for i from 0 below (min #x10000 char-code-limit)
#              for c = (code-char i)
#              for s1 = (and c (format nil "#\\~:c" c))
#              for s2 = (and c (format nil "~S" c))
#              for s3 = (formatter-call-to-string fn c)
#              unless (or (null c)
#                         (graphic-char-p c)
#                         (and (string= s1 s2) (string= s2 s3)))
#               do (incf count) and collect (list c s1 s2)
#              when (> count 100)
#               collect "count limit exceeded"
#               and do (loop-finish)))))
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
), Q{format.s.8};
)

#`(
# (deftest format.s.9
#   (with-standard-io-syntax
#    (let ((*print-readably* nil))
#      (apply
#       #'values
#       (loop for i from 1 to 10
#             for fmt = (format nil "~~~d@s" i)
#             for s = (format nil fmt nil)
#             for fn = (eval `(formatter ,fmt))
#             for s2 = (formatter-call-to-string fn nil)
#             do (assert (string= s s2))
#             collect s))))
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
	my $fn = $*fl.formatter( Q{~#B} );
	my $bv = 0b11001;
	for 0 .. 10 -> $i {
#		my @args = 
#		is $s, $s2;
#		@collected.append( $s );
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
), Q{format.s.9};
)

#`(
# (deftest format.s.10
#   (with-standard-io-syntax
#    (let ((*print-readably* nil))
#      (apply
#       #'values
#       (loop for i from 1 to 10
#             for fmt = (format nil "~~~dS" i)
#             for s = (format nil fmt nil)
#             for fn = (eval `(formatter ,fmt))
#             for s2 = (formatter-call-to-string fn nil)
#             do (assert (string= s s2))
#             collect s))))
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
	my $fn = $*fl.formatter( Q{~#B} );
	my $bv = 0b11001;
	for 0 .. 10 -> $i {
#		my @args = 
#		is $s, $s2;
#		@collected.append( $s );
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
), Q{format.s.10};
)

#`(
# (deftest format.s.11
#   (with-standard-io-syntax
#    (let ((*print-readably* nil))
#      (apply
#       #'values
#       (loop for i from 1 to 10
#             for fmt = (format nil "~~~d@:S" i)
#             for s = (format nil fmt nil)
#             for fn = (eval `(formatter ,fmt))
#             for s2 = (formatter-call-to-string fn nil)
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
	my $fn = $**fl.formatter( Q{~#B} );
	my $bv = 0b11001;
	for 0 .. 10 -> $i {
#		my @args = 
#		is $s, $s2;
#		@collected.append( $s );
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
), Q{format.s.11};
)

#`(
# (deftest format.s.12
#   (with-standard-io-syntax
#    (let ((*print-readably* nil))
#      (apply
#       #'values
#       (loop for i from 1 to 10
#             for fmt = (format nil "~~~d:s" i)
#             for s = (format nil fmt nil)
#             for fn = (eval `(formatter ,fmt))
#             for s2 = (formatter-call-to-string fn nil)
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
	my $fn = $*fl.formatter( Q{~#B} );
	my $bv = 0b11001;
	for 0 .. 10 -> $i {
#		my @args = 
#		is $s, $s2;
#		@collected.append( $s );
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
), Q{format.s.12};
)

#`(
# (deftest format.s.13
#   (with-standard-io-syntax
#    (let ((*print-readably* nil)
#          (fn (formatter "~V:s")))
#      (apply
#       #'values
#       (loop for i from 1 to 10
#             for s = (format nil "~v:S" i nil)
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
	my $fn = $*fl.formatter( Q{~#B} );
	my $bv = 0b11001;
	for 0 .. 10 -> $i {
#		my @args = 
#		is $s, $s2;
#		@collected.append( $s );
	}
	@collected;
}, [	Q{()}.
	Q{()}.
	Q{() }.
	Q{()  }.
	Q{()   }.
	Q{()    }.
	Q{()     }.
	Q{()      }.
	Q{()       }.
	Q{()        }
]
), Q{format.s.13};
)

#`(
# (deftest format.s.14
#   (with-standard-io-syntax
#    (let ((*print-readably* nil)
#          (fn (formatter "~V@:s")))
#      (apply
#       #'values
#       (loop for i from 1 to 10
#             for s = (format nil "~v:@s" i nil)
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
	my $fn = $*fl.formatter( Q{~#B} );
	my $bv = 0b11001;
	for 0 .. 10 -> $i {
#		my @args = 
#		is $s, $s2;
#		@collected.append( $s );
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
), Q{format.s.14};
)

# (def-format-test format.s.15
#   "~vS" (nil nil) "NIL")
# 
ok def-format-test( Q{~vS}, ( Nil, Nil ), Q{NIL} ), Q{format.s.15};

# (def-format-test format.s.16
#   "~v:S" (nil nil) "()")
# 
ok def-format-test( Q{~v:S}, ( Nil, Nil ), Q{()} ), Q{format.s.16};

# (def-format-test format.s.17
#   "~@S" (nil) "NIL")
# 
ok def-format-test( Q{~@S}, ( Nil ), Q{NIL} ), Q{format.s.17};

# (def-format-test format.s.18
#   "~v@S" (nil nil) "NIL")
# 
ok def-format-test( Q{~v@S}, ( Nil, Nil ), Q{NIL} ), Q{format.s.18};

# (def-format-test format.s.19
#   "~v:@s" (nil nil) "()")
# 
ok def-format-test( Q{~v:@s}, ( Nil, Nil ), Q{()} ), Q{format.s.19};

# (def-format-test format.s.20
#   "~v@:s" (nil nil) "()")
# 
ok def-format-test( Q{~v@:s}, ( Nil, Nil ), Q{()} ), Q{format.s.20};

subtest {
	# ;;; With colinc specified
	# 
	# (def-format-test format.s.21
	#   "~3,1s" (nil) "NIL")
	# 
	ok def-format-test( Q{~3,1S}, ( Nil ), Q{NIL} ), Q{format.s.21};

	# (def-format-test format.s.22
	#   "~4,3s" (nil) "NIL   ")
	# 
	ok def-format-test( Q{~4,3S}, ( Nil ), Q{NIL   } ), Q{format.s.22};

	# (def-format-test format.s.23
	#   "~3,3@s" (nil) "NIL")
	# 
	ok def-format-test( Q{~3,3@S}, ( Nil ), Q{NIL} ), Q{format.s.23};

	# (def-format-test format.s.24
	#   "~4,4@s" (nil) "    NIL")
	# 
	ok def-format-test( Q{~4,4@s}, ( Nil ), Q{    NIL} ), Q{format.s.23};

	# (def-format-test format.s.25
	#   "~5,3@s" (nil) "   NIL")
	# 
	ok def-format-test( Q{~5,3@s}, ( Nil ), Q{   NIL} ), Q{format.s.24};

	# (def-format-test format.s.26
	#   "~5,3S" (nil) "NIL   ")
	# 
	ok def-format-test( Q{~5,3S}, ( Nil ), Q{NIL   } ), Q{format.s.26};

	# (def-format-test format.s.27
	#   "~7,3@s" (nil) "      NIL")
	# 
	ok def-format-test( Q{~7,3@s}, ( Nil ), Q{      NIL} ), Q{format.s.27};

	# (def-format-test format.s.28
	#   "~7,3S" (nil) "NIL      ")
	# 
	ok def-format-test( Q{~7,3S}, ( Nil ), Q{NIL      } ), Q{format.s.28};
}, Q{With colinc specified};

subtest {
	#`(
	# (deftest format.s.29
	#   (with-standard-io-syntax
	#    (let ((*print-readably* nil)
	#          (*package* (find-package :cl-test))
	#          (fn (formatter "~V,,2s")))
	#      (loop for i from -4 to 10
	#            for s = (format nil "~v,,2S" i 'ABC)
	#            for s2 = (formatter-call-to-string fn i 'ABC)
	#            do (assert (string= s s2))
	#            collect s)))
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
		my $fn = $*fl.formatter( Q{~#B} );
		my $bv = 0b11001;
		for 0 .. 10 -> $i {
	#		my @args = 
	#		is $s, $s2;
	#		@collected.append( $s );
		}
		@collected;
	},
	[	Q{ABC  },
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
	), Q{format.s.29};
	)

	# (def-format-test format.s.30
	#   "~3,,+2S" ('ABC) "ABC  ")
	# 
	ok def-format-test( Q{~3,,+2S}, ( Q{ABC} ), Q{ABC  } ), Q{format.s.30};

	# (def-format-test format.s.31
	#   "~3,,0S" ('ABC) "ABC")
	# 
	ok def-format-test( Q{~3,,0S}, ( Q{ABC} ), Q{ABC} ), Q{format.s.31};

	# (def-format-test format.s.32
	#   "~3,,-1S" ('ABC) "ABC")
	# 
	ok def-format-test( Q{~3,,-1S}, ( Q{ABC} ), Q{ABC} ), Q{format.s.32};

	# (def-format-test format.s.33
	#   "~3,,0S" ('ABCD) "ABCD")
	# 
	ok def-format-test( Q{~3,,0S}, ( Q{ABCD} ), Q{ABCD} ), Q{format.s.33};

	# (def-format-test format.s.34
	#   "~3,,-1S" ('ABCD) "ABCD")
	# 
	ok def-format-test( Q{~3,,-1S}, ( Q{ABCD} ), Q{ABCD} ), Q{format.s.34};
}, Q{With minpad};

subtest {
	# (def-format-test format.s.35
	#   "~4,,,'XS" ('AB) "ABXX")
	# 
	ok def-format-test( Q{~4,,,'XS}, ( Q{AB} ), Q{ABXX} ), Q{format.s.35};

	# (def-format-test format.s.36
	#   "~4,,,s" ('AB) "AB  ")
	# 
	ok def-format-test( Q{~4,,,s}, ( Q{AB} ), Q{AB  } ), Q{format.s.36};

	# (def-format-test format.s.37
	#   "~4,,,'X@s" ('AB) "XXAB" )
	# 
	ok def-format-test( Q{~4,,,'X@s}, ( Q{AB} ), Q{XXAB} ), Q{format.s.37};

	# (def-format-test format.s.38
	#   "~4,,,@S" ('AB) "  AB")
	# 
	ok def-format-test( Q{~4,,,@s}, ( Q{AB} ), Q{  AB} ), Q{format.s.38};

	# (def-format-test format.s.39
	#   "~10,,,vS" (nil 'ABCDE) "ABCDE     ")
	# 
	ok def-format-test(
		Q{~10,,,vS}, ( Nil, Q{ABCDE} ), Q{ABCDE     }
	), Q{format.s.39};

	# (def-format-test format.s.40
	#   "~10,,,v@S" (nil 'ABCDE) "     ABCDE")
	# 
	ok def-format-test(
		Q{~10,,,v@S}, ( Nil, Q{ABCDE} ), Q{     ABCDE}
	), Q{format.s.40};

	# (def-format-test format.s.41
	#   "~10,,,vs" (#\* 'ABCDE) "ABCDE*****")
	# 
	ok def-format-test(
		Q{~10,,,vs}, ( Q{*}, Q{ABCDE} ), Q{ABCDE*****}
	), Q{format.s.41};

	# (def-format-test format.s.42
	#   "~10,,,v@s" (#\* 'ABCDE) "*****ABCDE")
	# 
	ok def-format-test(
		Q{~10,,,v@s}, ( Q{*}, Q{ABCDE} ), Q{*****ABCDE}
	), Q{forma.s.42};
}, Q{With padchar};

subtest {
	# (def-format-test format.s.43
	#   "~3,,vS" (nil 246) "246")
	# 
	ok def-format-test( Q{~3,,vS}, ( Nil, 246 ), Q{246} ), Q{format.s.43};

	#`(
	# (deftest format.s.44
	#   (with-standard-io-syntax
	#    (let ((*print-readably* nil)
	#          (*package* (find-package :cl-test))
	#          (fn (formatter "~3,,vs")))
	#      (loop for i from 0 to 6
	#            for s = (format nil "~3,,vS" i 'ABC)
	#            for s2 = (formatter-call-to-string fn i 'ABC)
	#            do (assert (string= s s2))
	#            collect s)))
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
		my $fn = $*fl.formatter( Q{~#B} );
		my $bv = 0b11001;
		for 0 .. 10 -> $i {
	#		my @args = 
	#		is $s, $s2;
	#		@collected.append( $s );
		}
		@collected;
	},
	[	Q{ABC},
		Q{ABC },
		Q{ABC  },
		Q{ABC   },
		Q{ABC    },
		Q{ABC     },
		Q{ABC      },
	]
	), Q{format.s.44};
	)

	#`(
	# (deftest format.s.44a
	#   (with-standard-io-syntax
	#    (let ((*print-readably* nil)
	#          (*package* (find-package :cl-test))
	#          (fn (formatter "~3,,V@S")))
	#      (loop for i from 0 to 6
	#            for s = (format nil "~3,,v@S" i 'ABC)
	#            for s2 = (formatter-call-to-string fn i 'ABC)
	#            do (assert (string= s s2))
	#            collect s)))
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
		my $fn = $*fl.formatter( Q{~#B} );
		my $bv = 0b11001;
		for 0 .. 10 -> $i {
	#		my @args = 
	#		is $s, $s2;
	#		@collected.append( $s );
		}
		@collected;
	},
	[	Q{ABC},
		Q{ ABC},
		Q{  ABC},
		Q{   ABC},
		Q{    ABC},
		Q{     ABC},
		Q{      ABC}
	]
	), Q{formatter.s.44a};
	)

	# (def-format-test format.s.45
	#   "~4,,vs" (-1 1234) "1234")
	# 
	ok def-format-test( Q{~4,,vs}, ( -1, 1234 ), Q{1234} ), Q{format.s.45};

	# (def-format-test format.s.46
	#   "~5,vS" (nil 123) "123  ")
	# 
	ok def-format-test( Q{~5,vS}, ( Nil, 123 ), Q{123  } ), Q{format.s.46};

	# (def-format-test format.s.47
	#   "~5,vS" (3 456) "456   ")
	# 
	ok def-format-test( Q{~5,vS}, ( 3, 456 ), Q{456   } ), Q{format.s.47};

	# (def-format-test format.s.48
	#   "~5,v@S" (3 789) "   789")
	#
	ok def-format-test( Q{~5,v@S}, ( 3, 789 ), Q{   789} ), Q{format.s.48};
}, Q{Other tests};

done-testing;

# vim: ft=perl6
