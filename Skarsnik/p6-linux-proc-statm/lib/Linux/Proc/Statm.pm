use NativeCall;

module Linux::Proc::Statm {
  sub getpagesize is native(Str) returns int32 { * };
  my $pagesize = getpagesize();

  sub f($v) {
    return Int($v * $pagesize / 1024);
  }
  sub get-statm($pid = $*PID) is export {
    my %data;
    my $fh = open '/proc/' ~ $pid ~ '/statm';
    my $statm-str = $fh.lines[0];
    my @value = $statm-str.split(/\s/);
    %data<size> = f(@value[0]);
    %data<resident> = f(@value[1]);
    %data<share> = f(@value[2]);
    %data<text> = f(@value[3]);
    %data<lib> = f(@value[4]);
    %data<data> = f(@value[5]);
    %data<dirty> = f(@value[6]);
    return %data;
  }
}
