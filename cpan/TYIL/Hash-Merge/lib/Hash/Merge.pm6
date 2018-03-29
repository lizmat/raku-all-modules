#! /usr/bin/env false

use v6.c;

unit module Hash::Merge;

#| Merge any number of Hashes together.
sub merge-hashes(
    *@hashes, #= Hashes to merge together
    --> Hash
) is export {
    my %merge-into = @hashes.shift;

    # Nothing to do if we only got 1 argument
    return %merge-into unless @hashes.elems;

    for ^@hashes.elems {
        %merge-into = merge-hash(%merge-into, @hashes.shift);
    }

    %merge-into;
}

#| Merge two hashes together.
sub merge-hash(
    %merge-into,   #= The original Hash that should be merged into.
    %merge-source, #= Another Hash to merge into the original Hash.
    Bool:D :$no-append-array = False,
    --> Hash
) is export {
    for %merge-source.keys -> $key {
        if %merge-into{$key}:exists {
            given %merge-source{$key} {
                when Hash {
                    merge-hash(%merge-into{$key}, %merge-source{$key}, :$no-append-array);
                }
                when Positional {
                    %merge-into{$key} = $no-append-array
                    ?? %merge-source{$key}
                    !!
                    do {
                        my @a;
                        @a.push: $_ for %merge-into{$key}.list;
                        @a.push: $_ for %merge-source{$key}.list;
                        @a;
                    }
                }
                default {
                    %merge-into{$key} = %merge-source{$key}
                }
            }
        } else {
            %merge-into{$key} = %merge-source{$key};
        }
    }

    %merge-into;
}

# vim: ft=perl6 ts=4 sw=4 et
