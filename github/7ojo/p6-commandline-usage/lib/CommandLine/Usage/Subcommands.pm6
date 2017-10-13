class CommandLine::Usage::Subcommands {

    method apply($base, @filter) {
        if @filter.elems > 0 {
            $base.replace:
                SUBCOMMANDS-TEXT => " " ~ @filter.join(" ")
                ;
        } else {
            my @subcommands;
            for $base.func.candidates -> $candidate {
                my $param = $candidate.signature.params[0];
                if $param {
                    my @constraints = $param.constraint_list();
                    if @constraints.elems > 0 {
                        @subcommands.push: $candidate;
                    }
                }
            }

            my Str $subcommands-list = self.parse-subcommands(:@subcommands);
            $base.replace:
                SUBCOMMANDS-TEXT => " COMMAND",
                SUBCOMMANDS-LIST => "\n\nCommands:\n$subcommands-list\nRun '{$base.name} COMMAND --help' for more information on a command."
                ;
        }
    }
    
    method parse-subcommands (:@subcommands) returns Str {
        my %out;
        for @subcommands -> $candidate {
            my $param = $candidate.signature.params[0];
            my @constraints = $param.constraint_list();
            next if @constraints.elems == 0;
            my @why-block = $candidate.WHY.contents();
            for @why-block -> $text {
                if $text {
                    %out{@constraints[0]} = @why-block.join("\n");
                }
            }
        }
        my $out = '';
        for %out.keys.sort -> $key {
            $out ~= sprintf("%2s%-12s%s\n", '', $key, %out{$key});
        }
        $out;
    }

}
