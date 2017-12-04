use v6;

use Test;
use lib 't/lib';
use Utils;
use Format::Lisp;

my $*fl = Format::Lisp.new;

# ;;; ~*
# 
# (def-format-test format.*.1
#   "~A~*~A" (1 2 3) "13")
# 
ok def-format-test( Q{~A~*~A}, ( 1, 2, 3 ), Q{13} ), Q{format.*.1};

# (def-format-test format.*.2
#   "~A~0*~A" (1 2 3) "12" 1)
# 
ok def-format-test( Q{~A~0*~A}, ( 1, 2, 3 ), Q{12}, 1 ), Q{format.*.2};

# (def-format-test format.*.3
#   "~A~v*~A" (1 0 2) "12")
# 
ok def-format-test( Q{~A~v*~A}, ( 1, 0, 2 ), Q{12} ), Q{format.*.3};

# (def-format-test format.*.4
#   "~A~v*~A" (1 1 2 3) "13")
# 
ok def-format-test( Q{~A~v*~A}, ( 1, 1, 2, 3 ), Q{13} ), Q{format.*.4};

# (def-format-test format.*.5
#   "~A~v*~A" (1 nil 2 3) "13")
# 
ok def-format-test( Q{~A~v*~A}, ( 1, Nil, 2, 3 ), Q{13} ), Q{format.*.5};

#`(
# (def-format-test format.*.6
#   "~A~1{~A~*~A~}~A" (0 '(1 2 3) 4) "0134")
# 
ok def-format-test(
	Q{~A~1{~A~*~A~}~A}, ( 0, [ 1, 2, 3 ], 4 ), Q{0134}
), Q{format.*.6};
)

#`(
# (def-format-test format.*.7
#   "~A~1{~A~0*~A~}~A" (0 '(1 2 3) 4) "0124")
# 
ok def-format-test(
	Q{~A~1{~A~0*~A~}~A}, ( 0, [ 1, 2, 3 ], 4 ), Q{0124}
), Q{format.*.7};
)

#`(
# (def-format-test format.*.8
#   "~A~{~A~*~A~}~A" (0 '(1 2 3 4 5 6) 7) "013467")
# 
ok def-format-test(
	Q{~A~1{~A~*~A~}~A}, ( 0, [ 1, 2, 3, 4, 5, 6 ], 7 ), Q{013467}
), Q{format.*.8};
)

#`(
# (def-format-test format.*.9
#   "~A~{~A~A~A~A~v*~^~A~A~A~A~}~A" (0 '(1 2 3 4 nil 6 7 8 9 #\A) 5)
#   "01234789A5")
# 
ok def-format-test(
	Q{~A~{~A~A~A~A~v*~^~A~A~A~A~}~A},
	( 0, [ 1, 2, 3, 4, Nil, 6, 7, 8, 9, Q{A} ], 5 ),
	Q{01234789A5}
), Q{format.*.9};
)

subtest {
	# ;;; ~:*
	# 
	# (def-format-test format.\:*.1
	#   "~A~:*~A" (1 2 3) "11" 2)
	# 
	ok def-format-test( Q{~A~:*~A}, ( 1, 2, 3 ), Q{11}, 2 ), Q{format.:*.1};

	# (def-format-test format.\:*.2
	#   "~A~A~:*~A" (1 2 3) "122" 1)
	# 
	ok def-format-test(
		Q{~A~A~:*~A}, ( 1, 2, 3 ), Q{122}, 1
	), Q{format.:*.2};

	# (def-format-test format.\:*.3
	#   "~A~A~0:*~A" (1 2 3) "123")
	# 
	ok def-format-test(
		Q{~A~A~0:*~A}, ( 1, 2, 3 ), Q{123}
	), Q{format.:*.3};

	# (def-format-test format.\:*.4
	#   "~A~A~2:*~A" (1 2 3) "121" 2)
	# 
	ok def-format-test(
		Q{~A~A~2:*~A}, ( 1, 2, 3 ), Q{121}, 2
	), Q{format.:*.4};

	# (def-format-test format.\:*.5
	#   "~A~A~v:*~A" (1 2 0 3) "123")
	# 
	ok def-format-test(
		Q{~A~A~v:*~A}, ( 1, 2, 0, 3 ), Q{123}
	), Q{format.:*.5};

	# (def-format-test format.\:*.6
	#   "~A~A~v:*~A" (6 7 2 3) "677" 2)
	# 
	ok def-format-test(
		Q{~A~A~v:*~A}, ( 6, 7, 2, 3 ), Q{677}, 2
	), Q{format.:*.6};

	# (def-format-test format.\:*.7
	#   "~A~A~v:*~A" (6 7 nil 3) "67NIL" 1)
	# 
	ok def-format-test(
		Q{~A~A~v:*~A}, ( 6, 7, Nil, 3 ), Q{67NIL}, 1
	), Q{format.:*.7};

	#`(
	# (def-format-test format.\:*.8
	#   "~A~1{~A~:*~A~}~A" (0 '(1 2 3) 4) "0114")
	# 
	ok def-format-test(
		Q{~A~1{~A~:*~A~}~A}, ( 0, [ 1, 2, 3 ], 4 ), Q{0114}
	), Q{format.:*.8};
	)

	#`(
	# (def-format-test format.\:*.9
	#   "~A~1{~A~A~A~:*~A~}~A" (0 '(1 2 3 4) 5) "012335")
	# 
	ok def-format-test(
		Q{~A~1{~A~A~A~:*~A~}~A}, ( 0, [ 1, 2, 3, 4 ], 5 ), Q{012335}
	), Q{format.:*.9};
	)

	#`(
	# (def-format-test format.\:*.10
	#   "~A~1{~A~A~A~2:*~A~A~}~A" (0 '(1 2 3 4) 5) "0123235")
	# 
	ok def-format-test(
		Q{~A~1{~A~A~A~2:*~A~A~}~A},
		( 0, [ 1, 2, 3, 4 ], 5 ),
		Q{0123235}
	), Q{format.:*.10};
	)

	#`(
	# (def-format-test format.\:*.11
	#   "~A~{~A~A~A~3:*~A~A~A~A~}~A" (0 '(1 2 3 4) 5) "012312345")
	# 
	ok def-format-test(
		Q{~A~{~A~A~A~3:*~A~A~A~A~}~A},
		( 0, [ 1, 2, 3, 4 ], 5 ),
		Q{012312345}
	), Q{format.:*.11};
	)

	#`(
	# (def-format-test format.\:*.12
	#   "~A~{~A~A~A~A~4:*~^~A~A~A~A~}~A" (0 '(1 2 3 4) 5) "0123412345")
	# 
	ok def-format-test(
		Q{~A~{~A~A~A~A~4:*~^~A~A~A~A~}~A},
		( 0, [ 1, 2, 3, 4 ], 5 ),
		Q{0123412345}
	), Q{format.:*.12};
	)

	#`(
	# (def-format-test format.\:*.13
	#   "~A~{~A~A~A~A~v:*~^~A~}~A" (0 '(1 2 3 4 nil) 5) "01234NIL5")
	# 
	ok def-format-test(
		Q{~A~{~A~A~A~A~v:*~^~A~}~A},
		( 0, [ 1, 2, 3, 4, Nil ], 5 ),
		Q{01234NIL5}
	), Q{format.:*.13};
	)
}, Q{~:*};

subtest {
	# (def-format-test format.@*.1
	#   "~A~A~@*~A~A" (1 2 3 4) "1212" 2)
	# 
	ok def-format-test(
		Q{~A~A~@*~A~A}, ( 1, 2, 3, 4 ), Q{1212}, 2
	), Q{format.@*.1};

	# (def-format-test format.@*.2
	#   "~A~A~1@*~A~A" (1 2 3 4) "1223" 1)
	# 
	ok def-format-test(
		Q{~A~A~1@*~A~A}, ( 1, 2, 3, 4 ), Q{1223}, 1
	), Q{format.@*.2};

	# (def-format-test format.@*.3
	#   "~A~A~2@*~A~A" (1 2 3 4) "1234")
	# 
	ok def-format-test(
		Q{~A~A~2@*~A~A}, ( 1, 2, 3, 4 ), Q{1234}
	), Q{format.@*.3};

	# (def-format-test format.@*.4
	#   "~A~A~3@*~A~A" (1 2 3 4 5) "1245")
	# 
	ok def-format-test(
		Q{~A~A~3@*~A~A}, ( 1, 2, 3, 4, 5 ), Q{1245}
	), Q{format.@*.4};

	# (def-format-test format.@*.5
	#   "~A~A~v@*~A~A" (1 2 nil 3 4) "1212" 3)
	# 
	ok def-format-test(
		Q{~A~A~v@*~A~A}, ( 1, 2, Nil, 3, 4 ), Q{1212}, 3
	), Q{format.@*.5};

	# (def-format-test format.@*.6
	#   "~A~A~v@*~A~A" (1 2 1 3 4) "1221" 2)
	# 
	ok def-format-test(
		Q{~A~A~v@*~A~A}, ( 1, 2, 1, 3, 4 ), Q{1221}, 2
	), Q{format.@*.6};

	# (def-format-test format.@*.7
	#   "~A~A~v@*~A~A" (6 7 2 3 4) "6723" 1)
	# 
	ok def-format-test(
		Q{~A~A~v@*~A~A}, ( 6, 7, 2, 3, 4 ), Q{6723}, 1
	), Q{format.@*.7};

	#`(
	# (def-format-test format.@*.8
	#   "~A~{~A~A~@*~A~A~}~A" (0 '(1 2) 9) "012129")
	# 
	ok def-format-test(
		Q{~A{~A~A~@*~A~A~}~A}, ( 0, [ 1, 2 ], 9 ), Q{012129}
	), Q{format.@*.8};
	)

	#`(
	# (def-format-test format.@*.9
	#   "~A~{~A~A~0@*~A~A~}~A" (0 '(1 2) 9) "012129")
	# 
	ok def-format-test(
		Q{~A{~A~A~0@*~A~A~}~A}, ( 0, [ 1, 2 ], 9 ), Q{012129}
	), Q{format.@*.9};
	)

	#`(
	# (def-format-test format.@*.10
	#   "~A~1{~A~A~v@*~A~A~}~A" (0 '(1 2 nil) 9) "012129")
	# 
	ok def-format-test(
		Q{~A~1{~A~A~v@*~A~A~}~A}, ( 0, [ 1, 2, Nil ], 9 ), Q{012129}
	), Q{format.@*.10};
	)

	#`(
	# (def-format-test format.@*.11
	#   "~A~{~A~A~1@*~A~}~A" (0 '(1 2) 9) "01229")
	# 
	ok def-format-test(
		Q{~A1{~A~A~1@*~A~}~A}, ( 0, [ 1, 2 ], 9 ), Q{01229}
	), Q{format.@*.11};
	)
}, Q{~@*};

done-testing;

# vim: ft=perl6
