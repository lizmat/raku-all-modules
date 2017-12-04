use v6;

use Test;
use lib 't/lib';
use Utils;
use Format::Lisp;

my $*fl = Format::Lisp.new;

subtest {
	is $*fl.format( Q{~C}, Q{a} ), Q{a}, Q{format.c.1};

	is $*fl.format( Q{~c}, Q{Ø} ), Q{Ø}, Q{format.c.1a};

	is $*fl.format( Q{~:c}, Q{ } ), Q{Space}, Q{format.c.2};

	is $*fl.format( Q{~:C}, qq{\n} ), Q{Linefeed}, Q{format.c.2a};

	# format.c.3 is its own coverage

	# format.c.4 is redundant

	# format.c.4a is redundant

	is $*fl.format( Q{~@c}, Q{a} ), Q{a}, Q{format.c.5};

	is $*fl.format( Q{~@C}, Q{Ø} ), Q{Ø}, Q{format.c.5a};

	# format.c.6 is redundant

	# format.c.6a is redundant
}, Q{missing coverage};

# (deftest format.c.1
#   (loop for c across +standard-chars+
#         for s = (format nil "~C" c)
#         unless (string= s (string c))
#         collect (list c s))
#   nil)
# 
ok deftest(
	{
		my @collected;
		for @standard-chars -> $c {
			my $s = $*fl.format( Q{~C}, $c );
			unless $s eq $c {
				@collected.append( [ $c, $s ] );
			}
		}
		@collected;
	}, [ ]
), Q{format.c.1};

#`(
# (deftest format.c.1a
#   (loop with count = 0
#         for i from 0 below (min #x10000 char-code-limit)
#         for c = (code-char i)
#         for s = (and c (format nil "~c" c))
#         unless (or (not c)
#                    (not (eql (char-code c) (char-int c)))
#                    (string= s (string c)))
#         do (incf count) and collect (list i c s)
#         when (> count 100) collect "count limit exceeded" and do (loop-finish))
#   nil)
# 
ok deftest(
	{
		my @collected;
		for @standard-chars -> $c {
			my $s = $*fl.format( Q{~c}, $c );
	#		unless $s eq $c {
	#			@collected.append( [ $c, $s ] );
	#		}
		}
		@collected;
	}, [ ]
), Q{format.c.1a};
)

#`(
# (deftest format.c.2
#   (loop for c across +standard-chars+
#         for s = (format nil "~:c" c)
#         unless (or (not (graphic-char-p c))
#                    (eql c #\Space)
#                    (string= s (string c)))
#         collect (list c s))
#   nil)
# 
ok deftest(
	{
		my @collected;
		for @standard-chars -> $c {
			my $s = $*fl.format( Q{~:c}, $c );
			unless $s eq $c {
	#			@collected.append( [ $c, $s ] );
			}
		}
		@collected;
	}, [ ]
), Q{format.c.2};
)

#`(
# (deftest format.c.2a
#   (loop with count = 0
#         for i from 0 below (min #x10000 char-code-limit)
#         for c = (code-char i)
#         for s = (and c (format nil "~:C" c))
#         unless (or (not c)
#                    (not (eql (char-code c) (char-int c)))
#                    (not (graphic-char-p c))
#                    (eql c #\Space)
#                    (string= s (string c)))
#         do (incf count) and collect (list i c s)
#         when (> count 100) collect "count limit exceeded" and do (loop-finish))
#   nil)
# 
ok deftest(
	{
		my @collected;
		for @standard-chars -> $c {
			my $s = $*fl.format( Q{~:C}, $c );
			unless $s eq $c {
	#			@collected.append( [ $c, $s ] );
			}
		}
		@collected;
	}, [ ]
), Q{format.c.2a};
)

# (def-format-test format.c.3
#   "~:C" (#\Space) #.(char-name #\Space))
# 
ok def-format-test( Q{~:C}, Q{ }, Q{Space} ), Q{format.c.3};

#`(
# (deftest format.c.4
#   (loop for c across +standard-chars+
#         for s = (format nil "~:C" c)
#         unless (or (graphic-char-p c)
#                    (string= s (char-name c)))
#         collect (list c (char-name c) s))
#   nil)
# 
ok deftest(
	{
		my @collected;
		for @standard-chars -> $c {
			my $s = $*fl.format( Q{~:C}, $c );
	#		unless $s eq $c {
	#			@collected.append( [ $c, $s ] );
	#		}
		}
		@collected;
	}, [ ]
), Q{format.c.4};
)

#`(
# (deftest format.c.4a
#   (loop with count = 0
#         for i from 0 below (min #x10000 char-code-limit)
#         for c = (code-char i)
#         for s = (and c (format nil "~:c" c))
#         unless (or (not c)
#                    (not (eql (char-code c) (char-int c)))
#                    (graphic-char-p c)
#                    (string= s (char-name c)))
#         do (incf count) and collect (print (list i c s))
#         when (> count 100) collect "count limit exceeded" and do (loop-finish))
#   nil)
# 
ok deftest(
	{
		my @collected;
		for @standard-chars -> $c {
			my $s = $*fl.format( Q{~:c}, $c );
	#		unless $s eq $c {
	#			@collected.append( [ $c, $s ] );
	#		}
		}
		@collected;
	},
	[ ]
), Q{format.c.4a};
)

#`(
# (deftest format.c.5
#   (loop for c across +standard-chars+
#         for s = (format nil "~@c" c)
#         for c2 = (read-from-string s)
#         unless (eql c c2)
#         collect (list c s c2))
#   nil)
# 
ok deftest(
	{
		my @collected;
		for @standard-chars -> $c {
			my $s = $*fl.format( Q{~@c}, $c );
	#		unless $s eq $c {
	#			@collected.append( [ $c, $s ] );
	#		}
		}
		@collected;
	},
	[ ]
), Q{format.c.5};
)

#`(
# (deftest format.c.5a
#   (loop with count = 0
#         for i from 0 below (min #x10000 char-code-limit)
#         for c = (code-char i)
#         for s = (and c (format nil "~@C" c))
#         for c2 = (and c (read-from-string s))
#         unless (eql c c2)
#         do (incf count) and collect (list c s c2)
#         when (> count 100) collect "count limit exceeded" and do (loop-finish))
#   nil)
#
ok deftest(
	{
		my @collected;
		for @standard-chars -> $c {
			my $s = $*fl.format( Q{~@C}, $c );
	#		unless $s eq $c {
	#			@collected.append( [ $c, $s ] );
	#		}
		}
		@collected;
	},
	[ ]
), Q{format.c.5};
)

#`(
# (deftest format.c.6
#   (loop for c across +standard-chars+
#         for s1 = (format nil "~:C" c)
#         for s2 = (format nil "~:@C" c)
#         unless (eql (search s1 s2) 0)
#         collect (list c s1 s2))
#   nil)
# 
ok deftest(
	{
		my @collected;
		for @standard-chars -> $c {
			my $s1 = $*fl.format( Q{~:C}, $c );
			my $s2 = $*fl.format( Q{~:@C}, $c );
	#		unless $s eq $c {
	#			@collected.append( [ $c, $s ] );
	#		}
		}
		@collected;
	},
	[ ]
), Q{format.c.6};
)

#`(
# (deftest format.c.6a
#   (loop with count = 0
#         for i from 0 below (min #x10000 char-code-limit)
#         for c = (code-char i)
#         for s1 = (and c (format nil "~:C" c))
#         for s2 = (and c (format nil "~@:C" c))
#         unless (or (not c) (eql (search s1 s2) 0))
#         do (incf count) and collect (list c s1 s2)
#         when (> count 100) collect "count limit exceeded" and do (loop-finish))
#   nil)
# 
ok deftest(
	{
		my @collected;
		for @standard-chars -> $c {
			my $s1 = $*fl.format( Q{~:C}, $c );
			my $s2 = $*fl.format( Q{~@:C}, $c );
	#		unless $s eq $c {
	#			@collected.append( [ $c, $s ] );
	#		}
		}
		@collected;
	},
	[ ]
), Q{format.c.6a};
)

done-testing;

# vim: ft=perl6
