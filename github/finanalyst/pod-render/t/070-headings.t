use lib 'lib';
use Test;
use PodCache::Render;
use PodCache::Processed;
use File::Directory::Tree;

plan 2;
my $fn = 'headings-test-pod-file_0';
diag 'Headings';

constant REP = 't/tmp/rep';
constant DOC = 't/tmp/doc';
constant OUTPUT = 't/tmp/html';

mktree OUTPUT unless OUTPUT.IO ~~ :d;
my PodCache::Processed $pr;

sub cache_test(Str $fn is copy, Str $to-cache --> PodCache::Processed ) {
    (DOC ~ "/$fn.pod6").IO.spurt: $to-cache;
    my PodCache::Render $ren .= new(:path( REP ), :output( OUTPUT ) );
    $ren.update-cache;
    $ren.processed-instance( :name($fn) );
}

$pr = cache_test(++$fn, q:to/PODEND/);
    =begin pod

    =head1 Heading 1

    =head2 Heading 1.1

    =head2 Heading 1.2

    =head1 Heading 2

    =head2 Heading 2.1

    =head2 Heading 2.2

    =head2 L<(Exception) method message|/routine/message#class_Exception>

    =head3 Heading 2.2.1

    =head3 X<Heading> 2.2.2

    =head1 Heading C<3>

    =end pod
    PODEND

my $html = $pr.pod-body.subst(/\s+/,' ',:g).trim;

#--MARKER-- Test 1
like $html, /'h2 id="heading_2.2"' .+ '>Heading 2.2'/, 'Heading 2.2 has expected id';
#--MARKER-- Test 2
like $html, /'class="index-entry">Heading' .+ '2.2.2</a>' / , 'Heading 2.2.2 is indexed';