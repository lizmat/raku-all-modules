#!/usr/bin/env perl6
use v6.c;
use lib 'lib';
use Test;
use Test::Output;
use File::Directory::Tree;
use Pod::To::Cached;

constant REP = 't/tmp/rep';
constant DOC = 't/tmp/doc';
constant OUTPUT = 't/tmp/html'; #will also be config by default

plan 10;
diag "Basic";

rmtree 't/tmp';
mktree DOC;

( DOC ~ '/a-pod-file.pod6').IO.spurt(q:to/POD-CONTENT/);
    =begin pod
    =TITLE This is a title

    Some text

    =end pod
    POD-CONTENT

( DOC ~ '/a-second-pod-file.pod6').IO.spurt(q:to/POD-CONTENT/);
    =begin pod
    =TITLE A Second Pod File

    =SUBTITLE This is subtitled for testing

    Some more text

    =head2 This is a heading

    Some text after a heading

    =end pod
    POD-CONTENT

my $cache = Pod::To::Cached.new(:path( REP ), :source( DOC ));
$cache.update-cache;

#--MARKER-- Test 1
use-ok 'PodCache::Render';
use PodCache::Render;
my PodCache::Render $renderer;

#--MARKER-- Test 2
lives-ok { $renderer .= new(:path( REP ), :output( OUTPUT ))}, 'instantiates';
#--MARKER-- Test 3
ok OUTPUT.IO.d, 'output directory created';

my $pod;
#--MARKER-- Test 4
ok ($pod = $renderer.pod('a-pod-file'))[0] ~~ Pod::Block, 'returns a Pod block';

#--MARKER-- Test 5
use-ok 'PodCache::Processed';
use  PodCache::Processed;
my PodCache::Processed $pf;

#--MARKER-- Test 6
lives-ok { $pf = $renderer.processed-instance(:name<a-pod-file> ) }, 'Processed file instance is created';
$renderer.debug = True;
#--MARKER-- Test 7
output-like { $renderer.processed-instance(:name<a-pod-file> ) }, / 'pod-tree is:' /, 'Debug info is given';
$renderer.debug = False;
#--MARKER-- Test 8
like $pf.pod-body.subst(/\s+/,' ', :g).trim,
    /
    '<section name="___top">'
    \s* '<h1 class="title" id="this_is_a_title">This is a title</h1>'  # the first header id
    \s* '<p>Some text</p>'
    \s* '</section>'
    /,
    'simple pod rendered';

$pf = $renderer.processed-instance(:name<a-second-pod-file>);
#--MARKER-- Test 9
like $pf.pod-body, /
    '<h1 class="title" id="a_second_pod_file">A Second Pod File</h1>'
    \s* '<div class="subtitle">' \s* '<p>This is subtitled for testing</p>'
    .+ '<p>Some more text</p>'
    \s* '<h2 id="this_is_a_heading"><a href="#a_second_pod_file" class="u" title="go to top of document">This is a heading</a></h2>'
    \s* '<p>Some text after a heading</p>'
    /, 'title rendered';
#--MARKER-- Test 10
like $pf.render-toc.subst(/\s+/,' ', :g).trim,
    /
          '<table id="TOC">'
    \s* '<caption>'
    \s* '<h2 id="TOC_Title">Table of Contents</h2></caption>'
    \s* '<tr class="toc-level-2">'
    \s* '<td class="toc-text">'
    \s* '<a href="#this_is_a_heading">This is a heading</a>'
    \s* '</td>'
    \s* '</tr>'
    \s* '</table>'
    /
    , 'rendered simple toc';