use v6;
unit module Text::Levenshtein::Damerau;

sub dld (str $source is copy, str $target is copy, int $max? is copy --> Int) is export {
    my int $sourceLength = $source.chars;
    my int $targetLength = $target.chars;
    my int (@currentRow, @previousRow, @transpositionRow);
    $max ||= $sourceLength max $targetLength;

    # Swap source/target so that $sourceLength always contains the shorter String
    if ($sourceLength > $targetLength) {
        ($source,$target)             .= reverse;
        ($sourceLength,$targetLength) .= reverse;
    }

    my int $diff = $targetLength - $sourceLength;
    return Int if $diff > $max;
    return $targetLength if $sourceLength == 0;

    @previousRow[$_] = $_ for 0..$sourceLength+1;

    my str $lastTargetCh = '';
    for 1..$targetLength -> int $i {
        my str $targetCh = $target.substr($i - 1, 1);
        @currentRow[0]   = $i;

        my int $start = max $i - $max - 1, 1;
        my int $end   = min $i + $max + 1, $sourceLength;

        my str $lastSourceCh = '';
        for $start..$end -> int $j {
            my str $sourceCh = $source.substr($j - 1, 1);
            my int $cost     = $sourceCh eq $targetCh ?? 0 !! 1;

            @currentRow[$j] = min
                @currentRow\[$j - 1] + 1, 
                @previousRow[$j >= @previousRow.elems ?? *-1 !! $j] + 1,
                @previousRow[$j - 1] + $cost,
                    ($sourceCh eq $lastTargetCh && $targetCh eq $lastSourceCh)
                        ?? @transpositionRow[$j - 2] + $cost
                        !! $max + 1;

            $lastSourceCh = $sourceCh;
        }

        $lastTargetCh = $targetCh;

        my int @tempRow   = @transpositionRow;
        @transpositionRow = @previousRow;
        @previousRow      = @currentRow;
        @currentRow       = @tempRow;
    }

    return @previousRow[$sourceLength] <= $max ?? @previousRow[$sourceLength] !! Int;
}

sub ld (str $source is copy, str $target is copy, int $max? is copy --> Int) is export {
    my int $sourceLength = $source.chars;
    my int $targetLength = $target.chars;
    my int (@currentRow, @previousRow);
    $max ||= $source.chars max $target.chars;

    #Swap source/target so that $sourceLength always contains the shorter String
    if ($sourceLength > $targetLength) {
        ($source,$target)             .= reverse;
        ($sourceLength,$targetLength) .= reverse;
    }

    my int $diff = $targetLength - $sourceLength;
    return Int if $diff > $max;
    return $targetLength if 0 ~~ any($sourceLength|$targetLength);

    @previousRow[$_] = $_ for 0..$sourceLength+1;

    for 1..$targetLength -> int $i {
        my str $targetCh = $target.substr($i - 1, 1);
        my int $start = max $i - $max - 1, 1;
        my int $end   = min $i + $max + 1, $sourceLength;
        @currentRow[0]   = $i;

        for $start..$end -> int $j {
            my str $sourceCh = $source.substr($j - 1, 1);
            @currentRow[$j] = min 
                @currentRow\[$j - 1] + 1,
                @previousRow[$j    ] + 1,
                @previousRow[$j - 1] + ($targetCh eq $sourceCh ?? 0 !! 1);

            return Int if ( @currentRow[0] == $j
                && $max < (($diff => @currentRow[@currentRow[0]])
                    ?? ($diff - @currentRow[@currentRow[0]]) 
                    !! (@currentRow[@currentRow[0]] + $diff))
            );
        }

        @previousRow[$_] = @currentRow[$_] for 0..@currentRow.end;
    }

    return @currentRow[*-1] <= $max ?? @currentRow[*-1] !! Int;
}
