use Grid::Util;

unit role Grid[:$columns];
  
has Int $!columns;
has Int $!rows;

submethod BUILD( ) is hidden-from-backtrace {

  $!columns = $columns // self.elems;
  
  die "Can't have grid of {$!columns} columns" unless $!columns;
  
  $!rows    = self.elems div $!columns;
  
  die "Can't have grid of {self.elems} elements with {$!columns} columns"
    unless self.elems == $!columns * $!rows;

}


multi method flip ( Grid:D: Int:D :$horizontal! --> Grid:D ) {

  self = self.rotor( $!columns ).map( *.reverse ).flat;

}

multi method flip ( Grid:D: Int:D :$vertical! --> Grid:D ) {

  self = self.rotor( $!columns ).reverse.flat;

}

multi method flip ( Grid:D: Int:D :$diagonal! --> Grid:D ) {

  return self unless self.is-square;

  self = self[ diagonal self.keys ];

}

multi method flip ( Grid:D: Int:D :$antidiagonal! --> Grid:D ) {

  return self unless self.is-square;

  self = self[ antidiagonal self.keys ];

}

multi method flip ( Grid:D: :@horizontal! --> Grid:D ) {
  
  my @subgrid := self!subgrid( @horizontal );

  return self unless @subgrid;

  
  self[ @horizontal ] = self[ @subgrid.flip: :horizontal ];

  return self;
 
}

multi method flip ( Grid:D: :@vertical! --> Grid:D ) {
  
  my @subgrid := self!subgrid( @vertical );

  return self unless @subgrid;

  self[ @vertical ] = self[ @subgrid.flip: :vertical ];

  self;

}

multi method flip ( Grid:D: :@diagonal! --> Grid:D ) {
  
  my @subgrid := self!subgrid( @diagonal, :square );

  return self unless @subgrid;

  self[ @diagonal ] = self[ @subgrid.flip: :diagonal ];

  self;

}

multi method flip ( Grid:D: :@antidiagonal! --> Grid:D ) {
  
  my @subgrid := self!subgrid( @antidiagonal, :square );

  return self unless @subgrid;

  self[ @antidiagonal ] = self[ @subgrid.flip: :antidiagonal ];

  self;

}


multi method rotate ( Grid:D:  Int:D :$left! --> Grid:D ) {

  self = flat [Z] ([Z] self.rotor($!columns)).list.rotate($left);
  
}

multi method rotate ( Grid:D:  Int:D :$right! --> Grid:D ) {

  self = flat [Z] ([Z] self.rotor($!columns)).list.rotate(- $right);
  
}

multi method rotate ( Grid:D:  Int:D :$up! --> Grid:D ) {

  self = flat self.rotor($!columns).list.rotate($up);
  
}

multi method rotate ( Grid:D:  Int:D :$down! --> Grid:D ) {

  self = flat self.rotor($!columns).list.rotate(- $down);
  
}

multi method rotate ( Grid:D: Int:D :$clockwise! --> Grid:D ) {
  
  self.transpose.flip :horizontal;

}

multi method rotate ( Grid:D: Int:D :$anticlockwise! --> Grid:D ) {

  self.transpose.flip :vertical;

}

multi method rotate ( Grid:D: :@clockwise! --> Grid:D ) {

  my @subgrid := self!subgrid( @clockwise, :square );

  return self unless @subgrid;

  self[ @clockwise ] = self[ @subgrid.rotate: :clockwise ];

  self;

}

multi method rotate ( Grid:D: :@anticlockwise! --> Grid:D ) {

my @subgrid := self!subgrid( @anticlockwise, :square );

  return self unless @subgrid;

  self[ @anticlockwise ] = self[ @subgrid.rotate: :anticlockwise ];

  self;

}


multi method transpose ( Grid:D: --> Grid:D ) {

   self = flat [Z] self.rotor( $!columns );

   ($!columns, $!rows) .= reverse; 

   self;

}

multi method transpose ( Grid:D: :@indices! --> Grid:D ) {
  
  my @subgrid := self!subgrid( @indices, :square );

  return self unless @subgrid;

  self[ @indices ] = self[ @subgrid.transpose ];

  self;

}


multi method append ( Grid:D: :@row! --> Grid:D ) {

  return self unless self!check-row( :@row );

  self = self.append(@row);

  $!rows += 1;

  self;
  
}

multi method append ( Grid:D: :@column! --> Grid:D ) {

  return self unless self!check-column( :@column );
  
  self = flat self.rotor($!columns) Z @column;

  $!columns += 1;

  self;

}


multi method prepend ( Grid:D: :@row! --> Grid:D ) {

  return self unless self!check-row( :@row );

  self = self.prepend(@row);
  
  $!rows += 1;

  self;

}

multi method prepend ( Grid:D: :@column! --> Grid:D ) {

  return self unless self!check-column( :@column );
  
  self = flat @column Z self.rotor($!columns);

  $!columns += 1;

  self;

}

multi method pop ( Grid:D: --> Grid:D ) {

  note 'Please provide `:$rows` or `:$columns`';

  self;

}

multi method pop ( Grid:D:  Int :$rows! --> Grid:D ) {

  self = flat self.rotor($!columns).head($!rows - $rows);

  $!rows -= $rows;

  self;

}

multi method pop ( Grid:D:  Int :$columns! --> Grid:D ) {

  self = flat [Z] ([Z] self.rotor($!columns)).head($!columns - $columns);

  $!columns -= $columns;

  self;
  
}

multi method shift ( Grid:D: --> Grid:D ) {

  note 'Please provide `:$rows` or `:$columns`';

  self;

}

multi method shift ( Grid:D:  Int :$rows! --> Grid:D ) {

  self = flat self.rotor($!columns).tail($!rows - $rows);
  
  $!rows -= $rows;

  self;

}

multi method shift ( Grid:D:  Int :$columns! --> Grid:D ) {

  self = flat [Z] ([Z] self.rotor($!columns)).tail($!columns - $columns);
  
  $!columns -= $columns;

  self;

}


method grid () {

  # TODO: indentation
  .put for self.rotor($!columns);
  

}


method has-subgrid( :@indices!, :$square = False --> Bool:D ) {

  my @subgrid := self!subgrid( @indices, :$square );
  
  return True if @subgrid ~~ Grid;

  False;

}

method is-square ( --> Bool:D ) {

  #return False if $!columns < 2;

  $!columns == $!rows;

}

submethod !check-column ( :@column --> Bool:D ) {

  return True if @column.elems == $!rows;

  note "Column check failed, must have {$!rows} elements.";

  False;

}

submethod !check-row ( :@row --> Bool:D ) {

  return True if @row.elems == $!columns;

  note "Row check failed, must have {$!columns} elements.";

  False;

}

submethod !subgrid( @indices, :$square = False ) {

  @indices .= sort.unique;
    
  die "[{@indices}] is not subgrid of {self.VAR.name}"
    if @indices.tail > self.end;
  
  #my $columns = (@subgrid Xmod $!columns).unique.elems;
  my $columns =  @indices.rotor(2 => -1, :partial).first( -> @a {
    (@a.head.succ != @a.tail) or (not @a.tail mod $!columns)
  }):k + 1;

  # fail  unless [eqv] (@subgrid Xmod $!columns).rotor(@subgrid.columns, :partial);
  die "[{@indices}] is not subgrid of {self.VAR.name}"
    unless @indices.rotor($columns).rotor(2 => -1).map( -> @a {
      (@a.head X+ $!columns) eq @a.tail;
    }).all.so ;


  my @subgrid = @indices;

  @subgrid does Grid[:$columns];

  $square and die "[{@indices}] is not square subgrid of {self.VAR.name}" unless @subgrid.is-square;

  return @subgrid;

  CATCH {

    note .message;

    return Array;

  }

}

