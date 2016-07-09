unit module Getopt::Type;

class Getopt::Type::Constraint {
    has %.accepted;
    has $.results;

    method new(@args) {
        my (%accepted, $results);
        for @args {
            if .index('|') {
                my ($short, $long) = .split('|');
                %accepted{$short} = %accepted{$long} = True;
                $results{$short} := $results{$long} = Any;
            } else {
                %accepted{$_} = True
            }
        }
        self.bless(:%accepted, :$results);
    }

    method ACCEPTS($opts is rw) {
        for $opts.kv -> $k, $v {
            if %!accepted{$k} {
                $!results{$k} = $v;
            } else {
                my @letters = $k.comb;
                for @letters -> $l {
                    unless %!accepted{$l} {
                        return False;
                    }
                }
                # apparently they're all good, set them all
                for @letters -> $l {
                    $!results{$l} = $v;
                }
            }
            $opts{$k}:delete;
        }
        for $!results.kv -> $k, $v {
            $opts{$k} = $v
        }
        return True
    }
}

sub getopt(@args) is export {
    return Getopt::Type::Constraint.new: @args;
}
