
use Getopt::Advance::Exception;

class Group::OptionName {
    has $.long is rw;
    has $.short is rw;
}

role Group {
    has $.optsetref;
    has @.names;
    has $.optional = True;

    # @options are names of options in group
    submethod TWEAK(:@options) {
        @!names = [];
        for @options {
            @!names.push(
                Group::OptionName.new(long => .long, short => .short)
            );
        }
    }

    method usage() {
        my $usage = "";

        $usage ~= $!optional ?? "+\[ " !! "+\< ";
        $usage ~= $!optsetref.get(.long eq "" ?? .short !! .long).usage() for @!names;
        $usage ~= $!optional ?? " \]+" !! " \>+";
        $usage;
    }

    method has(Str:D $name --> Bool) {
        for @!names {
            return True if $name eq .long | .short;
        }
        False;
    }

    method remove(Str:D $name where $name !~~ /^\s+$/) {
        for ^+@!names -> $index {
            my $optn := @!names[$index];
            if $name eq $optn.long {
                $optn.long = "";
            }
            if $name eq $optn.short {
                $optn.short = "";
            }
            if $optn.long eq "" and $optn.short eq "" {
                @!names.splice($index, 1);
                return True;
            }
        }
    }

    method check() { ... }

    method clone(*%_) {
        nextwith(
            optsetref => %_<optsetref> // $!optsetref,
            names => %_<names> // @!names.clone,
            optional => %_<optional> // $!optional,
            |%_
        );
    }
}

class Group::Radio does Group {
    method check() {
        my $count = 0;

        for @!names {
            my $name = .long eq "" ?? .short !! .long;
            $count += 1 if $!optsetref.get($name).has-value;
        }
        given $count {
            when 0 {
                unless $!optional {
                    ga-group-error("{self.usage}: Radio option group value is force required!");
                }
            }
            when * > 1 {
                ga-group-error("{self.usage}: Radio group value only allow set one!");
            }
        }
    }
}

class Group::Multi does Group {
    method check() {
        unless $!optional {
            my $count = 0;

            for @!names {
                my $name = .long eq "" ?? .short !! .long;
                $count += 1 if $!optsetref.get($name).has-value;
            }
            if $count < +@!names {
                ga-group-error("{self.usage}: Multi option group value is force required!");
            }
        }
    }
}
