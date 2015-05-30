use v6;

use File::Find;

sub MAIN {
    my @zone-files := find(dir => '../lib/DateTime/TimeZone/Zone', name => /.*pm6$/);
    my @zone-path-strings = @zone-files>>.abspath;
    @zone-path-strings>>.subst-mutate(/ .* '../lib/' /, '');
    my @module-names = @zone-path-strings>>.subst(/ \/ /, '::', :g);
    @module-names>>.subst-mutate(/ \.pm6$ /, '');
    my $num-subtests = @module-names.elems;

    my $header = q:to/EOH/;
    use v6;

    use lib './lib';

    use Test;
    use DateTime::TimeZone;
    use DateTime::TimeZone::Zone;
    EOH

    my $output-dir = "../t/all-zones";
    mkdir $output-dir if ! $output-dir.IO.d;

    for @module-names -> $module-name {
        write-zone-test($header, $module-name, $output-dir);
    }

}

sub write-zone-test($header, $module-name, $output-dir) {
    my $test = q:to/EOT/;
    plan 5;

    EOT
    $test ~= "use $module-name;\n";
    $test ~= "my \$tz = $module-name.new;\n";
    $test ~= q:to/EOT/;
    ok $tz, "timezone can be instantiated";
    isnt $tz.rules, Empty, "timezone has rules";
    is $tz.rules.WHAT, Hash, "rules is a Hash";
    ok $tz.zonedata, "timezone has zonedata";
    is $tz.zonedata.WHAT, Array, "zonedata is an Array";
    EOT

    my $test-fname = $module-name.subst('::', '-', :g) ~ '.t';
    $test-fname.subst-mutate('DateTime-TimeZone-Zone-', '');
    "$output-dir/$test-fname".IO.spurt(($header, $test).join("\n"));
}

# vim: expandtab shiftwidth=4 ft=perl6
