use v6;

use Test;
use lib 'lib';

my @methods = <my-home my-desktop my-documents my-music my-pictures my-videos
  my-data my-dist-config my-dist-data users-home users-documents users-data>;

plan @methods.elems + 3;

use File::HomeDir;
ok 1, "'use File::HomeDir' worked!";

for @methods -> $method {
  ok File::HomeDir.can(~$method), "File::HomeDir.$method exists";
}

my $my-home = File::HomeDir.my-home;
ok $my-home.defined, "my-home result is defined";
ok $my-home.IO ~~ :d, "my-home result is a directory";
