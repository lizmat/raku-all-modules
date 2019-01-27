use strict;

my $case = story_var("case");
my $sparrowdo_options = story_var("sparrowdo_options");
my $project_root_dir = project_root_dir();

print  "run case $case ...\n";
my $cmd = "sparrowdo --sparrowfile=$project_root_dir/$case/sparrowfile $sparrowdo_options";
print "run $cmd ... \n";

exec $cmd;

