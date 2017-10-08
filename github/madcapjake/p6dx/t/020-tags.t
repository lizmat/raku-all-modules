use Test;
use lib 'lib';

plan 4;
my $me = $?FILE.IO.dirname ~ $*SPEC.dir-sep;

my $p6dx = "{$me}../bin/p6dx";
my $pl6 = "{$me}/fixtures/word-wrap.pl6";

my $non-var-json = run $p6dx, '--tags', "--file=$pl6", '--json', :out;
is $non-var-json.out.slurp-rest,
   slurp("{$me}fixtures/non-vars.json"),
   "Produces tags as JSON";

my $all-json = run $p6dx, '--tags', "--file=$pl6", '--json', '--all', :out;
is $all-json.out.slurp-rest,
   slurp("{$me}fixtures/all.json"),
   "Produces all tags as JSON";

my $non-var-ctag = run $p6dx, '--tags', "--file=$pl6", '--ctag', :out;
is $non-var-ctag.out.slurp-rest,
   slurp("{$me}fixtures/non-vars.tags"),
   "Produces tags as ctag";

my $all-ctag = run $p6dx, '--tags', "--file=$pl6", '--ctag', '--all', :out;
is $all-ctag.out.slurp-rest,
   slurp("{$me}fixtures/all.tags"),
   "Produces all tags as ctag";
