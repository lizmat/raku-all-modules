use v6;

use Test;
use lib 't/lib';
use Utils;
use Format::Lisp;

my $*fl = Format::Lisp.new;

# (def-format-test format.?.1
#   "~?" ("" nil) "")
# 
ok def-format-test( Q{~?}, ( Q{}, Nil ), Q{} ), Q{format.?.1};

#`(
# (def-format-test format.?.2
#   "~?" ("~A" '(1)) "1")
# 
ok def-format-test( Q{~?}, ( Q{~A}, [ 1 ] ), Q{1} ), Q{format.?.2};
)

# (def-format-test format.?.3
#   "~?" ("" '(1)) "")
# 
ok def-format-test( Q{~?}, ( Q{}, [ 1 ] ), Q{} ), Q{format.?.3};

#`(
# (def-format-test format.?.4
#   "~? ~A" ("" '(1) 2) " 2")
# 
ok def-format-test( Q{~? ~A}, ( Q{}, [ 1 ], 2 ), Q{ 2} ), Q{format.?.4};
)

#`(
# (def-format-test format.?.5
#   "a~?z" ("b~?y" '("c~?x" ("~A" (1)))) "abc1xyz")
# 
ok def-format-test(
	Q{a~?z}, ( Q{b~?x}, [ Q{c~?x}, [ Q{~A}, [ 1 ] ] ] ), Q{abc1xyz}
), Q{format.?.5};
)

subtest {
	# (def-format-test format.@?.1
	#   "~@?" ("") "")
	# 
	ok def-format-test( Q{~@?}, ( Q{} ), Q{} ), Q{format.@?.1};

	#`(
	# (def-format-test format.@?.2
	#   "~@?" ("~A" 1) "1")
	# 
	ok def-format-test( Q{~@?}, ( Q{~A}, 1 ), Q{1} ), Q{format.@?.2};
	)

	#`(
	# (def-format-test format.@?.3
	#   "~@? ~A" ("<~A>" 1 2) "<1> 2")
	# 
	ok def-format-test(
		Q{~@? ~A}, ( Q{<~A>}, 1, 2 ), Q{<1> 2}
	), Q{format.@?.3};
	)

	#`(
	# (def-format-test format.@?.4
	#   "a~@?z" ("b~@?y" "c~@?x" "~A" 1) "abc1xyz")
	# 
	ok def-format-test(
		Q{a~@?z}, ( Q{b~@?y}, Q{c~@?x}, Q{~A}, 1 ), Q{abc1xyz}
	), Q{format.@?.4};
	)

	#`(
	# (def-format-test format.@?.5
	#   "~{~A~@?~A~}" ('(1 "~4*" 2 3 4 5 6)) "16")
	# 
	ok def-format-test(
		Q{~{~A~@?~A~}}, ( 1, Q{~4*}, 2, 3, 4, 5, 6 ), Q{16}
	), Q{format.@?.5};
	)
}, Q{Tests of ~@?};

done-testing;

# vim: ft=perl6
