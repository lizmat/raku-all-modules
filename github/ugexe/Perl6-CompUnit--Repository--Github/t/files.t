use v6;
use Test;
plan 5;

use CompUnit::Repository::Github;
use lib "CompUnit::Repository::Github#user<ugexe>#repo<zef>#branch<master>#/";


subtest 'name-path only' => {
    ok  $*REPO.repo-chain[0].files("bin/zef");
    nok $*REPO.repo-chain[0].files("bin/xxx");
}

subtest 'name-path and distribution name' => {
    ok  $*REPO.repo-chain[0].files("bin/zef", name => "Zef");
    nok $*REPO.repo-chain[0].files("bin/zef", name => "xxx");
}

subtest 'name-path and distribution auth' => {
    ok  $*REPO.repo-chain[0].files("bin/zef", auth => "github:ugexe");
    nok $*REPO.repo-chain[0].files("bin/zef", auth => "github:xxx");
}

subtest 'name-path and distribution ver' => {
    ok  $*REPO.repo-chain[0].files("bin/zef", ver => "*");
}

subtest 'name-path and distribution name/auth/ver' => {
    ok  $*REPO.repo-chain[0].files("bin/zef", name => "Zef", auth => "github:ugexe", ver => "*");
    nok $*REPO.repo-chain[0].files("bin/xxx", name => "Zef", auth => "github:ugexe", ver => "*");
}

done-testing;
