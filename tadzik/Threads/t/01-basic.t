use Test;
plan 1;

use Threads;

my @stuff;

sub do-stuff {
    for 1..10 { @stuff.push: $_ }
    return;
}

my @tasks;

@tasks.push: async(&do-stuff) for 1..5;

@tasks».join;

is +@stuff, 50, 'all threads finished successfully';
