use Test;
use LibGit2;

plan 2;

ok my $version = LibGit2.version, 'version';

diag "libgit2 version: $version";

ok (my @features = LibGit2.features()), 'features';

diag "libgit2 features: @features[]";

done-testing;

