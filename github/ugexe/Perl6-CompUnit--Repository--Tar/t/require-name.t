use v6;
use Test;
plan 1;

use CompUnit::Repository::Tar;
use lib "CompUnit::Repository::Tar#{CompUnit::Repository::Tar.test-dist('zef.tar.gz')}";


subtest 'require module with no external dependencies' => {
    {
        dies-ok { ::("Zef") };
        lives-ok { require ::("Zef") <&from-json> }, 'module require-d ok';
    }
    {
        require ::("Zef::Utils::FileSystem") <&list-paths>;
        ok &list-paths($*CWD).elems;
    }
}

done-testing;
