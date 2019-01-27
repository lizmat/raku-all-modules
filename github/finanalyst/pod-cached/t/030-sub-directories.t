use lib 'lib';
use Test;
use Test::Output;
use File::Directory::Tree;
use JSON::Fast;
use Pod::To::Cached;

constant REP = 't/tmp/ref';
constant DOC = 't/tmp/doc';
constant INDEX = REP ~ '/file-index.json';

my Pod::To::Cached $cache;
my $content = q:to/PODEND/;
    =begin pod
    Some text
    =end pod
    PODEND

for <sub-dir-1 sub-dir-2 sub-dir-3> -> $d {
    mktree DOC ~ "/$d";
    (DOC ~ "/$d/a-file-$_.pod6").IO.spurt($content) for 1..4
}

#--MARKER-- Test 1
lives-ok { $cache .=new( :path( REP ), :source( DOC ) )}, 'doc cache created with sub-directories';
$cache.update-cache;
#--MARKER-- Test 2
lives-ok { $cache.update-cache }, 'update cache with sub-dirs';
#--MARKER-- Test 3
nok 'sub-dir-1' ~~ any( $cache.hash-files.keys ), 'sub-directories filtered from file list';


't'.IO.&indir( {$cache .= new(:source( 'tmp/doc' ) ) } );
#--MARKER-- Test 4
ok 't/.pod-cache'.IO ~~ :d, 'default repository created';
rmtree 't/.pod-cache';

done-testing;
