
use v6;

unit class Parse::Selenese::TestSuite;

use Parse::Selenese::TestCaseDef;

has Str $.name is rw;
has Parse::Selenese::TestCaseDef @.test_case_defs is rw;
