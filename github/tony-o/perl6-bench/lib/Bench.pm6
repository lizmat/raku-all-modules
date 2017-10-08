use Text::Table::Simple;

class Bench {
  has Bool $.debug     = False;
  has Int  $.min_count = 4;
  has Rat  $.min_cpu   = 0.04;
  has Str  $.format    = '%5.4f';
  has Str  $.style     = 'auto';

  method timediff($a, $b){
    my $r = Array.new;
    for 0..max($a.end,$b.end) -> $i {
      $r.append(($a[$i] // 0) - ($b[$i] // 0));
    }
    return $r;
  }

  method timesum($a, $b){
    my $r = Array.new;
    for 0..max($a.end,$b.end) -> $i {
      $r.append(($a[$i] // 0) + ($b[$i] // 0));
    }
    return $r;
  }

  method timestr($t, :$style = $.style, :$format = $.format){
    my ($r, $n) = @$t; 
    my $f = $format;
    my $s = '';
    $s ~= sprintf("$f wallclock secs", $r);
    my $elapsed = $r;
    $s ~= sprintf(" \@ $f/s (n=$n)", $n/$elapsed) if $n && $elapsed;
    return $s;
  }

  method timedebug($msg,$t){
    $*ERR.say: "$msg {$.timestr($t);}" if $.debug;
  }

  method runloop(Int $n, $c){
    die "Negative loop count ($n)" if $n < 0;
    my ($t0, $t1, $td);
    my $subcode = "sub \{ for (1..$n) \{ \$c(); \}; \}";
    my $tbase   = now;
    my $ev = &($subcode.EVAL);
    while (($t0 = now) == $tbase) { };
    $ev.();
    $t1 = now;
    $td = $.timediff([$t1], [$t0]);
    return $td;
  }

  method timeit(Int $n, $c) {
    my ($wn, $wc, $wd);
    $*ERR.say: "timeit $n {$c.gist}" if $.debug;
    $wn    = $.runloop($n, $c.WHAT ~~ Callable ?? sub { } !! 'sub \{ \}');
    $wn[1] = 0;
    $wc    = $.runloop($n, $c);
    $wc[1] = $n;
    $wd    = $.timediff($wc, $wn);
    $.timedebug('timeit: ', $wc);
    $.timedebug('      - ', $wn);
    $.timedebug('      = ', $wd);
    return $wd;
  }

  method countit($max, $c) {
    my Rat $tmax = Rat.new($max == 0 ?? 0.1 !! $max < 0 ?? -$max !! $max);
    my (Int $n, $tc);
    my $zeros = 0;
    loop ($n = 1; ; $n *= 2) {
      my $t0 = now;
      my $td = $.timeit($n, $c);
      my $t1 = now;
      $tc = $td[0];
      if ($tc <= 0 and $n > 1024) {
        my $d = $.timediff($t1,$t0);
        if ($d[0] > 8 || ++$zeros > 16) {
          die "Timing consistently zero in estimation loop, cannot benchmark. N=$n";
        }
      } else {
        $zeros = 0;
      }
      last if $tc > 0.1;
    }
    my $nmin = $n;
    my $tpra = 0.1 * $tmax;
    while ($tc < $tpra) {
      $n = Int($tpra * 1.05 * $n / $tc);
      my $td = $.timeit($n, $c);
      my $new_tc = $.timeit($n, $c);
      $tc = $new_tc > 1.2 * $tc ?? $new_tc !! 1.2 * $tc;
    }
    my ($ntotal, $rtotal) = 0;
    $n = Int($n * (1.05 * $tmax / $tc));
    $zeros = 0;
    while (True) {
      my $td   = $.timeit($n,$c);
      $ntotal += $n;
      $rtotal += $td[0];
      last if $rtotal >= $tmax;
      if ($rtotal <= 0) {
        ++$zeros > 16 and die "Timing consistently zero, cannot benchmark. N=$n";
      } else {
        $zeros = 0;
      }
      $rtotal = 0.01 if $rtotal < 0.01;
      my $r = $tmax / $rtotal - 1;
      $n = Int($r * $ntotal);
      $n = $nmin if $n < $nmin;
    }
    return Array.new($rtotal, $ntotal);
  }

  method !n_to_for(Int $n) {
    return $n == 0 ?? $.min_count - 1 !! $n < 0 ?? -$n !! $n;
  }

  method timethis(Int $n, $c, :$title? = '', :$style = $.style) {
    my ($t, $forn);
    $t = $.countit(self!n_to_for($n), $c)
         if $n <= 0;
    $t = $.timeit($n, $c)
         if $n > 0;
    $title = "timethis for $n" unless defined $title;
    $forn  = $t[*-1];
    say sprintf("%10s: %s", $title, $.timestr($t));
    say "\t\t(warning: too few iterations for a reliable count)"
        if $n < $.min_count ||
           ($t[0] < 1 && $n < 1000);
    return $t;
  }

  method timethese(Int $n, $alts) {
    my @names = %$alts.keys.sort;
    say 'Benchmark: ';
    if ($n > 0) {
      print "Timing $n iterations of ";
    } else {
      print "Running ";
    }
    print @names.join(', ');
    unless ($n > 0) {
      my $for = self!n_to_for($n);
      print ", each" if $n > 1;
      print ", for at least $for seconds";
    }
    say '...';
    my $results = Hash.new;
    for @names -> $name {
      %$results{$name} = $.timethis($n, %$alts{$name}, :title($name));
    }
    return $results;
  }

  multi method cmpthese(Int $n, $alts) {
    my $results = $.timethese($n, $alts);
    my @vals    = map { [$_, |@(%$results{$_})] }, %$results.keys;
    for @vals -> $val {
      my $elapsed = $val[1];
      my $rate = $val[2] / ($elapsed + 0.00000000000000000001);
      $val[3] = $rate;
    }
    @vals.sort({ $^a[3] <=> $^b[3] });

    my $displayrate = @vals.end > 0 && @vals[@vals.end/2][3] > 1 ?? 
                        True !! 
                        False;
    my @cols = flat (' ', $displayrate ?? 'Rate' !! 's/iter', @vals.map({ $_[0] }).Slip);
    my @rows;
    for @vals -> $val {
      my ($row, $skip, $f, $rate);
      $row = Array.new;
      $row.append($val[0]);
      #@row.append($val[3]);
      $rate = $displayrate ?? $val[3] !! 1 / $val[3];
      given ($rate) {
        when $_ >= 100 { $f = '%0.0f' };
        when $_ >= 10  { $f = '%0.1f' };
        when $_ >= 1   { $f = '%0.2f' };
        when $_ >= 0.1 { $f = '%0.3f' };
        default        { $f = '%0.2e' };
      };
      $f ~= '/s' if $displayrate;
      $row.append(sprintf($f, $rate));
      for 0..@vals.end -> $i {
        my $colval = @vals[$i];
        my $out;
        if ($skip) {
          $out = '';
        } elsif ($colval[0] eq $val[0]) {
          $out = '--';
        } else {
          $out = sprintf('%.0f%%', 100 * $val[3] / $colval[3] - 100);
        }
        $row.append($out);
      }
      @rows.append($row);
    }
    .say for lol2table(@cols,@rows);
  }
};

