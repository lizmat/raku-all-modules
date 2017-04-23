use v6;
use Test;

plan 3;

use Git::Config;

my $gitconfig-path = $*PROGRAM.parent.child('data').child('gitconfig');

is git-config($gitconfig-path)<user><email>, 'hans@hansen.net', 'Hash Subscript to email field';
is git-config($gitconfig-path){'remote "origin"'}<url>, 'https://github.com/perl6/ecosystem.git', 'fancy section name';
is git-config($gitconfig-path).path, $gitconfig-path, 'Side-channel to get file path.'
