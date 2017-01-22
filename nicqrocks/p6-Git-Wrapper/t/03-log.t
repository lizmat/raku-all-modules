
use Test;

#This will check some of the functions to make sure that they work properly.

#Add the local lib folder.
use lib "{$*PROGRAM.dirname}/../lib";
use Git::Wrapper;

#Make a connection to the local git repo.
my $git = Git::Wrapper.new: gitdir => "{$*PROGRAM.dirname}/..";


plan 3;

unless $git.is-repo {
    skip-rest "Not in a git repo";
    exit;
}

#Check the log method.
isa-ok $git.log, "List", "Can parse the git log.";
ok $git.log.all ~~ Git::Wrapper::Log, "Objects in log list are the right type.";


#Check the gist method of the Git::Wrapper::Log object.
subtest {
    my $gist = $git.log[0].gist;
    isa-ok $gist, "Str", "The gist gives a string.";
    ok $gist ~~ / [\w+ ':' \s+ \w+ % \s+]+ % \n /, "Gist looks ok";
}


done-testing;
