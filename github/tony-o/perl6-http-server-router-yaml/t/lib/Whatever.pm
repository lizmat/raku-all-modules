unit module Whatever;

sub whatever($req, $res) is export {
  $res.close('Whatever::&whatever');
}

sub test($req, $res) is export {
  $res.close('Whatever::&test');
}

# vi:syntax=perl6
