unit module Flow::Utils::Cursor;

$_ = qx[stty -a </dev/tty 2>&1];


my $rows = +m/<(\d+)> ' rows'/;
my $cols = +m/<(\d+)> ' columns'/;

my %moves = 
  left  => 'tput cub1',
  right => 'tput cuf1',
  up    => 'tput cuu1',
  down  => 'tput cud1',
  home  => 'tput cr',
  tl    => 'tput home',
  eol   => "tput hpa $cols",
  br    => "tput cup $rows $cols";


sub left is export { qqx[%moves<left>]; }
sub right is export { qqx[%moves<right>]; }
sub up is export { qqx[%moves<up>]; }
sub down is export { qqx[%moves<down>]; }
sub home is export { qqx[%moves<home>]; }
sub tl is export { qqx[%moves<tl>]; }
sub eol is export { qqx[%moves<eol>]; }
sub br is export { qqx[%moves<br>]; }
