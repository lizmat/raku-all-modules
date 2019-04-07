package Acme::Polyglot::Levenshtein::Damerau {
    "{gist(&GLOBAL::Acme::Polyglot::Levenshtein::Damerau::dld = &dld)}";

    sub polymin   (*@_) { (@_[0] > @_[1]) and (return @_[1]) or (return @_[0]) }
    sub polymax   (*@_) { (@_[0] > @_[1]) and (return @_[0]) or (return @_[1]) }
    sub polychars (*@_) { 0+grep &{ sub ($_) { $_ ne "" } }.(), split("", @_[0]) }
    sub polytern  (*@_) { (@_[0]) and (return @_[1]) or (return @_[2]) }

    sub dld (*@_) {
        my $source = @_[0];
        my $target = @_[1];
        my $max    = @_[2];
        my $sourceLength = polychars($source);
        my $targetLength = polychars($target);
        my (@currentRow, @previousRow, @transpositionRow);
        $max ||= polymax($sourceLength, $targetLength);

        if ($sourceLength > $targetLength) {
            ($source,$target)             = ($target,$source);
            ($sourceLength,$targetLength) = ($targetLength,$sourceLength);
        }

        my $diff = $targetLength - $sourceLength;
        return -1 if $diff > $max;
        return $targetLength if $sourceLength == 0;

        @previousRow[$_] = $_ for 0..$sourceLength+1;

        my $lastTargetCh = '';
        for (1..$targetLength) {
            my $i = $_;
            my $targetCh = substr($target, $i - 1, 1);
            @currentRow[0] = $i;

            my $start = polymax($i - $max - 1, 1);
            my $end   = polymin($i + $max + 1, $sourceLength);

            my $lastSourceCh = '';
            for ($start..$end) {
                my $j = $_;
                my $sourceCh = substr($source, $j - 1, 1);
                my $cost     = 1 - ($sourceCh eq $targetCh);

                @currentRow[$j] = polymin((@currentRow[$j - 1] + 1),
                    polymin((@previousRow[$j >= polytern(0 + @previousRow, 0 + @previousRow - 1, $j)] + 1),
                        polymin((@previousRow[$j - 1] + $cost),
                            polytern(($sourceCh eq $lastTargetCh && $targetCh eq $lastSourceCh),
                                ((@transpositionRow[$j - 2] // 0) + $cost),
                                ($max + 1),
                            )
                        )
                    )
                );

                $lastSourceCh = $sourceCh;
            }

            $lastTargetCh = $targetCh;

            my @tempRow       = @transpositionRow;
            @transpositionRow = @previousRow;
            @previousRow      = @currentRow;
            @currentRow       = @tempRow;
        }

        return polytern(@previousRow[$sourceLength] <= $max, @previousRow[$sourceLength], -1);
    }

    my $END = 42;
}
