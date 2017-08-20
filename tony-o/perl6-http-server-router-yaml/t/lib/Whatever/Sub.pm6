unit module Whatever::Sub;

sub test($r, $s) is export {
  $s.close('Whatever::Sub::&test');
}

sub yolo($r, $s) is export {
  $s.close('Whatever::Sub::&yolo'); 
}
