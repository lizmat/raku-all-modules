use v6.c;

use Test;
use XML::XPath;

my $x = XML::XPath.new( xml => '<foo><bar/><bar/></foo>');
is-deeply $x.find('/foo/bar', :to-list), $x.find('/foo/bar', :to-list).flat, 'is not item context';

done-testing;

