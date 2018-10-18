use v6;
use Test;
plan 2;

use CompUnit::Repository::Tar;
use lib "CompUnit::Repository::Tar#{CompUnit::Repository::Tar.test-dist('zef.tar.gz')}";


my $matching-spec = CompUnit::DependencySpecification.new(
    short-name      => 'Zef',
    auth-matcher    => 'github:ugexe',
);
my $missing-spec = CompUnit::DependencySpecification.new(
    short-name      => 'Zef',
    auth-matcher    => 'cpan:ugexe',
    version-matcher => '666',
);

ok  $*REPO.repo-chain[0].resolve($matching-spec);
nok $*REPO.repo-chain[0].resolve($missing-spec);

done-testing;