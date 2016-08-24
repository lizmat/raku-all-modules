use Test;
plan 2;

use CompUnit::Repository::Tar;

use lib "CompUnit::Repository::Tar#{$?FILE.IO.parent.child('data/zef.tar.gz')}";


my $matching-spec = CompUnit::DependencySpecification.new(
    short-name      => 'Zef::Client',
    auth-matcher    => 'github:ugexe',
    version-matcher => '*',
);
my $missing-spec = CompUnit::DependencySpecification.new(
    short-name      => 'Zef::Client',
    auth-matcher    => 'cpan:ugexe',
    version-matcher => '*',
);


ok  $*REPO.repo-chain[0].resolve($matching-spec);
nok $*REPO.repo-chain[0].resolve($missing-spec);
