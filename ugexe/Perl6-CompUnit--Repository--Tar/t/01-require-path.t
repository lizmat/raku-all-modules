use Test;
plan 2;

use CompUnit::Repository::Tar;

use lib "CompUnit::Repository::Tar#{$?FILE.IO.parent.child('data/zef.tar.gz')}";


subtest {
    nok '$!dist' ~~ any( ::("Candidate").^attributes>>.name ), 'module not yet loaded';
    lives-ok { require "lib/Zef.pm6" },                        'module require-d ok';
    ok '$!dist' ~~ any( ::("Candidate").^attributes>>.name ),  'module is accessable';
}, 'require module with no dependencies';

subtest {
    nok '$!config' ~~ any( ::("Zef::Client").^attributes>>.name ),  'module not yet loaded';
    lives-ok { require "lib/Zef/Client.pm6" },                    'module require-d ok';
    ok '$!config' ~~ any( ::("Zef::Client").^attributes>>.name ), 'module loaded';
}, 'require modules with multi-level dependency chain';
