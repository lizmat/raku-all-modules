use v6;
unit class Algorithm::ZobristHashing;

has Hash $!table;
has $!rand-max;
has Str $!record-separator = '30'.chr;

submethod BUILD(:$!rand-max = 1e9) { }

multi method encode(Str:D $text) returns Int {
    return self.encode($text.split("",:skip-empty));
}

multi method encode(@array is copy) returns Int {
    @array = self!flatten(@array);
    if (@array.elems == 0) {
	return Int;
    }
    
    my Int @rand-array;
    for @array.kv -> $position, $element {
	my Str $key = $position ~ $!record-separator ~ $element;
	if (not $!table{$key}:exists) {
	    $!table{$key} = $!rand-max.rand.Int;
	}
	@rand-array.push($!table{$key});
    }
    return [+^] @rand-array;
}

method get(Int $position, Str $type) returns Int {
    my $key = $position ~ $!record-separator ~ $type;
    if ($!table{$key}:exists) {
	return $!table{$key};
    }
    return ($!table{$key} = $!rand-max.rand.Int);
}

method !flatten(@array)
{
    gather for @array -> $element
    {
	$element ~~ Array ?? take(self!flatten($element)) !! take $element
    }.flat
}

=begin pod

=head1 NAME

Algorithm::ZobristHashing - a hash function for board games

=head1 SYNOPSIS

  use Algorithm::ZobristHashing;

  # the case input is Str
  my $zobrist = Algorithm::ZobristHashing.new();
  my $status = $zobrist.encode("Perl6 is fun");
  my $code = $zobrist.get(0,"P"); # Int value which represents state h(0,"P")
  my $code = $zobrist.get(5," "); # Int value which represents state h(5," ")

  # the case input is Array
  my $zobrist = Algorithm::ZobristHashing.new();
  my $status = $zobrist.encode([["Perl6"],["is"],["fun"]]);
  my $code = $zobrist.get(0,"Perl6"); # Int value which represents state h(0,"Perl6")

=head1 DESCRIPTION

Algorithm::ZobristHashing is a hash function for board games such as chess, GO, GO-MOKU, tic-tac-toe, and so on. 

=head2 CONSTRUCTOR

=head3 new

    my $zobrist = Algorithm::ZobristHashing.new(%options);

=head4 OPTIONS

=item C<<max-rand => $max-rand>>

Sets the upper bound number for generating random number. Default is 1e9.

=head2 METHODS

=head3 encode(Str|Array)

       my $status = $zobrist.encode("abc"); # h(0,"a") xor h(1,"b") xor h(2,"c")
       my $status = $zobrist.encode([["a"],["b"],["c"]]); # h(0,"a") xor h(1,"b") xor h(2,"c")
       my $status = $zobrist.encode([["ab"],["c"]]); # h(0,"ab") xor h(1,"c")

Returns the hash value which represents the status of the input sequence. If the input value is the nested array, it flattens this and handles as a 1-dimensional array. If the input value is empty, it returns the type object Int.

=head3 get(Int $position, Str $type)

       my $status = $zobrist.encode(["abc"]);
       my $code = $zobrist.get(0,"abc"); # in this case $code == $status
       my $new-code = $zobrist.get(0,"perl"); # assigns a new rand value, since h(0,"perl") is not yet encoded

Returns the Int value which represents the state(i.e position-type pair). If it intends to get the state not yet encoded, it assigns a new rand value to the state and returns this new value.

=head1 AUTHOR

okaoka <cookbook_000@yahoo.co.jp>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 okaoka

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

This algorithm is from Zobrist, Albert L. "A new hashing method with application for game playing." ICCA journal 13.2 (1970): 69-73.

=end pod
