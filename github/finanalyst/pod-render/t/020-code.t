use lib 'lib';
use Test;
use PodCache::Render;
use PodCache::Processed;
use File::Directory::Tree;

plan 2;
diag "pod code";

my $fn = 'code-test-pod-file_0';

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
    This ordinary paragraph introduces a code block:

        $this = 1 * code('block');
        $which.is_specified(:by<indenting>);
    =end pod
    PODEND

#--MARKER-- Test 1
like $pr.pod-body.subst(/\s+/,' ',:g).trim, /
    '<p>' \s* 'This ordinary paragraph introduces a code block:' \s* '</p>'
     \s* '<pre class="pod-block-code">$this = 1 * code(\'block\');'
     \s* '$which.is_specified(:by&lt;indenting&gt;);</pre>'
     /, 'code block';

$pr = cache_test(++$fn, q:to/PODEND/);
    =begin pod
    This is an ordinary paragraph

        While this is not
        This is a code block

        =head1 Mumble: "mumble"

        Surprisingly, this is not a code block
            (with fancy indentation too)

    But this is just a text. Again

    =end pod
    PODEND
#--MARKER-- Test 2
like $pr.pod-body.subst(/\s+/,' ',:g).trim, /
    '<p>' \s* 'This is an ordinary paragraph' \s* '</p>'
    \s* '<pre class="pod-block-code">While this is not'
    \s* 'This is a code block</pre>'
    \s* '<h1 id="mumble:_&quot;mumble&quot;">'
    \s* '<a' \s* [ 'class="u"' \s* | 'href="#___top"' \s* | 'title="go to top of document"' \s* ]**3 '>'
    \s* 'Mumble: &quot;mumble&quot;'
    \s* '</a>'
    \s* '</h1>'
    \s* '<p>' \s* 'Surprisingly, this is not a code block (with fancy indentation too)' \s* '</p>'
    \s* '<p>' \s* 'But this is just a text. Again' \s* '</p>'
    /, 'para with heading and anchor to top';