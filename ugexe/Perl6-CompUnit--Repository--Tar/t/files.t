use Test;
plan 5;

use CompUnit::Repository::Tar;

use lib "CompUnit::Repository::Tar#{$?FILE.IO.parent.child('data/zef.tar.gz')}";


subtest {
    ok  $*REPO.repo-chain[0].files("bin/zef");
    nok $*REPO.repo-chain[0].files("bin/xxx");
}, 'name-path only';

subtest {
    ok  $*REPO.repo-chain[0].files("bin/zef", name => "zef");
    nok $*REPO.repo-chain[0].files("bin/zef", name => "xxx");
}, 'name-path and distribution name';

subtest {
    ok  $*REPO.repo-chain[0].files("bin/zef", auth => "github:ugexe");
    nok $*REPO.repo-chain[0].files("bin/zef", auth => "github:xxx");
}, 'name-path and distribution auth';

subtest {
    ok  $*REPO.repo-chain[0].files("bin/zef", ver => "*");
    # TODO: replace zef.tar.gz with a lighter weight test distro that also
    # doesn't happen to have a version of "*" (which would match the xxx below)
    # nok $*REPO.repo-chain[0].files("bin/zef", ver => "xxx");
}, 'name-path and distribution ver';

subtest {
    ok  $*REPO.repo-chain[0].files("bin/zef", name => "zef", auth => "github:ugexe", ver => "*");
    nok $*REPO.repo-chain[0].files("bin/xxx", name => "zef", auth => "github:ugexe", ver => "*");
}, 'name-path and distribution name/auth/ver';
