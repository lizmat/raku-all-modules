use v6;
use Test;

plan 1;

use Git::Config;

my $gitconfig-path = '.'.IO;

is quietly { git-config($gitconfig-path).Str } , '', 'load without a gitconfig';
