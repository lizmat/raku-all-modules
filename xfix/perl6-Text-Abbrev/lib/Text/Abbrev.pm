unit module Abbrev;
multi sub abbrev (*@words) is export {
    my $seen = SetHash.new;
    my %result;
    for @words {
        for 1 .. .chars -> $len {
            my $abbrev = .substr(0, $len);
            if $seen{$abbrev} {
                %result{$abbrev}:delete;
            }
            else {
                $seen{$abbrev} = True;
                %result{$abbrev} = $_;
            }
        }
    }
    for @words {
        %result{$_} = $_;
    }
    return %result;
}
