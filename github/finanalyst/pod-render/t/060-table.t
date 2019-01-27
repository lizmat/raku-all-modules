use lib 'lib';
use Test;
use PodCache::Render;
use PodCache::Processed;
use File::Directory::Tree;

plan 5;
my $fn = 'tables-test-pod-file_0';
diag 'Tables';

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
    =table
      col1  col2

    PODEND

#--MARKER-- Test 1
like $pr.pod-body.subst(/\s+/,' ',:g).trim, /
    \s* '<table class="pod-table">'
    \s*   '<tbody>'
    \s*     '<tr>'
    \s*       '<td>col1</td>'
    \s*       '<td>col2</td>'
    \s*     '</tr>'
    \s*   '</tbody>'
    \s* '</table>'
    /, 'simple row';

$pr = cache_test(++$fn, q:to/PODEND/);
    =table
      H1    H2
      --    --
      col1  col2

    PODEND

#--MARKER-- Test 2
like $pr.pod-body.subst(/\s+/,' ',:g).trim, /
    \s*   '<thead>'
    \s*     '<tr>'
    \s*       '<th>H1</th>'
    \s*       '<th>H2</th>'
    \s*     '</tr>'
    \s*   '</thead>'
    \s*   '<tbody>'
    \s*     '<tr>'
    \s*       '<td>col1</td>'
    \s*       '<td>col2</td>'
    \s*     '</tr>'
    \s*   '</tbody>'
    \s* '</table>'
    /,'simple header and row';


$pr = cache_test(++$fn, q:to/PODEND/);
    =begin table :class<sorttable>

      H1    H2
      --    --
      col1  col2

      col1  col2

    =end table

    PODEND

#--MARKER-- Test 3
like $pr.pod-body.subst(/\s+/,' ',:g).trim, /
    '<table class="pod-table sorttable">'
    \s*   '<thead>'
    \s*     '<tr>'
    \s*       '<th>H1</th>'
    \s*       '<th>H2</th>'
    \s*     '</tr>'
    \s*   '</thead>'
    \s*   '<tbody>'
    \s*     '<tr>'
    \s*       '<td>col1</td>'
    \s*       '<td>col2</td>'
    \s*     '</tr>'
    \s*     '<tr>'
    \s*       '<td>col1</td>'
    \s*       '<td>col2</td>'
    \s*     '</tr>'
    \s*   '</tbody>'
    \s* '</table>'
    /, 'table with class';

$pr = cache_test(++$fn, q:to/PODEND/);
    =begin table :caption<Test Caption>

      H1    H2
      --    --
      col1  col2

    =end table

    PODEND

#--MARKER-- Test 4
like $pr.pod-body.subst(/\s+/,' ',:g).trim, /
    '<table class="pod-table">'
    \s*   '<caption>Test Caption</caption>'
    \s*   '<thead>'
    \s*     '<tr>'
    \s*       '<th>H1</th>'
    \s*       '<th>H2</th>'
    \s*     '</tr>'
    \s*   '</thead>'
    \s*   '<tbody>'
    \s*     '<tr>'
    \s*       '<td>col1</td>'
    \s*       '<td>col2</td>'
    \s*     '</tr>'
    \s*   '</tbody>'
    \s* '</table>'
    /, 'table with caption';

$pr = cache_test(++$fn, q:to/PODEND/);
    =begin table :class<sorttable>

      H1    H2
      --    --
      col1  B<col2>

      I<col1>  col2

    =end table

    PODEND

todo 'Compiler does not give information about contents of POD table cells';
#--MARKER-- Test 5
like $pr.pod-body.subst(/\s+/,' ',:g).trim, /
    '<table class="pod-table sorttable">'
    \s*   '<thead>'
    \s*     '<tr>'
    \s*       '<th>H1</th>'
    \s*       '<th>H2</th>'
    \s*     '</tr>'
    \s*   '</thead>'
    \s*   '<tbody>'
    \s*     '<tr>'
    \s*       '<td><strong>col1</strong></td>'
    \s*       '<td>col2</td>'
    \s*     '</tr>'
    \s*     '<tr>'
    \s*       '<td><em>col1</em></td>'
    \s*       '<td>col2</td>'
    \s*     '</tr>'
    \s*   '</tbody>'
    \s* '</table>'
    /, 'table with class';