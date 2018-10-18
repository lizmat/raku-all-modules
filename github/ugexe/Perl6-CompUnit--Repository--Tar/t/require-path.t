use v6;
use Test;
plan 1;

use CompUnit::Repository::Tar;
use lib "CompUnit::Repository::Tar#{CompUnit::Repository::Tar.test-dist('zef.tar.gz')}";


subtest 'require module with no external dependencies' => {
    {
        dies-ok { ::("Zef") };
        lives-ok { require 'lib/Zef.pm6' <&from-json>; }, 'module require-d ok';
    }
    {
        require 'lib/Zef/Utils/FileSystem.pm6' <&list-paths>;
        ok &list-paths($*CWD).elems;
    }
}

done-testing;
