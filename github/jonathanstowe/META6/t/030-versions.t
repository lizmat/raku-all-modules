#!perl6

use v6;
use Test;

use META6;

my $warnings = 0;

my IO::Path $data-dir = $*PROGRAM.parent.child("data");

my IO::Path $meta-path = $data-dir.child('META-V.info');

my $obj;

{ 
    CONTROL {
        when CX::Warn {
            say $_.message;
            if $_.message ~~ /'prefix "v" seen in version string'/ {
                $warnings++;
                $_.resume;
            }
        }
    };
    $obj = META6.new(file => $meta-path);
}

is $obj.version, "0.0.1", "object get good version";
is $obj.perl-version, "6", "got right perl version";

is $warnings, 1, "got exactly 1 warning about v";




done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
