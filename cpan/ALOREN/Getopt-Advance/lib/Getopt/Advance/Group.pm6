
use Getopt::Advance::Utils;
use Getopt::Advance::Types;
use Getopt::Advance::Exception;

unit module Getopt::Advance::Group;

class OptionInfo {
    has $.optref;
    has $.long;
    has $.short;

    method name() {
        self.long eq "" ?? self.short() !! self.long();
    }
}

role Group does RefOptionSet {
    has @.infos;
    has $.optional = True;

    # @options are names of options in group
    submethod TWEAK(:@options) {
        @!infos = [];
        for @options {
            @!infos.push(
                OptionInfo.new(optref => $_, long => .long, short => .short)
            );
        }
    }

    method usage( --> Str) {
        my $usage = "";

        $usage ~= $!optional ?? "+\[ " !! "+\< ";
        $usage ~= self.owner.get(.name()).usage() for @!infos;
        $usage ~= $!optional ?? " \]+" !! " \>+";
        $usage;
    }

    method has(Str:D $name --> False) {
        for @!infos {
            if $name eq .long || $name eq .short {
                return True;
            }
        }
    }

    method remove(Str:D $name--> False) {
        for ^+@!infos -> $index {
            given @!infos[$index] {
                if $name eq .long || $name eq .short {
                    @!infos.splice($index, 1);
                    return True;
                }
            }
        }
    }

    method check() { ... }

    method clone(*%_) {
        nextwith(
            infos => %_<infos> // @!infos.clone,
            optional => %_<optional> // $!optional,
            |%_
        );
    }
}

class Group::Radio does Group {
    method check() {
        my $count = 0;

        for @!infos {
            my $name = .long eq "" ?? .short !! .long;
            $count += 1 if self.owner.get($name).has-value;
        }
        given $count {
            when 0 {
                unless $!optional {
                    &ga-group-error("{self.usage}: Radio option group value is force required!");
                }
            }
            when * > 1 {
                &ga-group-error("{self.usage}: Radio group value only allow set one!");
            }
        }
    }
}

class Group::Multi does Group {
    method check() {
        unless $!optional {
            my $count = 0;

            for @!infos {
                my $name = .long eq "" ?? .short !! .long;
                $count += 1 if self.owner.get($name).has-value;
            }
            if $count < +@!infos {
                &ga-group-error("{self.usage}: Multi option group value is force required!");
            }
        }
    }
}
