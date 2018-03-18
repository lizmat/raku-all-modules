

use Getopt::Advance::Parser;

sub config-loader-parser(@args, $optset, |c) is export {
    my (@loadop, @config, @noa);
	my %configs = shift @args;

    loop (my $i = 0;$i < +@args; $i++) {
        if @args[$i] eq '-l' { # only process -l option
            @loadop.push($i);
            @config.push(@args[++$i]);
        } else {
            @noa.push(@args[$i]);
        }
    }

	my %category := SetHash.new;

    for @config.sort.unique -> $name {
        if %configs{$name}:exists {
			for @(%configs{$name}<option>) -> $option {
				my $short = $option<short>;

				%category{$short} = True;
				if $optset.has($short) {
					my $o = $optset.get($short);
					my @ins := $option<value>;
					my @old := $o.default-value // [];

					@old.append(@ins);
					@old = @old.sort.unique;
					$o.set-default-value(@old);
					$o.reset-value;
				} else {
					$optset.push( "{$short}| = a", $option<annotation>, value => @($option<value>));
				}
			}
		} else {
			note "Not recognize config name: $name";
		}
    }

    return Getopt::Advance::ReturnValue.new(
        optionset => $optset,
        noa => @noa,
        return-value => %category,
    );
}
