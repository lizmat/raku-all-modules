use lib 'lib';
use Test;
use Test::Output;
use File::Directory::Tree;
use Pod::To::Cached;

constant REP = 't/tmp/ref';
constant DOC = 't/tmp/doc';
constant INDEX = REP ~ '/file-index.json';

plan 11;

my Pod::To::Cached $cache;
my $rv;
diag 'test pod extraction';
$cache .= new( :path( REP ));
#--MARKER-- Test 1
ok $cache.pod('a-pod-file')[0] ~~ Pod::Block::Named, 'pod is returned from cache';


(DOC ~ '/a-second-pod-file.pod6').IO.spurt(q:to/POD-CONTENT/);
    =begin pod
    =TITLE More and more

    Some extra changed text but now it is changed

    =end pod
    POD-CONTENT

$cache .=new(:path( REP ));
my %h = $cache.hash-files;
#--MARKER-- Test 2
is %h<a-second-pod-file>, 'Valid', 'The old version is still in cache, no update-cache';
#--MARKER-- Test 3
lives-ok { $rv = $cache.pod('a-second-pod-file') }, 'Old Pod is provided';

#--MARKER-- Test 4
like $rv[0].contents[1].contents[0], /'Some more text but now it is changed'/, 'previous text in source';

diag 'testing freeze';
#--MARKER-- Test 5
throws-like { $cache.freeze }, Exception, :message(/'Cannot freeze because some files not Current'/), 'Cant freeze when a file not Current';
#--MARKER-- Test 6
ok $cache.update-cache, 'updates without problem';

#--MARKER-- Test 7
like $cache.pod('a-second-pod-file')[0].contents[1].contents[0], /'Some extra changed text but now it is changed'/, 'new version after update';
#--MARKER-- Test 8
lives-ok { $cache.freeze }, 'All updated so now can freeze';

#rmtree DOC;
#--MARKER-- Test 9
lives-ok { $cache .=new(:path( REP )) }, 'Gets a frozen cache without source';

#--MARKER-- Test 10
throws-like { $cache.update-cache }, Exception, :message(/ 'Cannot update frozen cache'/), 'No updating on a frozen cache';

#--MARKER-- Test 11
throws-like {$cache.pod('xxxyyyzz') }, Exception, :message(/ 'Source name ｢xxxyyyzz｣ not in cache'/), 'Cannot get POD for invalid source name';
