
multi sub ga-helper($optset, $outfh) is export {
	my ($usage, @annotations) := &ga-helper-impl($optset, $outfh);

	$outfh.say("Usage:");
	$outfh.say($usage);
	$outfh.say($_) for @annotations;
}

multi sub ga-helper(@optsets, $outfh) is export {
	my @annotationss = [];

	$outfh.say("Usage:");
	for @optsets -> $optset {
		my ($usage, @annotations) := &ga-helper-impl($optset, $outfh);
		$outfh.say($usage);
		#@annotationss.push(@annotations);
	}
	# There not a good way display annotations of multi
	# OptionSet, so do not display it.
	#`(for @annotationss -> $annotations {
		$outfh.say($_) for @$annotations;
	})
}

multi sub ga-helper2($optset, $outfh, :$table-format) is export {
	my ($usage, @annotations) := &ga-helper-impl2($optset, $outfh, :$table-format);

	$outfh.say("Usage:");
	$outfh.say($usage);
	$outfh.say($_) for @annotations;
}

multi sub ga-helper2(@optsets, $outfh, :$table-format) is export {
	my @annotationss = [];

	$outfh.say("Usage:");
	for @optsets -> $optset {
		my ($usage, @annotations) := &ga-helper-impl2($optset, $outfh, :$table-format);

		$outfh.say($usage);
		#@annotationss.push(@annotations);
	}
	#`(for @annotationss -> $annotations {
		$outfh.say($_) for @$annotations;
	})
}

sub ga-helper-impl($optset, $outfh) is export {
    my %no-cmd = $optset.get-cmd();
    my %no-pos = $optset.get-pos();
    my @main = $optset.values();
    my (@command, @front, @pos, @wepos, @opts) := ([], [], [], [], []);

    if %no-cmd.elems > 0 {
        @command.push($_) for %no-cmd.values>>.usage;
    }

    if %no-pos.elems > 0 {
        my $fake = 4096;
        my %kind = classify {
            $_.index ~~ Int ?? ($_.index == 0 ?? 0 !! 'index' ) !! '-1'
        }, %no-pos.values;

        if %kind{0}:exists && %kind<0>.elems > 0 {
            @front.push("<{$_}>") for @(%kind<0>)>>.usage;
        }

        if %kind<index>:exists && %kind<index>.elems > 0 {
            my %pos = classify { $_.index }, @(%kind<index>);

            for %pos.sort(*.key)>>.value -> $value {
                @pos.push("<{join("|", @($value)>>.usage)}>");
            }
        }

        if %kind{-1}:exists && %kind{-1}.elems > 0 {
            my %pos = classify { $_.index.($fake) }, @(%kind{-1});

            for %pos.sort(*.key)>>.value -> $value {
                @wepos.push("<{join("|", @($value)>>.usage)}>");
            }
        }
    }
    for @main -> $opt {
        @opts.push($opt.optional ?? "[{$opt.usage}]" !! "<{$opt.usage}>");
    }

    my $usage = "{$*PROGRAM-NAME} ";

    $usage ~= '[' if +@command > 1 || +@front > 1 || (+@command > 0 && +@front > 0);
    $usage ~= @command.join("|") if +@command > 0;
    $usage ~= '|' if +@command > 0 && +@front > 0;
    $usage ~= @front.join("|") if +@front > 0;
    $usage ~= ']' if +@command > 1 || +@front > 1 || (+@command > 0 && +@front > 0);
    $usage ~= " {join(" ", @pos)} ";
    $usage ~= "{join(" ", @opts)} {join(" ", @wepos)} ";
    $usage ~= $optset.get-main().elems > 0 ?? "*\@args\n" !! "\n";

	my @annotations = [];

 	@annotations.push("{.join(" ")}\n") for @($optset.annotation());

	($usage, @annotations);
}

sub ga-helper-impl2($optset, $outfh, :$table-format) is export {
    my %no-cmd = $optset.get-cmd();
    my %no-pos = $optset.get-pos();
    my @main = $optset.values();
    my (@command, @pos, @wepos, @opts) := ([], [], [], []);

    if %no-cmd.elems > 0 {
        @command.push($_) for %no-cmd.values>>.usage;
    }

    if %no-pos.elems > 0 {
        my $fake = 4096;
        my %kind = classify {
            $_.index ~~ Int ?? ($_.index == 0 ?? 0 !! 'index' ) !! '-1'
        }, %no-pos.values;

        if %kind{0}:exists && %kind<0>.elems > 0 {
            @command.push("<{$_}>") for @(%kind<0>)>>.usage;
        }

        if %kind<index>:exists && %kind<index>.elems > 0 {
            my %pos = classify { $_.index }, @(%kind<index>);

            for %pos.sort(*.key)>>.value -> $value {
                @pos.push("<{join("|", @($value)>>.usage)}>");
            }
        }

        if %kind{-1}:exists && %kind{-1}.elems > 0 {
            my %pos = classify { $_.index.($fake) }, @(%kind{-1});

            for %pos.sort(*.key)>>.value -> $value {
                @wepos.push("<{join("|", @($value)>>.usage)}>");
            }
        }
    }
    for @main -> $opt {
        @opts.push($opt.optional ?? "[{$opt.usage}]" !! "<{$opt.usage}>");
    }

	my $usage = "";

	if +@command == 0 {
		$usage ~= "{$*PROGRAM-NAME} {join(" ", @pos)} ";
		$usage ~= "{join(" ", @opts)} {join(" ", @wepos)} ";
		$usage ~= $optset.get-main().elems > 0 ?? "*\@args\n" !! "\n";
	} else {
		if not $table-format {
			for @command -> $cmd {
				$usage ~= "{$*PROGRAM-NAME} {$cmd} {join(" ", @pos)} ";
				$usage ~= "{join(" ", @opts)} {join(" ", @wepos)} ";
				$usage ~= $optset.get-main().elems > 0 ?? "*\@args\n" !! "\n";
			}
	    } else {
	        my @usage = [];

	        for @command -> $cmd {
	            my @inner-usage = [];

	            @inner-usage.push($*PROGRAM-NAME);
	            @inner-usage.push($cmd);
	            @inner-usage.append(@pos);
	            @inner-usage.append(@opts);
	            @inner-usage.append(@wepos);
	            @inner-usage.append($optset.get-main().elems > 0 ?? "*\@args" !! "");
	            @usage.push(@inner-usage);
	        }

	        require Terminal::Table <&array-to-table>;

	        $usage ~= .join(" ") ~ "\n" for &array-to-table(@usage, style => 'none');
	    }
	}
	my @annotations = [];

	@annotations.push("{.join(" ")}\n") for @($optset.annotation());
	($usage, @annotations);
}

sub ga-versioner($version, $outfh) is export {
    $outfh.say($version) if $version;
}
