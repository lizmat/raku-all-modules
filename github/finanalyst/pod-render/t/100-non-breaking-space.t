use lib 'lib';
use Test;
use File::Directory::Tree;
use PodCache::Render;
use PodCache::Processed;

plan 3;

constant REP = 't/tmp/rep';
constant DOC = 't/tmp/doc';
constant OUTPUT = 't/tmp/html';
my $fn = 'non-breaking-space-test-pod-file_0';

mktree OUTPUT unless OUTPUT.IO ~~ :d;
my PodCache::Processed $pr;

sub cache_test(Str $fn is copy, Str $to-cache --> PodCache::Processed ) {
    (DOC ~ "/$fn.pod6").IO.spurt: $to-cache;
    my PodCache::Render $ren .= new(:path( REP ), :output( OUTPUT ) );
    $ren.update-cache;
    $ren.processed-instance( :name($fn) );
}

$pr = cache_test(++$fn, q:to/PODEND/);
    =begin foo
    =end foo
    PODEND

#--MARKER-- Test 1
like $pr.pod-body, /
    '<section name="Foo">'
    \s* '<h' .+ '<a' .+ 'Foo'
    .+ '</section>'
    /, 'section test';

$pr = cache_test(++$fn, q:to/PODEND/);
    =begin foo
    some text
    =end foo
    PODEND
#--MARKER-- Test 2
like $pr.pod-body, /
    '<section name="Foo">'
    \s* '<h' .+ '<a' .+ 'Foo'
    '</a></h'
    .+ 'some text'
    .+ '</section>'
    /, 'section + heading';

$pr = cache_test(++$fn, q:to/PODEND/);
    =head1 Talking about Perl 6
    PODEND

if  $*PERL.compiler.name eq 'rakudo'
and $*PERL.compiler.version before v2018.06 {
    skip "Your rakudo is too old for this test. Need 2018.06 or newer";
}
else {
#--MARKER-- Test 3
    unlike $pr.pod-body, / 'Perl 6' /, "no-break space is not converted to other space";
}