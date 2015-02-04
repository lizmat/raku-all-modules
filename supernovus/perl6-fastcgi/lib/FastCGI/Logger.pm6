use v6;

class FastCGI::Logger;

## TODO: pull this out of FastCGI and make it its own library.

has $.name;
has $.duration = True;
has $.string = False;

has $!lasttime;

method say ($message)
{
  my $time = now;
  my $timeStr; 
  if $.string
  {
    $timeStr = DateTime.new($time).Str;
  }
  else
  {
    $timeStr = $time.Num.fmt('%.4f');
  }
  my $log = '';
  if $.name
  {
    $log ~= "($.name) ";
  }
  $log ~= "[$timeStr] $message";
  if $.duration && $!lasttime {
    my $duration = $time - $!lasttime;
    $log ~= " <{$duration.Num.fmt('%.4f')}>";
  }
  $*ERR.say: $log;
  $!lasttime = $time;
}

