module Perl6::Literate;

my regex empty { ^ \s* $ }

our sub convert($text) {
    # There are six modes, 'start', 'code', 'comment', 'empty line after code'
    # and 'empty line after comment'. The latter two are abbreviated '_code'
    # and '_comment', respectively. All given-statements looping over $mode
    # should treat all four modes somehow.
    my $mode = 'start';

    my @p = gather {
        for $text.comb(/\N*\n|\N+\n?/).kv -> $n, $line {
            given $line {
                when /^ '>'/ {
                    given $mode {
                        when 'code'|'_code'|'start'|'_start' {
                            # all clear, break here
                        }
                        when '_comment' {
                            take "=end Comment\n";
                        }
                        when 'comment' {
                            die "Must have empty line before code paragraph "
                                ~ "on line $n";
                        }
                    }
                    take ' ' ~ $line.substr(1);
                    $mode = 'code';
                }
                when /<empty>/ {
                    take $line;
                    $mode.=subst(/^_?/, '_');
                }
                default {
                    given $mode {
                        when 'comment'|'_comment' {
                            # all clear, break here
                        }
                        when 'start'|'_start'|'_code' {
                            take "=begin Comment\n";
                        }
                        when 'code' {
                            die "Must have empty line after code paragraph "
                                ~ "on line $n";
                        }
                    }
                    take $line;
                    $mode = 'comment'
                }
            }
        }
        # RAKUDO: Would rather have this in a LAST block.
        if $mode ~~ /comment/ {
            take "\n=end Comment\n";
        }
    }

    # This is slightly hackish, but still much preferrable to buffering
    # lines and other unholy tricks.
    for reverse 0..(@p - 2) -> $n {
        if @p[$n] ~~ /<empty>/ && @p[$n+1] ~~ /'=end Comment'\n/ {
            (@p[$n], @p[$n+1]) = @p[$n+1], @p[$n];
        }
    }

    return [~] @p;
}
