use v6;
use lib 'lib';
use lib 'examples/lib';
use Test;

my @modules = <
    Example::Docker::Attach
    Example::Docker::Build
    Example::Docker
    CommandLine::Usage::Header
    CommandLine::Usage::Positionals
    CommandLine::Usage::Subcommands
    CommandLine::Usage::Options
    CommandLine::Usage
    >;

plan @modules.elems;

use-ok $_, "load $_" for @modules;

