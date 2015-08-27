use v6;

use Test;
use lib 'lib';

my @methods = <my_home my_desktop my_documents my_music my_pictures my_videos
  my_data my_dist_config my_dist_data users_home users_documents users_data>;

plan @methods.elems + 1;

use File::HomeDir;
ok 1, "'use File::HomeDir' worked!";

for @methods -> $method {
  ok File::HomeDir.can(~$method), "File::HomeDir.$method exists";
}
