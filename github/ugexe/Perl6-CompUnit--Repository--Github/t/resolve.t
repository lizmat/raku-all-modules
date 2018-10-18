use v6;
use Test;
plan 2;

use CompUnit::Repository::Github;
use lib "CompUnit::Repository::Github#user<ugexe>#repo<zef>#branch<master>#/";


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