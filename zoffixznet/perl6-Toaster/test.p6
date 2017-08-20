use JSON::Fast;
            # run «zef update»;
            given run(«zef --help», :err).err.slurp(:close)
              .lines.grep(*.starts-with: 'CONFIGURATION')
              .head.words.tail.trim.IO
            {
                my $j = from-json .slurp;
                for |$j<Repository> {
                    next unless .<short-name> eq 'p6c';
                    .<options><auto-update> = 0;
                    last;
                }
                .spurt: to-json $j;
            }
