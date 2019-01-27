use v6;
use Test;
use BSON::Document;

my BSON::Document $d .= new;

$d<array> = [ 10, 'abc', 345, [ 45, 46, 57, 68, 'a', 'b', 'g']];

my Buf $edoc = $d.encode;
ok $edoc.elems > 1, 'some bytes';



my BSON::Document $dnew .= new;
$dnew.decode($edoc);

is $dnew<array>[2], 345, 'array[2] = 345';
is-deeply $dnew<array>,
          [ 10, 'abc', 345, [ 45, 46, 57, 68, 'a', 'b', 'g']],
          'array check';
#-------------------------------------------------------------------------------
# Cleanup
#
done-testing;
exit(0);
