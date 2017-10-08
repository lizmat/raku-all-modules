use Test;
plan 2;

use CompUnit::Repository::Tar;

use lib "CompUnit::Repository::Tar#{$?FILE.IO.parent.child('data/zef.tar.gz')}";


subtest {
    nok '$!dist' ~~ any( ::("Candidate").^attributes>>.name ), 'module not yet loaded';
    use-ok("Zef");
    ok '$!dist' ~~ any( ::("Candidate").^attributes>>.name ),  'module is accessable';
}, 'use module with no dependencies';

subtest {
    nok '$!config' ~~ any( ::("Zef::Client").^attributes>>.name ),  'module not yet loaded';
    use-ok("Zef::Client");
    ok '$!config' ~~ any( ::("Zef::Client").^attributes>>.name ), 'module loaded';
}, 'use modules with multi-level dependency chain';
