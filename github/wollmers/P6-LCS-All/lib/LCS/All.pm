use v6;
module LCS::All:ver<0.2.0>:auth<wollmers> {

  our sub allLCS($X, $Y) is export {

    my int $m = @($X).elems;
    my int $n = @($Y).elems;

    my $ranks = {}; # e.g. '4' => [[3,6],[4,5]]
    my $c = [];
    my ($i,$j);

    for (0..$m) {$c[$_][0] = 0;}
    for (0..$n) {$c[0][$_] = 0;}
    loop ($i = 1; $i <= $m; $i++) {
      loop ($j = 1; $j <= $n; $j++) {
        if ($X[$i-1] eqv $Y[$j-1]) {
          $c[$i][$j] = $c[$i-1][$j-1]+1;
          push $ranks{$c[$i][$j]}, $[$i-1, $j-1];
        }
        else {
          $c[$i][$j] =
            ($c[$i][$j-1] > $c[$i-1][$j])
              ?? $c[$i][$j-1]
              !! $c[$i-1][$j];
        }
      }
    }
    my $max = %($ranks).keys.elems;
    return all_lcs($ranks, $max);
  }

  my sub all_lcs($ranks, $max) {
    my $R = [[],];
    my $rank = 1;

    while ($rank <= $max) {
      my @temp;
      for @($R) -> $path {
        for @($ranks{$rank}) -> $hunk {
          if ( @($path).elems == 0 ) {
            push @temp, [$hunk];
          }
          elsif ( ($path[*-1][0] < $hunk[0]) && ($path[*-1][1] < $hunk[1]) ) {
            push @temp, [(@($path), $hunk).flat];
          }
        }
      }
      @($R) = @temp;
      $rank++;
    }
    return $R;
  }

}

