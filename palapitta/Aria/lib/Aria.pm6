class Aria {
  sub check($var) {
    my $y = substr($var, *-1);
    if $y eq 'k' {
      my $w = chop $var;
      return $w ~ 'K';
    }
    elsif $y eq 'm' {
      my $w = chop $var;
      return $w ~ 'M';
    }
    else {
      $var;
    }
  }

 sub check-log($text) {
   my $cont = slurp $text;
 		if ($cont ~~ /(OK)/) {
 			unlink $text;
 			return "OK";
 	}
 	elsif ($cont ~~ /(ERR)/) {
 		unlink $text;
 		return "ERR";
 	}
 	elsif ($cont ~~ /(INPR)/) {
 		unlink $text;
 		return "INPR";
 	}
 	else {
 		unlink $text;
 		return "ERR";
 	}
 }

  method get($dir, $link) {
    unless $dir { mkdir $dir; }
    my $log = "log" ~ rand.split(".")[1] ~ ".txt";
    my $conte = qqx/aria2c -d "$dir" "$link" > $log 2>&1/;
    return check-log($log);
  }

  method get-limit($dir, $link, $speed) {
    unless $dir { mkdir $dir; }
    my $log = "log" ~ rand.split(".")[1] ~ ".txt";
    my $lim = check($speed);
    my $conte = qqx/aria2c -d "$dir" --max-download-limit=$lim "$link" > $log 2>&1/;
    return check-log($log);
  }

 method  get-multi(*@arr) {
    my $dir = @arr[0];
    unless $dir { mkdir $dir; }
    for 1 .. @arr.elems-1 -> $v {
      if @arr.WHAT.gist eq "(Any)" {
        @arr[$v] = "";
      }
    }
    my $log = "log" ~ rand.split(".")[1] ~ ".txt";
    my $conte = qqx/aria2c -d $dir @arr[1] @arr[2] @arr[3] @arr[4] @arr[5] > $log 2>&1/;
    return check-log($log);
  }

  method get-concurrent($dir, $link, $num) {
    unless $dir { mkdir $dir; }

    if $num > 7 {
      $num = 7 ;
     }
    my $n = "-x" ~ $num;
    my $log = "log" ~ rand.split(".")[1] ~ ".txt";
    my $conte = qqx/aria2c -d $dir $n $link > $log 2>&1/;
    return check-log($log);
  }
}
