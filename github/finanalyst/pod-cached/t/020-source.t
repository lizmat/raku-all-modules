use lib 'lib';
use Test;
use Test::Output;
use File::Directory::Tree;
use JSON::Fast;
use Pod::To::Cached;

constant REP = 't/tmp/ref';
constant DOC = 't/tmp/doc';
constant INDEX = REP ~ '/file-index.json';

plan 36;

my Pod::To::Cached $cache;

mktree DOC;
#--MARKER-- Test 1
throws-like { $cache .= new( :source( DOC ), :path( REP ) ) },
    Exception, :message(/'No POD files found under'/), 'Detects absence of source files';

(DOC ~ '/a-pod-file.pod6').IO.spurt(q:to/POD-CONTENT/);
    =pod A test file
    =TITLE This is a title

    Some text

    =end pod
    POD-CONTENT

(DOC ~ '/a-second-pod-file.pod6').IO.spurt(q:to/POD-CONTENT/);
    =pod Another test file
    =TITLE More and more

    Some more text

    =end pod
    POD-CONTENT
# Change the extension but not the name
(DOC ~ '/a-second-pod-file.pod').IO.spurt(q:to/POD-CONTENT/);
    =pod Another test file
    =TITLE More and more

    Some more text

    =end pod
    POD-CONTENT

#--MARKER-- Test 2
throws-like { $cache .= new( :source( DOC ), :path( REP ))},
    Exception, :message(/'duplicates name of'/), 'Detects duplication of source file names';

(DOC ~ '/a-second-pod-file.pod').IO.unlink ;
#--MARKER-- Test 3
nok REP.IO ~~ :d, 'No cache directory should be created yet';
#--MARKER-- Test 4
lives-ok { $cache .= new( :source( DOC ), :path( REP ), :!verbose) }, 'Instantiates OK';
#--MARKER-- Test 5
ok REP.IO ~~ :d, 'Correctly creates the cache directory';
#--MARKER-- Test 6
ok INDEX.IO ~~ :f, 'index file has been created';
my %config;
#--MARKER-- Test 7
lives-ok { %config = from-json( INDEX.IO.slurp ) }, 'good json in index';
#--MARKER-- Test 8
ok (%config<frozen>:exists and %config<frozen> ~~ 'False'), 'frozen is False as expected';
#--MARKER-- Test 9
ok (%config<files>:exists
    and %config<files>.WHAT ~~ Hash)
    , 'files is as expected';
#--MARKER-- Test 10
is +%config<files>.keys, 0, 'No source files in index because nothing in cache';

my $mod-time = INDEX.IO.modified;
my $rv;
#--MARKER-- Test 11
lives-ok {$rv = $cache.update-cache}, 'Updates cache without dying';
#--MARKER-- Test 12
nok $rv, 'Returned false because of compile errors';
#--MARKER-- Test 13
like $cache.error-messages[0], /'Compile error in'/, 'Error messages saved';
#--MARKER-- Test 14
is-deeply $cache.hash-files, ( 'a-pod-file' => 'Failed', 'a-second-pod-file'=>'Failed').hash, 'lists Failed files';
#--MARKER-- Test 15
nok INDEX.IO.modified > $mod-time, 'INDEX not modified';
#--MARKER-- Test 16
is +gather for $cache.files.kv -> $nm, %inf { take 'f' unless %inf<handle>:exists },
    2, 'No handles are defined for Failed files';

$cache.verbose = True;
#--MARKER-- Test 17
stderr-like { $cache.update-cache }, /'Cache not fully updated'/, 'Got correct progress message';
$cache.verbose = False;

(DOC ~ '/a-pod-file.pod6').IO.spurt(q:to/POD-CONTENT/);
    =begin pod
    =TITLE This is a title

    Some text

    =end pod
    POD-CONTENT

(DOC ~ '/a-second-pod-file.pod6').IO.spurt(q:to/POD-CONTENT/);
    =begin pod
    =TITLE More and more

    Some more text

    =end pod
    POD-CONTENT

#--MARKER-- Test 18
ok $cache.update-cache, 'Returned true because both POD now compile';
# this works because the source paths are in the cache object, and they are new

#--MARKER-- Test 19
is-deeply $cache.hash-files, ( 'a-pod-file' => 'Current', 'a-second-pod-file'=>'Current').hash, 'hash-files shows two pod Current';

#--MARKER-- Test 20
ok INDEX.IO.modified > $mod-time, 'INDEX has been modified because update cache ok';

(DOC ~ '/a-second-pod-file.pod6').IO.spurt(q:to/POD-CONTENT/);
    =begin pod
    =TITLE More and more

    Some more text but now it is changed

    =end pod
    POD-CONTENT
$cache .= new( :source( DOC ), :path( REP ));
#--MARKER-- Test 21
is-deeply $cache.hash-files, ( 'a-pod-file' => 'Current', 'a-second-pod-file'=>'Valid').hash, 'One current, one tainted';
#--MARKER-- Test 22
is-deeply $cache.list-files( <Valid Current> ), ( 'a-pod-file' , 'a-second-pod-file', ), 'List with list of statuses';
$cache.update-cache;
#--MARKER-- Test 23
is-deeply $cache.hash-files, ( 'a-pod-file' => 'Current', 'a-second-pod-file'=>'Current').hash, 'Both updated';

#has an error
(DOC ~ '/a-pod-file.pod6').IO.spurt(q:to/POD-CONTENT/);
    =pod A test file
    =TITLE This is a title

    Some text

    =end pod
    POD-CONTENT

$cache .= new( :source( DOC ), :path( REP ));
#--MARKER-- Test 24
is-deeply $cache.hash-files, ( 'a-pod-file' => 'Valid', 'a-second-pod-file'=>'Current').hash, 'One current, one tainted';
$cache.update-cache;
#--MARKER-- Test 25
is-deeply $cache.hash-files, ( 'a-pod-file' => 'Valid', 'a-second-pod-file'=>'Current').hash, 'One remains Valid because new version did not compile';
#--MARKER-- Test 26
like $cache.error-messages.join, /'Compile error'/, 'Error detected in pod';

#--MARKER-- Test 27
lives-ok { $rv = $cache.cache-timestamp('a-pod-file')}, 'method cache-timestamp lives';
#--MARKER-- Test 28
ok $rv ~~ Instant, 'return value is an Instant';
#--MARKER-- Test 29
ok $rv < (DOC ~ '/a-pod-file.pod6').IO.modified, 'new file not added to cache because it did not compile';
# return to valid pod;
(DOC ~ '/a-pod-file.pod6').IO.spurt(q:to/POD-CONTENT/);
    =begin pod
    =TITLE This is a title

    Some text

    =end pod
    POD-CONTENT

#--MARKER-- Test 30
lives-ok {$cache .=new(:path( REP ))}, 'with a valid cache, source can be omitted';
$cache.update-cache;
#--MARKER-- Test 31
is-deeply $cache.hash-files, ( 'a-pod-file' => 'Current', 'a-second-pod-file'=>'Current').hash, 'Both Current now';
#--MARKER-- Test 32
ok (DOC ~ '/a-pod-file.pod6').IO.modified < $cache.cache-timestamp('a-pod-file'), 'new file compiles so timestamp after modification';
(DOC ~ '/pod-file-to-deprecate.pod6').IO.spurt(q:to/POD-CONTENT/);
    =begin pod
    =TITLE This will be disappear from source

    Some more text but now it is changed

    =end pod
    POD-CONTENT
$cache .=new(:path(REP));
$cache.update-cache;
#--MARKER-- Test 33
is +$cache.hash-files.keys, 3, 'file added';
(DOC ~ '/pod-file-to-deprecate.pod6').IO.unlink;
#--MARKER-- Test 34
stderr-like {$cache .=new(:path(REP),:verbose)}, /
    'names not associated with pod files:'
    .+ 'pod-file-to-deprecate'
    /, 'detects old files';
$cache.verbose = False;
$cache.update-cache;
#--MARKER-- Test 35
is-deeply $cache.hash-files, ( 'a-pod-file' => 'Current', 'a-second-pod-file'=>'Current', 'pod-file-to-deprecate' => 'Old').hash, 'An Old file is detected';
#has an error
(DOC ~ '/a-pod-file.pod6').IO.spurt(q:to/POD-CONTENT/);
    =pod A test file
    =TITLE This is a title

    Some text

    =end pod
    POD-CONTENT

$cache .= new( :source( DOC ), :path( REP ));
is-deeply $cache.hash-files(<Valid Old>), %( 'a-pod-file' => 'Valid', 'pod-file-to-deprecate' => 'Old'), 'hash-files with seq of statuses correct';
# remove rep with old source
rmtree REP;
#restore valid source file for later tests.
(DOC ~ '/a-pod-file.pod6').IO.spurt(q:to/POD-CONTENT/);
    =begin pod
    =TITLE This is a title

    Some text

    =end pod
    POD-CONTENT
