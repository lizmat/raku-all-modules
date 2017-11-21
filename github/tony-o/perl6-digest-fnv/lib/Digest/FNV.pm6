unit module Digest::FNV1;

my $fnv-prime = {
  32   => 0x1000193,
  64   => 0x100000001B3,
  128  => 0x1000000000000000000013B,
  256  => 0x1000000000000000000000000000000000000000163,
  512  => 0x100000000000000000000000000000000000000000000000000000000000000000000000000000000000157,
  1024 => 0x10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018D,
};
my $fnv-basis = {
  32   => 0x811c9dc5,
  64   => 0xcbf29ce484222325,
  128  => 0x6c62272e07bb014262b821756295c58d,
  256  => 0xdd268dbcaac550362d98c384c4e576ccc8b1536847b6bbb31023b4c8caee0535,
  512  => 0xb86db0b1171f4416dca1e50f309990acac87d059c90000000000000000000d21e948f68a34c192f62ea79bc942dbe7ce182036415f56e34bac982aac4afe9fd9,
  1024 => 0x5f7a76758ecc4d32e56d5a591028b74b29fc4223fdada16c3bf34eda3674da9a21d9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004c6d7eb6e73802734510a555f256cc005ae556bde8cc9c6a93b21aff4b16c71ee90b3,
};
my $fnv-mask  = {
  32   => 0xffffffff,
  64   => 0xffffffffffffffff,
  128  => 0xffffffffffffffffffffffffffffffff,
  256  => 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff,
  512  => 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff,
  1024 => 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff,
};

sub fnv1a($data, :$bits where { $fnv-mask{$_}.defined } = 64) is export {
  return 0 unless $data.^can('ords');
  my @x    = $data.ords;
  my $hash = $fnv-basis{$bits};

  for @x {
    $hash = $hash +^ ($_ +& 0xff);
    $hash = ($hash * $fnv-prime{$bits}) +& $fnv-mask{$bits};
  }
  
  $hash;
}

sub fnv1($data, :$bits where { $fnv-mask{$_}.defined } = 64) is export {
  return 0 unless $data.^can('ords');
  my @x    = $data.ords;
  my $hash = $fnv-basis{$bits};

  for @x {
    $hash = ($hash * $fnv-prime{$bits}) +& $fnv-mask{$bits};
    $hash = $hash +^ ($_ +& 0xff);
  }
  
  $hash;
}

sub fnv0($data, :$bits where { $fnv-mask{$_}.defined } = 64) is export(:DEPRECATED) {
  return 0 unless $data.^can('ords');
  my @x    = $data.ords;
  my $hash = 0;

  for @x {
    $hash = ($hash * $fnv-prime{$bits}) +& $fnv-mask{$bits};
    $hash = $hash +^ ($_ +& 0xff);
  }
  
  $hash;
}
