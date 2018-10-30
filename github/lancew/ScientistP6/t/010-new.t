use lib 'lib';

use Scientist;
use Test;

plan 2;

throws-like { Scientist.new }, Exception, message =>
q/The attribute '&!use' is required, but you did not provide a value for it./,
'use is required';

ok Scientist.new( use => sub {} ).enabled, 'enabled defaults to True';
