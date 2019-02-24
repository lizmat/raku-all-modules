unit module Grid::Util;

sub diagonal ( @perfect --> Array ) is export {
  #TODO: check if not perfect square

  my $root = @perfect.sqrt.Int;

  sub diagonaled-index ( Int $index ) { 
    return $index when $index == @perfect.end;
    return $index * $root mod @perfect.end;
  }

  my @diagonaled = @perfect[ @perfect.keys.map: *.&diagonaled-index ];

  @diagonaled;

}



sub antidiagonal ( @perfect --> Array) is export {
  my $root = @perfect.sqrt.Int;

  multi antidiagonal-index ( Int $index ) {
    my $newindex = @perfect.end - $index * $root;

    return $newindex unless $newindex < 0;
    samewith $newindex;
  }

  multi antidiagonal-index (Int $index where * < 0) {
    my $newindex = $index + @perfect.end;
    return $newindex unless $newindex < 0;
    samewith $newindex;
  }


  my @antidiagonaled = @perfect[ @perfect.keys.map: *.&antidiagonal-index ];
  
  @antidiagonaled;

}
