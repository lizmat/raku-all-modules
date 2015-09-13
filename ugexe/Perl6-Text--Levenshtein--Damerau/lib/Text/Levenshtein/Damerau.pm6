use v6;
unit class Text::Levenshtein::Damerau;

has Str  @.targets        is rw;
has Str  @.sources        is rw;
has Int  $.max            is rw;  # Int/-1 = no max distance
has Int  $.results_limit  is rw;  # Only return X closest results
has Hash %.results        is rw;
has Int  $.best_distance  is rw;
has Str  $.best_target    is rw;
has Str  $.best_source    is rw;

method get_results {
    my @working;

    for @!sources -> $source {
        for @!targets -> $target {
            @working.push(%!results{$source}{$target} = dld($source, $target));
        }
    }

    for %!results.kv -> $source, $targets {
        for $targets.kv -> $target, $distance {
            if !$!best_distance || $!best_distance > $distance {
                $!best_target   = $target;
                $!best_distance = $distance;
                $!best_source   = $source if @!sources.elems > 1;
            }
        }
    }

    return %!results;
}


sub dld (Str $source is copy, Str $target is copy, Int $max? is copy) is export {
    my Int $sourceLength = $source.chars;
    my Int $targetLength = $target.chars;
    my Int (@currentRow, @previousRow, @transpositionRow);
    $max = $sourceLength max $targetLength unless $max;

    # Swap source/target so that $sourceLength always contains the shorter String
    if ($sourceLength > $targetLength) {
        ($source,$target)             .= reverse;
        ($sourceLength,$targetLength) .= reverse;
    }

    return ($max <= $targetLength ?? $targetLength !! Int) if 0 == any($sourceLength|$targetLength);

    my Int $diff = $targetLength - $sourceLength;
    return Int if $diff > $max;
    
    @previousRow[$_] = $_ for 0..$sourceLength+1;

    my Str $lastTargetCh = '';
    for 1..$targetLength -> Int $i {
        my Str $targetCh = $target.substr($i - 1, 1);
        @currentRow[0]   = $i;

        my Int $start = [max] $i - $max - 1, 1;
        my Int $end   = [min] $i + $max + 1, $sourceLength;

        my Str $lastSourceCh = '';
        for $start..$end -> Int $j {
            my Str $sourceCh = $source.substr($j - 1, 1);
            my Int $cost     = $sourceCh eq $targetCh ?? 0 !! 1;

            @currentRow[$j] = [min] 
                @currentRow\[$j - 1] + 1, 
                @previousRow[$j >= @previousRow.elems ?? *-1 !! $j] + 1,
                @previousRow[$j - 1] + $cost,
                    ($sourceCh eq $lastTargetCh && $targetCh eq $lastSourceCh)
                        ?? @transpositionRow[$j - 2] + $cost
                        !! $max + 1;

            $lastSourceCh = $sourceCh;
        }

        $lastTargetCh = $targetCh;

        my Int @tempRow   = @transpositionRow;
        @transpositionRow = @previousRow;
        @previousRow      = @currentRow;
        @currentRow       = @tempRow;
    }

    return @previousRow[$sourceLength] <= $max ?? @previousRow[$sourceLength] !! Int;
}


sub ld ( Str $source is copy, Str $target is copy, Int $max? is copy) is export {
    my Int $sourceLength = $source.chars;
    my Int $targetLength = $target.chars;
    my Int (@currentRow, @previousRow);
    $max = $source.chars max $target.chars unless $max;

    #Swap source/target so that $sourceLength always contains the shorter String
    if ($sourceLength > $targetLength) {
        ($source,$target)             .= reverse;
        ($sourceLength,$targetLength) .= reverse;
    }

    return ($max <= $targetLength ?? $targetLength !! Int) if 0 ~~ any($sourceLength|$targetLength);

    my Int $diff = $targetLength - $sourceLength;
    return Int if $diff > $max;

    @previousRow[$_] = $_ for 0..$sourceLength+1;

    for 1..$targetLength -> $i {
        my Str $targetCh = $target.substr($i - 1, 1);
        my Int $start = [max] $i - $max - 1, 1;
        my Int $end   = [min] $i + $max + 1, $sourceLength;
        @currentRow[0]   = $i;

        for $start..$end -> $j {
            my Str $sourceCh = $source.substr($j - 1, 1);
            @currentRow[$j] = [min] 
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

