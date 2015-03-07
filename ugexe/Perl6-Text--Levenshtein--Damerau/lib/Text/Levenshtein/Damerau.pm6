use v6;
class Text::Levenshtein::Damerau;

has Str  @.targets        is rw;
has Str  @.sources        is rw;
has Int  $.max            is rw;  # Int/-1 = no max distance
has Int  $.results_limit  is rw;  # Only return X closest results
has Hash %.results        is rw;
has Int  $.best_distance  is rw;
has Str  $.best_target    is rw;
has Str  $.best_source    is rw;

method get_results {
    my %results;
    my @working;

    for @.sources -> $source {
        for @.targets -> $target {
            @working.push(start { %results{$source}{$target} = dld($source, $target) });
            await Promise.anyof(@working);
        }
    }
    await Promise.allof(@working);

    for %results.kv -> $source, $targets {
        for $targets.kv -> $target, $distance {
            if !$.best_distance || $.best_distance > $distance {
                $.best_target   = $target;
                $.best_distance = $distance;
                $.best_source   = $source if @.sources.elems > 1;
            }
        }
    }

    %.results = %results;
    return %.results;
}


sub dld (Str $source is copy, Str $target is copy, Int $max?) is export {
    my Int $maxd = ($max.defined && $max >= 0) ?? $max !! $source.chars max $target.chars;
    my Int $sourceLength = $source.chars;
    my Int $targetLength = $target.chars;
    my Int (@currentRow, @previousRow, @transpositionRow);

    # Swap source/target so that $sourceLength always contains the shorter string
    if ($sourceLength > $targetLength) {
        ($source,$target)             .= reverse;
        ($sourceLength,$targetLength) .= reverse;
    }

    return ((!$max.defined || $maxd <= $targetLength)
        ?? $targetLength !! Int) if 0 ~~ any($sourceLength|$targetLength);

    my Int $diff = $targetLength - $sourceLength;
    return Int if $max.defined && $diff > $maxd;
    
    @previousRow[$_] = $_ for 0..$sourceLength+1;


    my Str $lastTargetCh = '';
    for 1..$targetLength -> Int $i {
        my Str $targetCh = $target.substr($i - 1, 1);
        @currentRow[0]   = $i;

        my Int $start = [max] $i - $maxd - 1, 1;
        my Int $end   = [min] $i + $maxd + 1, $sourceLength;

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
                        !! $maxd + 1;

            $lastSourceCh = $sourceCh;
        }

        $lastTargetCh = $targetCh;

        my Int @tempRow   = @transpositionRow;
        @transpositionRow = @previousRow;
        @previousRow      = @currentRow;
        @currentRow       = @tempRow;
    }

    return (!$max.defined || @previousRow[$sourceLength] <= $maxd) ?? @previousRow[$sourceLength] !! Int;
}


sub ld ( Str $source is copy, Str $target is copy, Int $max?) is export {
    my Int $maxd = ($max.defined && $max >= 0) ?? $max !! $source.chars max $target.chars;
    my Int $sourceLength = $source.chars;
    my Int $targetLength = $target.chars;
    my Int (@currentRow, @previousRow);

    #Swap source/target so that $sourceLength always contains the shorter string
    if ($sourceLength > $targetLength) {
        ($source,$target)             .= reverse;
        ($sourceLength,$targetLength) .= reverse;
    }

    return ((!$max.defined || $maxd <= $targetLength)
        ?? $targetLength !! Int) if 0 ~~ any($sourceLength|$targetLength);

    my Int $diff = $targetLength - $sourceLength;
    return Int if $max.defined && $diff > $maxd;

    @previousRow[$_] = $_ for 0..$sourceLength+1;

    for 1..$targetLength -> $i {
        my Str $targetCh = $target.substr($i - 1, 1);
        my Int $start = [max] $i - $maxd - 1, 1;
        my Int $end   = [min] $i + $maxd + 1, $sourceLength;
        @currentRow[0]   = $i;

        for $start..$end -> $j {
            my Str $sourceCh = $source.substr($j - 1, 1);
            @currentRow[$j] = [min] 
                @currentRow\[$j - 1] + 1,
                @previousRow[$j    ] + 1,
                @previousRow[$j - 1] + ($targetCh eq $sourceCh ?? 0 !! 1);

            return Int if ( @currentRow[0] == $j
                && $maxd < (($diff => @currentRow[@currentRow[0]])
                    ?? ($diff - @currentRow[@currentRow[0]]) 
                    !! (@currentRow[@currentRow[0]] + $diff))
            );
        }

        @previousRow[$_] = @currentRow[$_] for 0..@currentRow.end;
    }

    return (!$max.defined || @currentRow[*-1] <= $maxd) ?? @currentRow[*-1] !! Int;
}

