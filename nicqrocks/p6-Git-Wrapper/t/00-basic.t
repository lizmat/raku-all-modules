
use Test;

#Add the local lib folder.
use lib "{$*PROGRAM.dirname}/../lib";

my @modules = qw[Git::Wrapper Git::Log::Parser];

plan @modules.elems;

#Attempt to load the modules.
for @modules -> $mod {
    use-ok "$mod", "Can load module: $mod";
}

done-testing;
