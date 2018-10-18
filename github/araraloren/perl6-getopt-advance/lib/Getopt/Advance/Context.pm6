
use Getopt::Advance::Utils;

unit module Getopt::Advance::Context;

role Context is export {
    has $.success;

    method TWEAK() {
        $!success = False;
    }

    method mark-matched() {
        $!success = True;
    }

    method match(ContextProcessor, $o) { ... }

    method set(ContextProcessor, $o) { ... }

    method gist() { ... }
}

class TheContext is export {
    class Option does Context {
        has $.prefix;
        has $.name;
        has $.hasarg;
        has &.getarg;
        has $.canskip;

        method match(ContextProcessor $cp, $o) {
            my $name-r = do given $!prefix {
                    when Prefix::LONG {
                        $o.long eq $!name;
                    }
                    when Prefix::SHORT {
                        $o.short eq $!name;
                    }
                    when Prefix::NULL {
                        $o.long eq $!name || $o.short eq $!name
                    }
                    default {
                        False;
                    }
                };

            Debug::debug("  - Name => { $name-r ?? 'OK' !! 'Failed' }");

            my $value-r = False;

            if $o.need-argument == $!hasarg {
                Debug::debug("    - Value [{&!getarg()}] for [{$o.usage}]");
                $value-r = &!getarg.defined ?? $o.match-value(&!getarg()) !! True;
            }
            Debug::debug("    - Match " ~ ($name-r && $value-r ?? "Okay!" !! "Failed!"));
            return $name-r && $value-r;
        }

        method set(ContextProcessor $cp, $o) {
            self.mark-matched();
            $o.set-value(&!getarg(), :callback);
            Debug::debug("    - OK! Set value {&!getarg()} for [{$o.usage}], shift args: {self.canskip}");
        }

        method gist() { "\{{$!prefix}, {$!name}{$!hasarg ?? ":" !! ""}\}" }
    }

    class DelayOption is Option {
        method set(ContextProcessor $cp, $o) {
            self.mark-matched();
            Debug::debug("    - OK! Delay set value {self.getarg()()} for [{$o.usage}], shift args: {$o.need-argument}");
            OptionValueSetter.new(
                optref => $o,
                value  => self.getarg()(),
            );
        }
    }

    class NonOption does Context {
        has @.argument;
        has $.index;

        method match(ContextProcessor $cp, $no) {
            my $style-r = $no.match-style($cp.style);

            Debug::debug("  - Style => { $style-r ?? 'OK' !! 'Failed' }");

            my $name-r  = $style-r && do given $cp.style {
                when Style::MAIN {
                    $no.match-name("");
                }
                default {
                    $no.match-name(@!argument[$!index].Str);
                }
            };

            Debug::debug("  - Name => { $name-r ?? 'OK' !! 'Failed' }");

            my $index-r = $name-r && $no.match-index(+@!argument, $!index);

            Debug::debug("  - Index => { $index-r ?? 'OK' !! 'Failed' }");

            my $call-r  = $index-r && do {
                given $cp.style {
                    when Style::POS | Style::WHATEVERPOS {
                        Debug::debug("    - Try call {$cp.style} sub.");
                        $no.($no.owner, @!argument[$!index]);
                    }
                    when Style::CMD {
                        my @realargs = @!argument[1..*-1];
                        Debug::debug("    - Try call {$cp.style} sub.");
                        $no.($no.owner, @realargs);
                    }
                    default {
                        Debug::debug("    - Try call {$cp.style} sub.");
                        $no.($no.owner, @!argument);
                    }
                }
            };
            Debug::debug("    - Match " ~ ($call-r ?? "Okay!" !! "Failed!"));
            return $call-r;
        }

        method set(ContextProcessor $cp, $no) { }

        method gist() {
            my $gist = "\{";
            $gist ~= [ "{.Str}\@{.index}" for self.argument ].join(",");
            $gist ~ '}';
        };
    }

    class Pos is NonOption {
        method gist() {
            given self.argument[self.index] {
                "\{{.Str}\@{.index}\}";
            }
        }
    }
}
