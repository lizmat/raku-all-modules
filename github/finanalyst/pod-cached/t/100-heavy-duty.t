#! /usr/bin/env perl6
use v6.*;
use lib 'lib';
use Test;
use Test::Output;
use File::Directory::Tree;
use Pod::To::Cached;

diag 'Heavy duty test optional';
done-testing; exit; # comment this line out to get test

if 't/tmp'.IO ~~ :d  {
    empty-directory 't/tmp';
}
else {
    mktree 't/tmp'
}
mktree 't/tmp/doc';

# set up pod files
constant DRY-RUN = 5;
constant HEAVY-RUN = 70;
constant TEST-FILE = 't/doctest/community.pod6';

my $text = TEST-FILE.IO.slurp;
my Pod::To::Cached $cache;
my ( $start1, $start2, $stop1, $stop2);

"t/tmp/doc/test-$_.pod6".IO.spurt($text) for ^DRY-RUN;
#--MARKER-- Test 1
is +'t/tmp/doc'.IO.dir, DRY-RUN, 'files written';
$start1 = now;
#--MARKER-- Test 2
lives-ok { $cache .= new(:path<t/tmp/ref>, :source<t/tmp/doc>); $cache.update-cache }, 'dry run lives';
$stop1 = now;
#--MARKER-- Test 3
is +$cache.list-files( 'Current' ), DRY-RUN, DRY-RUN ~ ' files cached as compiled';

empty-directory 't/tmp';
mktree 't/tmp/doc';

diag 'Starting Heavy run';
"t/tmp/doc/test-$_.pod6".IO.spurt($text) for ^HEAVY-RUN;
#--MARKER-- Test 4
is +'t/tmp/doc'.IO.dir, HEAVY-RUN, 'files written';
$start2 = now;
$cache .= new(:path<t/tmp/ref>, :source<t/tmp/doc>);
$cache.update-cache ;
$stop2 = now;
#--MARKER-- Test 6
is +$cache.list-files( 'Current' ), HEAVY-RUN, HEAVY-RUN ~ ' files cached as compiled';

diag "Dry run took " ~ DateTime.new($stop1 - $start1).hh-mm-ss ~ '. Heavy run took ' ~ DateTime.new($stop2-$start2).hh-mm-ss;
empty-directory 't/tmp';

done-testing;
