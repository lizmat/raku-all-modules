
use Getopt::Advance;
use Getopt::Advance::Exception;

sub guess-the-type($p) {
    my $ft = %(
        Int => 'i',
        IntStr => 'i',
        Str => 's',
        Array => 'a',
        Hash => 'h',
        Num => 'f',
        Rat => 'f',
        Bool => 'b',
        Any => 's',
        Positional => 'a',
        Associative => 'h',
    ){ $p.type.^name };
    given $p.sigil {
        when '$' | '\\' {
            return $ft;
        }
        when '@' {
            if $ft ne 's' {
                die 'Not support';
            }
            return 'a';
        }
        when '%' {
            if $ft ne 's' {
                die 'Not support';
            }
            return 'h';
        }
        default { die 'Not support'; }
    }
}

sub guess-the-name($p) {
    if $p.sigil eq '\\' {
        return $p.name;
    } else {
        if $p.name ~~ /^.<[*\.!]>?(.+)/ {
            return $/[0];
        } else {
            return $p.name;
        }
    }
}

multi sub mixin-option($os, Sub $s) is export {
    my Bool $slurpy = False;
    my Int $noa = 0;

    $os.insert-cmd($s.name);
    for @($s.signature.params) -> $p {
        if $p.slurpy {
            $slurpy = True;
            next;
        }

        my $name = &guess-the-name($p);

        if $p.named {
            say "OPTION $name";
            if so $p.default {
                $os.push(
                    "{$name}={guess-the-type($p)}",
                    value => $p.default.(),
                    callback => sub ($, $v) {
                        &ga-option-error("Invalid value of option {$name}: {$v}")
                            if not so $p.constraints($v);
                    }
                );
            } else {
                $os.push(
                    "{$name}={guess-the-type($p)}",
                    callback => sub ($, $v) {
                        &ga-option-error("Invalid value of option {$name}: {$v}")
                            if not so $p.constraints($v);
                    }
                );
            }
        } else {
            if so $p.default {
                $os.get-pos(
                    $os.insert-pos(
                        $name,
                        ++$noa,
                        sub ($, $arg) {
                            &ga-non-option-error("Invalid value of pos {$name}: {$arg.value}")
                                if not so $p.constraints.($arg.value);
                            $arg.value;
                        }
                    )
                ).set-value($p.default-value);
            } else {
                $os.insert-pos(
                    $name,
                    ++$noa,
                    sub ($, $arg) {
                        &ga-non-option-error("Invalid value of pos {$name}: {$arg.value}")
                            if not so $p.constraints.($arg.value);
                        $arg.value;
                    }
                )
            }
        }
    }
    $os.insert-main(sub ($os, @args) {
        my @posarg;
        my %namedarg;

        for $os.get-pos().sort(*.key) {
            @posarg.push(.value.value);
        }
        for $os.options {
            if .has-value {
                %namedarg{ .has-long ?? .long !! .short} = .value ;
            }
        }
        $s.(|@posarg, |%namedarg);
    });
    $os;
}

multi sub mixin-option($os, Method $m) is export {

}

sub read(\a where * eq '123') {
    say 123;
}

my OptionSet $os .= new;

mixin-option($os, &read);

&getopt($os);

say $os;
