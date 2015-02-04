class Flower::TAL::TALES::List;

has $.flower is rw;
has $.tales  is rw;

has %.handlers =
  'group'     => 'list_group',
  'sort'      => 'list_sort',
  'reverse'   => 'list_reverse',
  'limit'     => 'list_limit',
  'shuffle'   => 'list_pick',
  'pick'      => 'list_pick';

method list_sort ($query, *%opts) {
  my $array = $.tales.query($query);
  if $array ~~ Array {
    my @newarray = $array.sort;
    return @newarray;
  }
}

method list_group ($query, *%opts) {
  my ($array, $num) = $.tales.get-args(:query({1=>1}), $query, 1);
  if $array ~~ Array {
    my @nest = ([]);
    my $level = 0;
    loop (my $i=0; $i < $array.elems; $i++) {
      if $level > @nest.end {
        @nest.push: [];
      }
      @nest[$level].push: $array[$i];
      if ($i+1) % $num == 0 {
        $level++;
      }
    }
    return @nest;
  }
}

method list_limit ($query, *%opts) {
  my ($array, $num) = $.tales.get-args(:query({1=>1}), $query, 1);
  if $array ~~ Array {
    my $count = $num - 1;
    my @return = $array[0..$count];
    return @return;
  }
}

method list_pick ($query, *%opts) {
  my ($array, $num) = $.tales.get-args(:query({1=>1}), $query, *);
  if $array ~~ Array {
    my @return = $array.pick($num);
    return @return;
  }
}

method list_reverse ($query, *%opts) {
  my $array = $.tales.query($query);
  if $array ~~ Array {
    my @return = $array.reverse;
    return @return;
  }
}

