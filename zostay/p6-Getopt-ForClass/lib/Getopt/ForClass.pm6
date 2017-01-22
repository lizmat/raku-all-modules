unit module Getopt::ForClass;
use v6;

our sub order-options($sig, @args is copy) {
    my (@pos, %names);

    my %named-params = $sig.params.grep(*.named).flatmap(-> $p {
        $p.named_names.map({ $_ => $p });
    });

    # Pull out the named args
    my @keepers = ^@args.elems;
    for @args.kv -> $i, $arg {
        if $arg ~~ / '--' $<name> = [ <-[-]> .* ] '=' $<value> = [ .* ] / {
            if %named-params{ $<name> } -> $p {
                if $p.type ~~ Bool {
                    %names{ $<name> } = do given $<value> {
                        when m:i/ 1 | y | yes | true / { True }
                        when m:i/ 0 | n | no | false / { False }
                        default                        { ?$<value> }
                    };
                }
                elsif $p.type ~~ Numeric {
                    %names{ $<name> } = +$<value>;
                }
                else {
                    %names{ $<name> } = $<value>;
                }
            }
            else {
                die "No parameter named --$<name> is defined for this command.";
            }

            @keepers .= grep: none($i);
        }

        elsif $arg ~~ / '--' $<name> = [ <-[-]> .* ] / {
            my $name = $<name>;

            if %named-params{ $name } -> $p {
                if $p.type ~~ Bool {
                    %names{ $name } = True;
                    @keepers .= grep: none($i);
                }
                else {
                    %names{ $name } = do {
                        my $final-value;
                        my $hhrecv = False;
                        for @args[$i^..*].kv -> $j, $value {
                            if $value ~~ '--' {
                                $hhrecv = True;
                            }
                            elsif $hhrecv || $value !~~ / ^ '--' <-[-]> / {
                                next unless $j == any(|@keepers);
                                $final-value = $value;
                                @keepers .= grep: none($j);
                                last;
                            }
                        }
                        $final-value //= fail "Parameter --$name expected an argument but got none.";
                        $final-value;
                    };
                    @keepers .= grep: none($i);
                }
            }
            elsif $name ~~ s/^ 'no-' // && %named-params{ $name } -> $p {
                %names{ $name } = False;
                @keepers .= grep: none($i);
            }
            else {
                die "No parameter named --$<name> is deifned for this command.";
            }
        }

        elsif $arg eq '--' {
            @keepers .= grep: none($i);
            last;
        }
    }

    # Anything left is positional
    my @pos-params = $sig.params.grep(*.positional);
    @pos = gather for @args Z @pos-params -> ($arg, $p) {
        given $p.type {
            when Bool    { take ?$arg }
            when Numeric { take +$arg }
            default      { take $arg }
        }
    }

    #dd \(|@pos, |%names);
    \(|@pos, |%names);
}

my role SubCommand[$name] {
    method sub-command() { $name }
}

my multi trait_mod:<is> (Routine $sub, :$sub-command!) {
    $sub does SubCommand[$sub-command];
}

our sub MAIN_HELPER($retval = 0) is export {
    my &main = callframe(1).my<&MAIN>;
    return $retval unless &main;

    my $args;
    for &main.candidates -> &main-candidate {
        next unless &main-candidate ~~ SubCommand;
        next unless &main-candidate.sub-command eq any(|@*ARGS);
        #note &main-candidate.sub-command;

        $args = order-options(&main-candidate.signature, @*ARGS);
        last if &main.cando($args);
    }

    # the option order Perl 6 allows is crummy
    main(|$args);
}

# usage: our &MAIN := build-main-for-class(...);

sub build-main-for-class(
    :$class!,      #= The class for which to build MAIN.
    :$methods = *, #= Smartmatcher naming methods to make available on the command-line.
) returns Routine:D is export {
    my $class-name  = $class.^name;
    my $MAIN = "MAIN-for-$class-name";

    my $MAIN-CODE = qq:to/END_OF_PROTO/;
    my proto sub $MAIN\(|) \{ * }
    END_OF_PROTO

    my (@common-pos, @common-named);
    my &build-method = $class.^find_method('BUILD');
    if &build-method {
        my $p := &build-method.signature.params;
        @common-pos   = $p.grep({ .positional });
        @common-named = $p.grep({ .named });
    }

    for $class.^methods.grep({ .name ~~ $methods }) -> &method {
        my @this-pos   = &method.signature.params.grep({ .positional });
        my @this-named = &method.signature.params.grep({ .named });

        my @ps = flat @common-pos, @this-pos, @common-named, @this-named;
        my $signature = [~] gather for @ps -> $p {
            next if $p.invocant;
            next if $p.slurpy;

            take "    ";
            take "$p.type().^name() " unless $p.type =:= Any;

            my $closers = '';
            if ?$p.named_names {
                for $p.named_names -> $name {
                    $closers ~= ")";
                    take ":";
                    take $name;
                    take "(";
                }
            }

            take $p.name.subst(/^(.)'!'(.)/, -> $/ { "$0$1" });
            take $closers;
            take ",\n";
        }

        my $build-capture = [~] gather for &build-method.signature.params -> $p {
            next if $p.invocant;
            next if $p.slurpy;

            take "        ";
            take ":" if $p.named;
            take $p.name.subst(/^(.)'!'(.)/, -> $/ { "$0$1" });
            take ",\n";
        }

        my $method-capture = [~] gather for &method.signature.params -> $p {
            next if $p.invocant;
            next if $p.slurpy;

            take "        ";
            take ":" if $p.named;
            take $p.name.subst(/^(.)'!'(.)/, -> $/ { "$0$1" });
            take ",\n";
        }

        my $method-name = &method.name;
        $MAIN-CODE ~= qq:to/END_OF_MAIN_METHOD/;
        my multi $MAIN\(\n    '$method-name',\n$signature) is sub-command('$method-name') \{
            $class-name.new\(\n$build-capture    ).$method-name\(\n$method-capture    );
        }
        END_OF_MAIN_METHOD
    }

    $MAIN-CODE ~= qq:to/END_OF_REF/;
    &$MAIN;
    END_OF_REF

    # my $i = 0;
    # note $MAIN-CODE.subst(/^^/, { sprintf "%3d: ", ++$i }, :g);
    use MONKEY-SEE-NO-EVAL;
    $MAIN-CODE.EVAL;
}
