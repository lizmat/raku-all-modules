
use v6;

unit class Parse::Selenese::TestCase;

use Parse::Selenese::Command;

has Str $.name is rw;
has Str $.base_url is rw;
has Parse::Selenese::Command @.commands is rw;
