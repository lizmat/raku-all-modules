use v6;

=begin pod

=head1 NAME

Algorithm::Genetic::Crossoverable - A role providing crossover behaviour of attribute values.

=begin code
unit role Algorithm::Genetic::Crossoverable;
=end code

=head1 METHODS

=end pod

unit role Algorithm::Genetic::Crossoverable;

method crossover(Algorithm::Genetic::Crossoverable $other, Rat $ratio) returns List
#= Crossover between this and another Crossoverable object.
#= Use the ratio to manage where the crossover point will be.
#= standard attribute types will be swapped by value and Arrays will be swapped recursively.
#= Note that this process effectively duck types attributes so best to only crossover between instances of the same class!
{
  my $a = self.clone;
  my $b = $other.clone;

  for self.^attributes[0 .. floor(self.^attributes.end * $ratio)] -> $attr {
    given $attr.type {
      when Array {
        self!crossover-nested($attr.get_value(self), $attr.get_value($other), $ratio)
      }
      default {
        $attr.set_value( $a, $attr.get_value($other) );
        $attr.set_value( $b, $attr.get_value(self) );
      }
    }
  }

  $a, $b;
}

# implements recursive array crossover
method !crossover-array(Array $a, Array $b, Rat $ratio) {
  for $a[0 .. floor($a.end * $ratio)].keys -> $i {
    $a[$i], $b[$i] = $b[$i], $a[$i]
  }
}
