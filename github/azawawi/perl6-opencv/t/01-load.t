use v6;

use Test;
use lib 'lib';

plan 2;

use OpenCV;
ok 1, "'use OpenCV' worked!";

use OpenCV::NativeCall;
ok 1, "'use OpenCV::NativeCall' worked!";