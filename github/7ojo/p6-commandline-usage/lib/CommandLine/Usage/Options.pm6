class CommandLine::Usage::Options {

    method apply($base, @filter) {
        my @candidates;
        my @explanations;
        my Bool $filter-by-constraint = @filter.elems > 0; # Are we doing subcommand usage?
        if $filter-by-constraint {
            for $base.func.candidates -> $candidate {
                my Bool $got-it = False;
                loop ( my $i=0; $i < @filter.elems; $i++ ) {
                    my $param = $candidate.signature.params[$i];
                    next unless $param;
                    my @param-constraints = $param.constraint_list();
                    if @param-constraints[0] {
                        my Str $first-constraint = @param-constraints[0]; # Probably doesn't scale on more complicated stuff
                        $got-it = $first-constraint eq @filter[$i];
                    }
                    last if $got-it == False;
                }
                if $got-it {
                    @candidates.push: $candidate;
                    @explanations.push: $candidate.WHY;
                }
            }
        } else {
            for $base.conf.candidates -> $candidate {
                my $param = $candidate.signature.params[0];
                if $param.constraint_list().elems == 0 {
                    @candidates.push: $candidate;
                }
            }
        }
        my $out-options = self.parse-options(:candidates(@candidates));
        if $out-options.chars > 0 {
            $base.replace:
                OPTIONS-TEXT => $filter-by-constraint ?? " [OPTIONS]" !! '',
                OPTIONS-LIST => "Options:\n$out-options"
                ;
        } else {
            $base.replace:
                OPTIONS-TEXT => ''
                ;
        }
    }

    method parse-options (:@candidates) {
        my $out = '';
        for @candidates -> $candidate {
            for $candidate.signature.params -> $param {
                next if $param.constraint_list();

                my $short-param = '';
                my $long-param = '';
                my $default-value = '';
                my $param-type = '';

                my token type { \w+ <?before \s> }
                my token name { <-[\s\$():]>+ }
                my token short-name { <?after ':'> <name> <?before '('> };
                my token long-name { <?after ':$'> <name> };
                my token separator { '(:'  };

                $param-type = $0 if $param.perl ~~ /^ (<type>) /;
                $short-param = "-$0" if $param.perl ~~ / (<short-name>) /;
                $long-param = "--$0" if $param.perl ~~ / (<long-name>) /;
                $default-value = $0 if $param.perl ~~ / '=' \s* '"'? (<-["]>+) '"'? /;

                given $param-type {
                    when 'Int' {
                        $param-type = 'integer';
                    }
                    when 'Str' {
                        $param-type = 'string';
                    }
                    default {
                        $param-type = 'string' if $default-value ~~ / \w /;
                    }
                }
                $long-param ~= " $param-type".lc if $param-type.chars > 0;

                next if $short-param eq $long-param;

                $short-param ~= $short-param.chars > 0 && $long-param.chars > 0 ?? ', ' !! '  ';
                my $usage = $param.WHY ?? $param.WHY.Str !! '';
                if $default-value {
                    $default-value ~~ s/ '\$HOME' /$*HOME/;
                    $usage ~= ' ' if $usage.chars > 0 and $default-value.chars > 0;
                    $usage ~= "(default \"$default-value\")";
                }
                $out ~= sprintf("%6s%-21s%s\n",
                    $short-param.chars > 0 ?? $short-param !! '',
                    $long-param.chars > 0 ?? $long-param !! '',
                    $usage
                    );
            }
        }
        $out;
    }

}
