#!/usr/bin/env perl6
my $a0 = <a b c>;
my $a1 = <1 2 3>;
say "Using scalar version (\$a):";
for 0..1 -> $i {
    my $a = $::("a{$i}");
    say "array \$a{$i}:";
    say "  $_" for $a;
    say "element 0 is {$a[0]}";
    say "element 1 is {$a[1]}";
    say "element 2 is {$a[2]}";
}

my @a0 = <a b c>;
my @a1 = <1 2 3>;
say "Using array version (\@a):";
for 0..1 -> $i {
    my @a = @::("a{$i}");
    say "array \@a{$i}:";
    say "  $_" for @a;
    say "element 0 is {@a[0]}";
    say "element 1 is {@a[1]}";
    say "element 2 is {@a[2]}";
}
