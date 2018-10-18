use v6;
use Test;
plan 2;

use CompUnit::Repository::Github;
use lib "CompUnit::Repository::Github#user<ugexe>#repo<zef>#branch<master>#/";


subtest 'require module with no external dependencies' => {
    {
        dies-ok { ::("Zef") };
    }
    {
        use-ok("Zef"), 'module use-d ok';
    }
}

subtest 'require modules with external dependency chain' => {
    {
        dies-ok { ::("Zef::Build") };
    }
    {
        use-ok("Zef::Build"), 'module use-d ok';
    }
}

done-testing;
