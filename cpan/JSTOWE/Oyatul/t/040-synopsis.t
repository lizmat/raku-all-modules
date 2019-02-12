#!/usr/bin/env perl6
#
use v6;

use Oyatul;
use Test;

lives-ok {
my $description = q:to/LAY/;
{
   "type" : "layout",
   "children" : [
      {
         "name" : "t",
         "purpose" : "tests",
         "type" : "directory",
         "children" : [
            {
               "type" : "file",
               "purpose" : "test",
               "template" : true
            }
         ]
      },
      {
         "type" : "directory",
         "purpose" : "lib",
         "name" : "lib",
         "children" : []
      }
   ]
}
LAY

# the :real adverb causes instance nodes to be inserted
# for any templates if they exist.
my $layout = Oyatul::Layout.from-json($description, root => $*CWD.Str, :real);

# get the directory that stands in for 'lib'
my $lib = $layout.nodes-for-purpose('lib').first.path;

my $me = $*PROGRAM.basename;

# get all the instances for 'test' excluding the template
for $layout.nodes-for-purpose('test', :real).grep({$_.name ne $me }) -> $test {
   my $proc = Proc::Async.new($*EXECUTABLE, '-I', $lib, $test.path);
   $proc.stdout.tap( { Empty });
   $proc.stderr.tap( { Empty });
    ok do { await $proc.start }, "run { $test.path }";

}
}, "the synopsis runs ok";

done-testing;
