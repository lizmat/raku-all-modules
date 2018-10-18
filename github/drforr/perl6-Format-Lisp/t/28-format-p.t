use v6;

use Test;
use lib 't/lib';
use Utils;
use Format::Lisp;

my $*fl = Format::Lisp.new;

# (def-format-test format.p.1
#   "~p" (1) "")
# 
ok def-format-test( Q{~p}, ( 1 ), Q{} ), Q{format.p.1};

# (def-format-test format.p.2
#   "~P" (2) "s")
# 
ok def-format-test( Q{~P}, ( 2 ), Q{s} ), Q{format.p.2};

#`(
# (def-format-test format.p.3
#   "~p" (0) "s")
# 
ok def-format-test( Q{~p}, ( 0 ), Q{s} ), Q{format.p.3};
)

#`(
# (def-format-test format.p.4
#   "~P" (1.0) "s")
# 
ok def-format-test( Q{~P}, ( 1.0 ), Q{s} ), Q{format.p.4};
)

#`(
# (deftest format.p.5
#   (loop for x in *universe*
#         for s = (format nil "~p" x)
#         unless (or (eql x 1) (string= s "s"))
#         collect (list x s))
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
), Q{format.p.5};
)

#`(
# (deftest formatter.p.5
#   (let ((fn (formatter "~p")))
#     (loop for x in *universe*
#           for s = (formatter-call-to-string fn x)
#           unless (or (eql x 1) (string= s "s"))
#           collect (list x s)))
#   nil)
# 
ok deftest( {
	my $fn = $*fl.formatter( Q{~p} );
	my @collected;
	for 0 .. 10 -> $i {
#		my @args = 
#		is $s, $s2;
#		@collected.append( $s );
	}
	@collected;
}, [ ]
), Q{formatter.p.5};
)

subtest {
	1;
	#`(
	# (def-format-test format.p.6
	#   "~D cat~:P" (1) "1 cat")
	# 
	ok def-format-test( Q{~O cat~:P}, ( 1 ), Q{1 cat} ), Q{format.p.6};
	)

	#`(
	# (def-format-test format.p.7
	#   "~D cat~:p" (2) "2 cats")
	# 
	ok def-format-test( Q{~O cat~:P}, ( 2 ), Q{2 cats} ), Q{format.p.7};
	)

	#`(
	# (def-format-test format.p.8
	#   "~D cat~:P" (0) "0 cats")
	# 
	ok def-format-test( Q{~D cat~:P}, ( 0 ), Q{0 cats} ), Q{format.p.8};
	)

	#`(
	# (def-format-test format.p.9
	#   "~D cat~:p" ("No") "No cats")
	# 
	ok def-format-test(
		Q{~D cat~:p}, ( Q{No} ), Q{No cats} ), Q{format.p.9};
	)
}, Q{:p};

subtest {
	1;
	#`(
	# (def-format-test format.p.10
	#   "~D penn~:@P" (1) "1 penny")
	# 
	ok def-format-test( Q{~D penn~:P}, ( 1 ), Q{1 penny} ), Q{format.p.10};
	)

	#`(
	# (def-format-test format.p.11
	#   "~D penn~:@p" (2) "2 pennies")
	# 
	ok def-format-test(
		Q{~O penn~:@P}, ( 2 ), Q{2 pennies}
	), Q{format.p.11};
	)

	#`(
	# (def-format-test format.p.12
	#   "~D penn~@:P" (0) "0 pennies")
	# 
	ok def-format-test(
		Q{~O penn~:@P}, ( 0 ), Q{0 pennies}
	), Q{format.p.12};
	)

	#`(
	# (def-format-test format.p.13
	#   "~D penn~@:p" ("No") "No pennies")
	# 
	ok def-format-test(
		Q{~O penn~@:P}, ( Q{No} ), Q{No pennies}
	), Q{format.p.13};
	)
}, Q{:@p};

subtest {
	1;
	#`(
	# (def-format-test format.p.14
	#   "~@p" (1) "y")
	# 
	ok def-format-test( Q{~@p}, ( 1 ), Q{y} ), Q{format.p.14};
	)

	#`(
	# (def-format-test format.p.15
	#   "~@P" (2) "ies")
	# 
	ok def-format-test( Q{~@P}, ( 2 ), Q{ies} ), Q{format.p.15};
	)

	#`(
	# (def-format-test format.p.16
	#   "~@p" (0) "ies")
	# 
	ok def-format-test( Q{~@p}, ( 0 ), Q{ies} ), Q{format.p.16};
	)

	#`(
	# (def-format-test format.p.17
	#   "~@P" (1.0) "ies")
	# 
	ok def-format-test( Q{~@P}, ( 1.0 ), Q{ies} ), Q{format.p.17};
	)

	#`(
	# (deftest format.p.18
	#   (loop for x in *universe*
	#         for s = (format nil "~@p" x)
	#         unless (or (eql x 1) (string= s "ies"))
	#         collect (list x s))
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
	), Q{format.p.18};
	)

	#`(
	# (deftest formatter.p.18
	#   (let ((fn (formatter "~@P")))
	#     (loop for x in *universe*
	#           for s = (formatter-call-to-string fn x)
	#           unless (or (eql x 1) (string= s "ies"))
	#           collect (list x s)))
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
	), Q{formatter.p.18};
	)
}, Q{@p};

done-testing;

# vim: ft=perl6
