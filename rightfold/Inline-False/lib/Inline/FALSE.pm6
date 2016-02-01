use v6.c;

=begin pod

=head1 NAME

Inline::FALSE - embed FALSE code in Perl 6 code

=head1 SYNOPSIS

    use Inline::FALSE;

    sub square($z) {
        false('z;z;*z:', :$z);
    }

    say square(5); # 25

=head1 DESCRIPTION

=end pod

module Inline::FALSE {
    #| FALSE grammar.
    our grammar Grammar {
        rule TOP { <ws> $<stmts>=<stmt>* }

        token ws {
            [\s || '{' .*? '}']*
        }

        proto rule stmt {*}

        rule stmt:sym<op> {
            $<op>=<[+\-*/_=>&|~:;!$%\\@ø?#.,^ß]>
        }

        rule stmt:sym<integer> {
            $<value>=[<[0..9]>+]
        }

        rule stmt:sym<character> {
            '\''$<value>=.
        }

        rule stmt:sym<variable> {
            $<name>=<[a..z]>
        }

        rule stmt:sym<lambda> {
            '[' $<stmts>=<stmt>* ']'
        }

        rule stmt:sym<string> {
            '"'$<value>=[.*?]'"'
        }
    }

    #| FALSE grammar actions.
    our class Actions {
        method TOP($/) {
            my @stmts = $<stmts>>>.made;
            make -> @stack, %globals {
                $_(@stack, %globals) for @stmts;
            };
        }

        method stmt:sym<op>($/) {
            sub unop(&op) {
                -> @stack, %globals {
                    my $x = @stack.pop;
                    @stack.push(&op($x));
                };
            }

            sub binop(&op) {
                -> @stack, %globals {
                    my $b = @stack.pop;
                    my $a = @stack.pop;
                    @stack.push(&op($a, $b));
                };
            }

            my %ops =
                '+' => binop(* + *),
                '-' => binop(* - *),
                '*' => binop(* * *),
                '/' => binop(* div *),
                '_' => unop(-*),
                '=' => binop(+(* == *)),
                '>' => binop(+(* > *)),
                '&' => binop({ +($^a && $^b) }),
                '|' => binop({ +($^a || $^b) }),
                '~' => unop(+!*),
                ':' => -> @stack, %globals {
                    my $name = @stack.pop;
                    my $value = @stack.pop;
                    %globals{$name} = $value;
                },
                ';' => -> @stack, %globals {
                    my $name = @stack.pop;
                    @stack.push(%globals{$name});
                },
                '!' => -> @stack, %globals {
                    my &callee = @stack.pop;
                    &callee(@stack, %globals);
                },
                '$' => -> @stack, %globals {
                    my $x = @stack.pop;
                    @stack.push($x);
                    @stack.push($x);
                },
                '%' => -> @stack, %globals {
                    @stack.pop;
                },
                '\\' => -> @stack, %globals {
                    my $a = @stack.pop;
                    my $b = @stack.pop;
                    @stack.push($a);
                    @stack.push($b);
                },
                '@' => -> @stack, %globals {
                    my $c = @stack.pop;
                    my $b = @stack.pop;
                    my $a = @stack.pop;
                    @stack.push($b);
                    @stack.push($c);
                    @stack.push($a);
                },
                'ø' => -> @stack, %globals {
                    my $n = @stack.pop;
                    @stack.push(@stack[@stack.end - $n]);
                },
                '?' => -> @stack, %globals {
                    my &f = @stack.pop;
                    my $c = @stack.pop;
                    &f(@stack, %globals) if $c;
                },
                '#' => -> @stack, %globals {
                    my &f = @stack.pop;
                    my &c = @stack.pop;
                    loop {
                        &c(@stack, %globals);
                        last unless @stack.pop;
                        &f(@stack, %globals);
                    }
                },
                '.' => -> @stack, %globals {
                    @stack.pop.Int.print;
                },
                ',' => -> @stack, %globals {
                    @stack.pop.chr.print;
                },
                '^' => -> @stack, %globals {
                    @stack.push($*IN.getc // -1);
                },
                'ß' => -> @stack, %globals {
                    $*OUT.flush;
                },
            ;

            make %ops{$<op>};
        }

        method stmt:sym<integer>($/) {
            my $value = +$<value>;
            make -> @stack, %globals {
                @stack.push($value);
            };
        }

        method stmt:sym<character>($/) {
            my $value = $<value>.chr;
            make -> @stack, %globals {
                @stack.push($value);
            };
        }

        method stmt:sym<variable>($/) {
            my $name = ~$<name>;
            make -> @stack, %globals {
                @stack.push($name);
            };
        }

        method stmt:sym<lambda>($/) {
            my @stmts = $<stmts>>>.made;
            make -> @stack, %globals {
                @stack.push(-> @stack, %globals {
                    $_(@stack, %globals) for @stmts;
                });
            };
        }

        method stmt:sym<string>($/) {
            my $value = ~$<value>;
            make -> @stack, %globals {
                print $value;
            };
        }
    }

    our sub compile(Str:D $text) {
        my &main = Grammar.parse($text, actions => Actions).made;
        -> *%globals is copy {
            &main([], %globals);
            %globals<z>;
        };
    }

    #| Executes a FALSE program, setting global variables. When the FALSE
    #| program halts, the value of the C<z> variable is returned.
    sub false(Str:D $code, *%globals) is export {
        compile($code)(|%globals);
    }
}

=begin pod

=head1 SEE ALSO

FALSE language specification (available on
L<http://strlen.com/false/false.txt>).

=head1 BUGS AND LIMITATIONS

Inline assembly is not supported. FALSE programs that rely on integer overflow
may not work as intended. FALSE programs that perform pointer arithmetic may
not work as intended.

=end pod
