
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

class Getopt::Advance::ReturnValue {
    has $.optionset;
    has @.noa;
    has %.return-value;
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
				if $optname eq $opt.short && $opt.need-argument {
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
multi sub ga-parser(
    @args,
    $optset,
    :$strict,
    :$x-style where :!so,
    :$bsd-style,
    :$autohv
) of Getopt::Advance::ReturnValue is export {
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
    # set value before non-option and main
    .set-value for @oav;
    # check option group and value optional
    $optset.check();
    # call callback of non-option
    &process-pos($optset, @noa);
    # call main
    my %ret;
    %ret = &process-main($optset, @noa) if !$autohv || !&will-not-process-main($optset);
    return Getopt::Advance::ReturnValue.new(
        optionset => $optset,
        noa => @noa,
        return-value => %ret,
    );
}

# check name
# check value
# then parse over
multi sub ga-parser(
    @args,
    $optset,
    :$strict,
    :$x-style where :so,
    :$bsd-style,
    :$autohv
) of Getopt::Advance::ReturnValue is export {
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
    # set value before non-option and main
    .set-value for @oav;
    # check option group and value optional
    $optset.check();
    # call callback of non-option
    &process-pos($optset, @noa);
    # call main
    my %ret;
    %ret = &process-main($optset, @noa) if !$autohv || !&will-not-process-main($optset);
    return Getopt::Advance::ReturnValue.new(
        optionset => $optset,
        noa => @noa,
        return-value => %ret,
    );
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

sub will-not-process-main($optset) {
    $optset.has('version') && $optset<version>
    ||
    $optset.has('help') && $optset<help>;
}

sub process-main($optset, @noa) {
    my %all = $optset.get-main();
    my %ret;

    for %all -> $all {
        %ret{$all.key} = $all.value.($optset, @noa);
    }
    return %ret;
}

sub process-pos($optset, @noa is copy) {
    my %cmd = $optset.get-cmd();
    my %pos = $optset.get-pos();
    my %need-sort-pos;
    my ($cmd-matched, $front-matched) = (False, False);

    # check cmd
    if %cmd.elems > 0 {
        if +@noa == 0 {
            ga-try-next("Need command: < {%cmd.values>>.usage.join("|")} >.");
        } else {
            my @cmdargs = @noa[1..*-1];
            for %cmd.values() -> $cmd {
                # check command
                if $cmd.match-name(@noa[0].value) {
                    if $cmd.($optset, @cmdargs) {
                        # exclude the cmd name
                        $cmd-matched = True;
                        last;
                    }
                }
            }
        }
    }

    # pos index base on 0
    # classify the pos base on index
    for %pos.values -> $pos {
        %need-sort-pos{
            -> $index {
                $index ~~ WhateverCode ?? $index.(+@noa) !! $index;
            }($pos.index)
        }.push: $pos;
    }

    my @fix-noa := @noa;

    # check front pos
    # maybe add by insert-pos :front or
    # insert-pos with index 0 or
    # insert-pos with * - 1
    if (not $cmd-matched) && +@noa > 0 && (%need-sort-pos{0}:exists) {
        for @(%need-sort-pos{0}) -> $front {
            try {
                if $front.($optset, @fix-noa[0]) {
                    $front-matched = True;
                    last;
                }
                CATCH {
                    when X::GA::PosCallFailed {}
                    default {
                        ...
                    }
                }
            }
        }
    }

    if (%cmd.elems > 0 && not $cmd-matched)
        && ((%need-sort-pos{0}:exists)
            && %need-sort-pos{0}.elems > 0 && not $front-matched) {
        # no cmd or pos matched, and pos is optional
        ga-try-next("Not recongnize command: {@noa[0].value}.");
    }

    # check other pos
    # remove 0 pos
    %need-sort-pos{0}:delete;
    for %need-sort-pos.keys.sort -> $index {
        if +@fix-noa > $index && $index >= 0 {
            for @(%need-sort-pos{$index}) -> $pos {
                try {
                    if $pos.($optset, @fix-noa[$index]) {
                        last;
                    }
                    CATCH {
                        when X::GA::PosCallFailed {}
                        default {
                            ...
                        }
                    }
                }
            }
        }
    }
}
