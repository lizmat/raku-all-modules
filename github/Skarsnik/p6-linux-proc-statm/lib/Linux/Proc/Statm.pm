use NativeCall;

module Linux::Proc::Statm {
  sub getpagesize is native(Str) returns int32 { * };
  my $pagesize = getpagesize();
  my %convert = (b => 1, k => 1024, m => 1024 * 1024);

  sub make-human ($var, $unit) {
    return $var.flip.comb(/.**1..3/).join('.').flip ~ ($unit eq 'b' ?? ""  !! " {$unit}B");
  }
  sub f($v, $unit) {
    return Int($v * $pagesize / %convert{$unit});
  }
  sub get-statm($pid = $*PID, :$unit = 'k') is export {
    die unless defined %convert{$unit};
    my %data;
    my $fh = open '/proc/' ~ $pid ~ '/statm';
    my $statm-str = $fh.lines[0];
    my @value = $statm-str.split(/\s/);
    %data<size> = f(@value[0], $unit);
    %data<resident> = f(@value[1], $unit);
    %data<share> = f(@value[2], $unit);
    %data<text> = f(@value[3], $unit);
    %data<lib> = f(@value[4], $unit);
    %data<data> = f(@value[5], $unit);
    %data<dirty> = f(@value[6], $unit);
    $fh.close;
    return %data;
  }

  sub get-statm-human($pid = $*PID, :$unit = 'k') is export {
    die unless defined %convert{$unit};
    my %data = get-statm(:unit($unit));
    my %toret;
    for %data.kv -> $k, $v {
      %toret{$k} = make-human($v, $unit);
    }
    return %toret;
  }
}
