use v6;

use Test;
use lib 't/lib';
use Utils;
use Format::Lisp;

my $*fl = Format::Lisp.new;

# (def-format-test format.%.1
#   "~%" nil #.(string #\Newline))
# 
ok def-format-test( Q{~%}, Nil, qq{\n} ), Q{format.%.1};

#`(
# (deftest format.%.2
#   (loop for i from 0 to 100
#         for s1 = (make-string i :initial-element #\Newline)
#         for format-string = (format nil "~~~D%" i)
#         for s2 = (format nil format-string)
#         for fn = (eval `(formatter ,s2))
#         for s3 = (formatter-call-to-string fn)
#         unless (and (string= s1 s2) (string= s1 s3))
#         collect i)
#   nil)
# 
ok deftest( {
	my @collected;
	for 0 .. 10 -> $i {
#		my @args = 
##		my $s = $*fl.format( Q{~v,,2A}, $i, 'ABC' );
#		my $s2 = formatter-call-to-string( $fn, $i, 'ABC' );
#		is $s, $s2;
#		@collected.append( $s );
	}
	@collected;
}, [ ]
), Q{format.%.2};
)

#`(
# (def-format-test format.%.3
#   "~v%" (nil) #.(string #\Newline))
# 
ok def-format-test( Q{~v%}, Nil, qq{\n} ), Q{format.%.3};
)

# (def-format-test format.%.4
#   "~V%" (1) #.(string #\Newline))
# 
ok def-format-test( Q{~v%}, ( 1 ), qq{\n} ), Q{format.%.4};

# (deftest format.%.5
#   (loop for i from 0 to 100
#         for s1 = (make-string i :initial-element #\Newline)
#         for s2 = (format nil "~v%" i)
#         unless (string= s1 s2)
#         collect i)
#   nil)
# 
ok deftest( {
	my @collected;
	for 0 .. 100 -> $i {
		my $s1 = qq{\n} x $i;
		my $s2 = $*fl.format( Q{~v%}, $i );
		unless $s1 eq $s2 {
			@collected.append( $i )
		}
	}
	@collected;
}, [ ]
), Q{format.%.5};

#`(
# (deftest formatter.%.5
#   (let ((fn (formatter "~v%")))
#     (loop for i from 0 to 100
#           for s1 = (make-string i :initial-element #\Newline)
#           for s2 = (formatter-call-to-string fn i)
#           unless (string= s1 s2)
#           collect i))
#   nil)
# 
ok deftest( {
	my $fn = $*fl.formatter( Q{~v%} );
	my @collected;
	for 0 .. 100 -> $i {
#		my @args = 
#		is $s, $s2;
#		@collected.append( $s );
	}
	@collected;
}, [ ]
), Q{formatter.%.5};
)

#`(
# (deftest format.%.6
#   (loop for i from 0 to (min (- call-arguments-limit 3) 100)
#         for args = (make-list i)
#         for s1 = (make-string i :initial-element #\Newline)
#         for s2 = (apply #Q{format nil "~#%" args)
#         unless (string= s1 s2)
#         collect i)
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
), Q{format.%.6};
)

#`(
# (deftest formatter.%.6
#   (let ((fn (formatter "~#%")))
#     (loop for i from 0 to (min (- call-arguments-limit 3) 100)
#           for args = (make-list i)
#           for s1 = (make-string i :initial-element #\Newline)
#           for s2 = (with-output-to-string
#                      (stream)
#                      (assert (equal (apply fn stream args) args)))
#           unless (string= s1 s2)
#           collect i))
#   nil)
# 
ok deftest( {
	my $fn = $*fl.formatter( Q{~#%} );
	my @collected;
	for 0 .. 10 -> $i {
#		my @args = 
#		is $s, $s2;
#		@collected.append( $s );
	}
	@collected;
}, [ ]
), Q{formatter.%.6};
)

done-testing;

# vim: ft=perl6
