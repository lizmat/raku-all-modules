
use Getopt::Advance::Option;
use Getopt::Advance::Argument;
use Getopt::Advance::Exception;


my class OptionValueSetter {
    has $.optref;
    has $.value;

    method set-value() {
        $!optref.set-value($!value, :callback);
    }
}

grammar Option::Grammar {
	token TOP { ^ <option> $ }

	proto token option {*}

	token option:sym<s> { '-'  <optname> }

	token option:sym<l> { '--' <optname> }

	token option:sym<ds>{ '-/' <optname> }

	token option:sym<dl>{ '--/'<optname> }

	token option:sym<lv>{ '-'  <optname> '=' <optvalue> }

	token option:sym<sv>{ '--' <optname> '=' <optvalue>	}

	token optname {
		<-[\=]>+
	}

	token optvalue {
		.+
	}
}

enum Parser::Type (
    :LONG-X(1),
    :SHORT(2),
    :WITH-ARG(3),
    :COMPONENT(4),
);

class Option::Actions {
	has $.name;
	has $.value;
	has $.long;
    has $.type;

	method option:sym<s>($/) {
		$!name = ~$<optname>;
		$!long = False;
	}

	method option:sym<l>($/) {
		$!name = ~$<optname>;
		$!long = True;
	}

	method option:sym<ds>($/) {
		$!name  = ~$<optname>;
		$!value = False;
		$!long  = False;
	}

	method option:sym<dl>($/) {
		$!name  = ~$<optname>;
		$!value = False;
		$!long  = True;
	}

	method option:sym<lv>($/) {
		$!name  = ~$<optname>;
		$!value = ~$<optvalue>;
		$!long  = True;
	}

	method option:sym<sv>($/) {
		$!name  = ~$<optname>;
		$!value = ~$<optvalue>;
		$!long  = False;
	}

	# this check include gnu style and x-style i.e. '--foo' '-foo'
	method guess-long-x-option($optset, &get-value, $can-throw) {
        if (not $!long) && ($!name.chars < 2) {
            &ga-try-next("Option {$!name} not recongnized!") if $can-throw;
            return ();
        }
        if $optset.get($!name) -> $opt {
            if $!name eq ($!long ?? $opt.long !! $opt.short) {
                without $!value {
        			if not $opt.need-argument {
        				$!value = True;
        			} else {
        				$!value = &get-value();
        			}
        		}
                if $!value.defined && $opt.match-value($!value) {
                    $!type = Parser::Type::LONG-X;
                    return ($opt, $!value);
                } elsif $can-throw {
                    &ga-try-next("{$opt.usage}: {$!value} not correct!");
                }
            }
        }
        &ga-try-next("Option {$!name} not recongnized!") if $can-throw;
        return ();
	}

    # short-style '-a'
	method guess-short-option($optset, &get-value, $can-throw) {
        if $!name.chars > 1 {
            &ga-try-next("Option {$!name} not recongnized!") if $can-throw;
            return ();
        }
        if $optset.get($!name) -> $opt {
            if $!name eq $opt.short {
                without $!value {
        			if not $opt.need-argument {
        				$!value = True;
        			} else {
        				$!value = &get-value();
        			}
        		}
                if $!value.defined && $opt.match-value($!value) {
                    $!type = Parser::Type::SHORT;
                    return ($opt, $!value);
                } elsif $can-throw {
                    &ga-try-next("{$opt.usage}: {$!value} not correct!");
                }
            }
        }
        &ga-try-next("Option {$!name} not recongnized!") if $can-throw;
        return ();
	}

	# this assume first char is an option, and left is argument
	method guess-with-argument($optset, $can-throw) {
		unless $!name.chars < 2 || $!value.defined {
			my ($optname, $value) = ($!name.substr(0, 1), $!name.substr(1));

			if $optset.get($optname) -> $opt {
				if $optname eq $opt.short {
                    $!type = Parser::Type::WITH-ARG;
					return ($opt, $value);
				}
			}
		}
        &ga-try-next("Option {$!name} not recongnized!")
            if $can-throw;
        return ();
	}

	method guess-component-option($optset, &get-value, $can-throw) {
        my @opts = $!name.comb;

        if +@opts > 1 {
            if $optset.get(@opts[* - 1]) -> $opt {
                if $opt.need-argument and $!value == False {
                    &ga-try-next("Option {$opt.usage}: not support deactivate style!")
                        if $can-throw;
                    return ();
                }
                for @opts {
                    if $optset.get($_).need-argument {
                        &ga-try-next("Option {$optset.get($_).usage}: need argument!")
                            if $can-throw;
                        return ();
                    }
                }
                without $!value {
        			if not $opt.need-argument {
        				$!value = True;
        			} else {
        				$!value = &get-value();
        			}
        		}
                if $!value.defined && $opt.match-value($!value) {
                    $!type = Parser::Type::COMPONENT;
                    return ($!name, $!value);
                } elsif $can-throw {
                    &ga-try-next("{$opt.usage}: {$!value} not correct!");
                }
            }
        }
        &ga-try-next("Option {$!name} not recongnized!")
            if $can-throw;
        return ();
	}
}

# check name
# check value
# then parse over
multi sub ga-parser(@args, $optset, :$strict, :$x-style where :!so, :$bsd-style) of Array is export {
    my $count = +@args;
    my $noa-index = 0;
    my @oav = [];
    my @noa = [];

    loop (my $index = 0;$index < $count;$index++) {
        my $args := @args[$index];
        my ($name, $value, $long);
        my $actions = Option::Actions.new;
        my &get-value = sub () {
            if ($index + 1 < $count) {
                # $index increment when everything ok
                # and $value would be available in next guess
                # when match-value failed or exception will be throwed
                unless $strict && (so @args[$index + 1].starts-with('-'|'--'|'--/')) {
                    return @args[++$index];
                }
            }
        };

        # not in x-style
        if Option::Grammar.parse($args, :$actions) {
            my @ret = $actions.long ??
                $actions.guess-long-x-option($optset, &get-value, True) !!
                (
                    $actions.guess-short-option($optset, &get-value, False) ||
                    $actions.guess-with-argument($optset, False) ||
                    $actions.guess-component-option($optset, &get-value, False) ||
                    $actions.guess-long-x-option($optset, &get-value, True)
                );
            if +@ret > 0 {
                given $actions.type {
                    when Parser::Type::COMPONENT {
                        my @opts = @ret[0].comb;
                        @oav.push(OptionValueSetter.new(
                            optref => @opts[* - 1],
                            value  => @ret[1],
                        ));
                        @oav.push(OptionValueSetter.new(
                            optref => $optset.get($_), :value
                        )) for @opts[0 ... * - 2];
                    }
                    default {
                        @oav.push(OptionValueSetter.new(
                            optref => @ret[0],
                            value  => @ret[1],
                        ));
                    }
                }
            }
        } else {
            my @ret = $bsd-style ?? &process-bsd-style($optset, $args) !! [];
            if +@ret > 0 {
                @oav.append(@ret);
            } else {
                @noa.push(Argument.new(index => $noa-index++, value => $args));
            }
        }
    }

    # call callback of non-option
    &process-pos($optset, @noa);
    # set value before main
    .set-value for @oav;
    # call main
    &process-main($optset, @noa);
    # check option group and value optional
    $optset.check();

    return @noa;
}

# check name
# check value
# then parse over
multi sub ga-parser(@args, $optset, :$strict, :$x-style where :so, :$bsd-style) of Array is export {
    my $count = +@args;
    my $noa-index = 0;
    my @oav = [];
    my @noa = [];

    loop (my $index = 0;$index < $count;$index++) {
        my $args := @args[$index];
        my ($name, $value, $long);
        my $actions = Option::Actions.new;
        my &get-value = sub () {
            if ($index + 1 < $count) {
                unless $strict && (so @args[$index + 1].starts-with('-'|'--'|'--/')) {
                    return @args[++$index];
                }
            }
        };

        if Option::Grammar.parse($args, :$actions) {
            my @ret = $actions.long ??
                $actions.guess-long-x-option($optset, &get-value, True) !!
                (
                    $actions.guess-long-x-option($optset, &get-value, False) ||
                    $actions.guess-short-option($optset, &get-value, False) ||
                    $actions.guess-with-argument($optset, False) ||
                    $actions.guess-component-option($optset, &get-value, True)
                );
            if +@ret > 0 {
                given $actions.type {
                    when Parser::Type::COMPONENT {
                        my @opts = @ret[0].comb;
                        @oav.push(OptionValueSetter.new(
                            optref => @opts[* - 1],
                            value  => @ret[1],
                        ));
                        @oav.push(OptionValueSetter.new(
                            optref => $optset.get($_), :value
                        )) for @opts[0 ... * - 2];
                    }
                    default {
                        @oav.push(OptionValueSetter.new(
                            optref => @ret[0],
                            value  => @ret[1],
                        ));
                    }
                }
            }
        } else {
            my @ret = $bsd-style ?? &process-bsd-style($optset, $args) !! [];
            if +@ret > 0 {
                @oav.append(@ret);
            } else {
                @noa.push(Argument.new(index => $noa-index++, value => $args));
            }
        }
    }

    # call callback of non-option
    &process-pos($optset, @noa);
    # set value before main
    .set-value for @oav;
    # call main
    &process-main($optset, @noa);
    # check option group and value optional
    $optset.check();

    return @noa;
}


sub process-bsd-style($optset, $arg) {
    my $check = True;
    my @options = $arg.comb();

    $check &&= $optset.has($_) && ( not $optset.get($_).need-argument)
        for @options;

    return $check ?? [
        OptionValueSetter.new(
            optref => $optset.get($_),
            :value
        ) for @options
    ] !! ();
}

sub process-main($optset, @noa) {
    my %all = $optset.get-main();

    for %all.values() -> $all {
        $all.($optset, @noa);
    }
}

sub process-pos($optset, @noa) {
    my %cmd = $optset.get-cmd();
    my %pos = $optset.get-pos();

    if %cmd.elems > 0 {
        if +@noa == 0 {
            ga-try-next("Need command: < {%cmd.values>>.usage.join("|")} >.");
        } else {
            my $matched = False;
            for %cmd.values() -> $cmd {
                # check command
                if $cmd.match-name(@noa[0].value) {
                    $matched ||= $cmd.($optset, @noa);
                }
            }
            unless $matched {
                # when no command matched, check if there
                # any pos[Int] can match
                for %pos.values() -> $pos {
                    if $pos.index ~~ Int {
                        for @noa -> $noa {
                            if $pos.match-index(+@noa, 0) {
                                $matched = True;
                            }
                        }
                    }
                }
            }
            unless $matched {
                # no cmd or pos matched
                ga-try-next("Not recongnize command: {@noa[0].value}.");
            }
        }
    }
    if +@noa > 0 {
        for %pos.values() -> $pos {
            for @noa -> $noa {
                if $pos.match-index(+@noa, $noa.index) {
                    $pos.($optset, $noa);
                }
            }
        }
    }
}
