use v6;

unit module Filesystem::Capacity::DirSize;

sub dirsize ( Str:D $dirpath, :$human = False ) is export {
  
  return "No valid path directory" unless $dirpath.IO.e;

  my $ret;
  my $scale;
  
  given $*KERNEL {
    
    when /linux/  { 
    	$ret = linux($dirpath); 
      $scale = 1000;
    	if $human { $ret = byte-to-human($ret, $scale); }
  	}   

    when /win32/  { 
      $ret = win32($dirpath); 
      $scale = 1024;
      if $human { $ret = byte-to-human($ret, $scale); }      
    }  
  }  

  return $ret;
}

sub linux ( Str:D $dirpath ) {

  my @du-output = (run 'du', '-sb', $dirpath, :out).out.lines;
  
  my @words = @du-output[0].words;

  return @words[0].Int;
  
}

sub win32 ( Str:D $dirpath ) {

  return "Directory provided not exists" unless $dirpath.IO.e;

  my $totalsize = 0;
  recursivedir $dirpath;  
  return $totalsize;

  sub recursivedir ($dirpath) {

    for dir $dirpath -> $item {
      CATCH { when X::IO::Dir { next; } }
      if $item.d { recursivedir $item; }
      if $item.f { $totalsize += $item.s; }   
    }
  }
}

sub byte-to-human( Int:D $bytes, Int:D $scale ) {
  if $bytes.chars > 27 { return "Fail! Must be < 27 positions"; }

  my $i = 0;
  my $b = $bytes;

  my @scale = <Bytes KB MB GB TB PB EB ZB YB>;

  while $b > $scale {
    $b = ($b / $scale);
    $i++;
  }

  return $b.round(0.01) ~ " " ~ @scale[$i];
}