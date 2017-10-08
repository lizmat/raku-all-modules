#!perl6

use v6;

use Test;
use META6;
use JSON::Class;

my constant Projects = Array[META6] but JSON::Class;

my IO::Path $data-dir = $*PROGRAM.parent.child("data");
my IO::Path $meta-path = $data-dir.child('projects.json');

my $json = $meta-path.slurp;

my $projects;

{ 
    CONTROL {
        when CX::Warn {
            $_.resume;
        }
    };
    lives-ok { $projects = Projects.from-json($json) }, "create an object from projects.json";
    ok all($projects.list) ~~ META6, "and they're all META6 objects";
}




done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
