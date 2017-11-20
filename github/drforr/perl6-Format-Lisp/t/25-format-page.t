use v6;

use Test;
use lib 't/lib';
use Utils;
use Format::Lisp;

my $fl = Format::Lisp.new;

# (def-format-test format.page.1
#   "~0|" nil "")
# 
is $fl.format( Q{~0|} ), Q{}, Q{format.page.1};

#`(
# (deftest format.page.2
#   (let ((s (format nil "~|")))
#     (cond
#      ((string= s "") nil)
#      ((> (length s) 1) (values s :too-long))
#      (t
#       (let ((c (elt s 0)))
#         (loop for i from 2 to 100
#               for s = (format nil (format nil "~~~D|" i))
#               unless (and (= (length s) i)
#                           (every #'(lambda (c2) (char= c c2)) s))
#               collect i)))))
#   nil)
# 
)

#`(
# (deftest format.page.3
#   (let ((s (format nil "~|")))
#     (cond
#      ((string= s "") nil)
#      ((> (length s) 1) (values s :too-long))
#      (t
#       (let ((c (elt s 0)))
#         (loop for i from 2 to 100
#               for s = (format nil "~v|" i)
#               unless (and (= (length s) i)
#                           (every #'(lambda (c2) (char= c c2)) s))
#               collect i)))))
#   nil)
# 
)

# (def-format-test format.page.4
#   "~V|" (0) "")
# 
is $fl.format( Q{~V|}, 0 ), Q{}, Q{format.page.4};

# (def-format-test format.page.5
#   "~v|" (nil) #.(format nil "~|"))
# 
is $fl.format( Q{~v|}, Nil ), $fl.format( Q{~|} ), Q{format.page.5};

done-testing;

# vim: ft=perl6
