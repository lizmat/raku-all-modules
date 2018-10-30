use v6;

unit module FileSystem::Capacity::VolumesInfo;

sub volumes-info ( Bool :$human = False ) is export {
  my %ret;  
  
  given $*KERNEL {
    when /linux/  { %ret = linux() }
    when /win32/  { %ret = win32() }
    when /darwin/ { %ret = macos() }
  }
  
  if $human {
    
    my $scale = 1024;

    for %ret.values -> $sizes {
      for $sizes{'size', 'used', 'free'} -> $size is rw {
        $size = byte-to-human($size, $scale);
      }
    }
  }

  return %ret;
}

sub linux ( ) {
  my @df-output = ((run 'df', '-k', :out).out.slurp-rest).lines;
  @df-output.shift;

  return gather for @df-output {
    my @line = $_.words;

    take @line[5] => {
      'size'  => @line[1].Int * 1024,
      'used'  => @line[2].Int * 1024,
      'used%' => @line[4],
      'free'  => @line[3].Int * 1024
    };
  }
}

sub win32 ( ) {
  my @wmic-output = ((shell "wmic /node:'%COMPUTERNAME%' LogicalDisk Where DriveType='3' Get DeviceID,Size,FreeSpace", :out).out.slurp-rest).lines;
  @wmic-output.shift;

  return gather for @wmic-output {
    next unless $_;
    my @line = $_.words;

    my $size = @line[2].Int;
    my $free = @line[1].Int;
    my $used = ($size - $free);
    my $used-percent = (($used * 100) / $size).Int ~ "%";

    take @line[0] => {
      'size'  => $size,
      'used'  => $used,
      'used%' => $used-percent,
      'free'  => $free
    };
  }
}

sub macos ( ) {

  # get df output using 1024 bytes blocks and without inode stats
  my @df-output = run('df', '-k', '-P', :out).out.lines;
  
  # parse header to find position of each column
  my $header = @df-output.shift ~~ /^
      'Filesystem'
      \s+
      $<size>='1024-blocks'
      \s+
      $<used>='Used'
      \s+
      $<free>='Available'
      \s+
      $<used%>='Capacity'
      \s+
      $<location>='Mounted on'
  $/ or fail 'Cannot parse df output header.';
  
  # extract data from each column according to its alignment
  return gather for @df-output {
    my $volume = $_ ~~ /
        $<size>=\d+ <.at($header<size>.to)>
        \s+
        $<used>=\d+ <.at($header<used>.to)>
        \s+
        $<free>=\d+ <.at($header<free>.to)>
        \s+
        <.at($header<used%>.from)> \s* $<used%>=(\d+ '%') \s* <.at($header<used%>.to)>
        \s+
        <.at($header<location>.from)> $<location>=(.*)
    $/ or fail 'Cannot parse df output volume.';
    
    take $volume{'location'} => {
      'size'  => $volume{'size'}.Int * 1024,
      'used'  => $volume{'used'}.Int * 1024,
      'used%' => $volume{'used%'}.Str,
      'free'  => $volume{'free'}.Int * 1024
    };
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
