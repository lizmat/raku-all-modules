use lib 'lib';
use Test;
use PodCache::Render;
use PodCache::Processed;
use File::Directory::Tree;

plan 1;
my $fn = 'preserve-html-test-pod-file_0';
diag 'html';

constant REP = 't/tmp/rep';
constant DOC = 't/tmp/doc';
constant OUTPUT = 't/tmp/html';

mktree OUTPUT unless OUTPUT.IO ~~ :d;
my PodCache::Processed $pr;
my Str $rv;

sub cache_test(Str $fn is copy, Str $to-cache --> PodCache::Processed ) {
    (DOC ~ "/$fn.pod6").IO.spurt: $to-cache;
    my PodCache::Render $ren .= new(:path( REP ), :output( OUTPUT ) );
    $ren.update-cache;
    $ren.processed-instance( :name($fn) );
}

$pr = cache_test(++$fn, q:to/PODEND/);
    =begin Html
    <img style="float: right; margin: 0 0 1em 1em; width:261px" src="/images/Camelia.svg" alt="" id="home_logo"/>
    Welcome to the official documentation of the <a href="https://perl6.org">Perl 6</a>
    programming language!
    Besides online browsing and searching, you can also
    <a href="/perl6.html">view everything in one file</a> or
    <a href="https://github.com/perl6/doc">contribute</a>
    by reporting mistakes or sending patches.

    <hr/>
    =end Html
    PODEND

$rv = $pr.pod-body.subst(/\s+/,' ',:g).trim;
#--MARKER-- Test 1
like $rv, /
    '<img style="float: right; margin: 0 0 1em 1em; width:261px" src="/images/Camelia.svg" alt="" id="home_logo"/>'
    \s* ' Welcome to the official documentation of the <a href="https://perl6.org">Perl 6</a> programming language!'
    \s* 'Besides online browsing and searching, you can also <a href="/perl6.html">view everything in one file</a> or'
    \s* '<a href="https://github.com/perl6/doc">contribute</a> by reporting mistakes or sending patches.<hr/>'
    /, 'html as expected';