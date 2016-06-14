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

  method get($dir, $link) {
  	#works for http(s)/ftp links
    unless $dir { mkdir $dir; }
  	shell("aria2c -d $dir $link > /dev/null");
  }

  method get-limit($dir, $link, $speed) {
    unless $dir { mkdir $dir; }

    my $lim = check($speed);

  	shell("aria2c -d $dir --max-download-limit=$lim $link > /dev/null");
  }

  multi method get-multi($dir, $link1, $link2) {
    unless $dir { mkdir $dir; }
  	shell("aria2c -d $dir $link1 $link2 > /dev/null");
  }

  multi method get-multi($dir, $link1, $link2, $link3) {
    unless $dir { mkdir $dir; }
  	shell("aria2c -d $dir $link1 $link2 $link3 > /dev/null");
  }

  multi method  get-multi($dir, $link1, $link2, $link3, $link4) {
    unless $dir { mkdir $dir; }
  	shell("aria2c -d $dir $link1 $link2 $link3 $link4 > /dev/null");
  }

  method get-concurrent($dir, $link, $num) {
    unless $dir { mkdir $dir; }

    if $num > 5 {
      $num = 5 ;
     }
    my $n = "-x" ~ $num;
  	shell("aria2c -d $dir $n $link > /dev/null");
  }

  method get-magnet($dir, $magnet) {
    unless $dir { mkdir $dir; }
    shell("aria2c -d $dir $magnet > /dev/null");
  }

  method get-torrent($dir, $torrent-file-path) {
    unless $dir { mkdir $dir; }
    shell("aria2c -d $dir $torrent-file-path > /dev/null");
  }

  method get-torrent-limit($dir, $torrent-file-path, $up-limit, $down-limit) {
    unless $dir { mkdir $dir; }

    my $uplim = check($up-limit);
    my $downlim = check($down-limit);

    shell("aria2c -d $dir -u $uplim --max-download-limit=$downlim $torrent-file-path > /dev/null");
  }

  method get-metalink($dir, $metalink) {
    unless $dir { mkdir $dir; }
    shell("aria2c -d $dir $metalink > /dev/null");
  }

  method get-fromfile($dir, $file-path) {
    unless $dir { mkdir $dir; }
  	shell("aria2c -i $file-path > /dev/null");
  }
}
