
use Test;

#This will check some of the functions to make sure that they work properly.

#Add the local lib folder.
use lib "{$*PROGRAM.dirname}/../lib";
use Git::Wrapper;

#Make a connection to the local git repo.
my $git = Git::Wrapper.new: gitdir => "{$*PROGRAM.dirname}/..";

plan 3;

#Test if Git::Wrapper can detect if this is a git repo.
isa-ok $git.is-repo, "Bool", "Checking for a git repo returns Bool.";

#Check the version.
subtest {
    isa-ok $git.version, "Str", "Can get the version.";
    ok $git.version ~~ / 'git version ' /, "Version output looks right.";
}

#Make sure we are in an actual git repo before proceeding.
unless $git.is-repo {
    skip-rest "Not in a git repo";
    exit;
}

#Check for arguments with two dashes.
ok $git.run("config", :local, "remote.origin.url") ne "", "Args with two dashes";

done-testing;
