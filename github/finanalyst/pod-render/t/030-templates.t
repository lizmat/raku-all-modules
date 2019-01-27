use lib 'lib';
use Test;
use File::Directory::Tree;
use PodCache::Render;
use PodCache::Processed;
plan 4;

#temp $*CWD = 't/';

constant REP = 't/tmp/rep';
constant DOC = 't/tmp/doc';
constant TEMPL = 't/tmp/templates';
constant OUTPUT = 't/tmp/html';

mktree OUTPUT unless OUTPUT.IO ~~ :d;
rmtree TEMPL;
mktree TEMPL ~ '/html';
diag "templates";

my $fn = 'templates-test-pod-file_0';

(TEMPL ~ "/html/para.mustache").IO.spurt: '<p class="special {{# addClass }} {{ addClass }}{{/ addClass }}">{{{ contents }}}</p>';

my PodCache::Render $renderer .= new(:path(REP), :templates( TEMPL ), :output( OUTPUT ));
my PodCache::Processed $pf = $renderer.processed-instance(:name<a-second-pod-file> );

#--MARKER-- Test 1
like $pf.pod-body, /
    '<p class="special' \s* '">Some more text'
    /, 'Para template over-ridden';

#--MARKER-- Test 2
like $renderer.templates-changed, / 'para' .+ 'from' .* {TEMPL}  '/html' /, 'reports over-ridden template';

#--MARKER-- Test 3
lives-ok {$renderer.gen-templates}, 'gen-templates lives';

#--MARKER-- Test 4
is +(TEMPL ~ '/html').IO.dir, +$renderer.engine.tmpl, 'correct number of template files generated';

rmtree TEMPL;