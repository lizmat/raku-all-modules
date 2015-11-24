unit module Terminal::WCWidth;

use Terminal::WCWidth::Tables;

sub bisearch($ucs, @table) {
  my $lower = 0;
  my $upper = @table.elems - 1;
  return False if $ucs < @table[0][0] || $ucs > @table[$upper][1];
  while $upper >= $lower {
    my $mid = ($lower + $upper) +> 1;
    if $ucs > @table[$mid][1] {
      $lower = $mid + 1;
    } elsif $ucs < @table[$mid][0] {
      $upper = $mid - 1;
    } else {
      return True;
    }
  }
  return False;
}

sub wcwidth($ucs) is export {
  return 0 if $ucs ~~ any(0, 0x034F, 0x2028, 0x2029) ||
      0x200B <= $ucs <= 0x200F ||
      0x202A <= $ucs <= 0x202E ||
      0x2060 <= $ucs <= 0x2063;
  return -1 if $ucs < 32 || 0x07f <= $ucs < 0x0A0;
  return 0 if bisearch($ucs, ZERO_WIDTH);
  return 2 if bisearch($ucs, WIDE_EASTASIAN);
  return 1;
}

sub wcswidth($str) is export {
  my $res = 0;
  for $str.NFC {
    my $w = wcwidth($_);
    return -1 if $w < 0;
    $res += $w;
  }
  return $res;
}

=begin pod
=title Terminal::WCWidth

=head1 Name
A Perl 6 port of a Python module
(L<https://github.com/jquast/wcwidth>)

=head1 Synopsis

    sub print-right-aligned($s) {
      print " " x (80 - wcswidth($s));
      say $s;
    }
    print-right-aligned("this is right-aligned");
    print-right-aligned("another right-aligned string")

=head1 Subroutines

=head2 C<wcwidth>

Takes a single I<codepoint> and outputs its width:

    wcwidth(0x3042) # "あ" - returns 2

Returns:

=item C<-1> for a control character
=item C<0> for a character that does not advance the cursor (NULL or combining)
=item C<1> for most characters
=item C<2> for full width characters

=head2 C<wcswidth>

Takes a I<string> and outputs its total width:

    wcswidth("*ウルヰ*") # returns 8 = 2 + 6

Returns -1 if any control characters are found.

Unlike the Python version, this module does not support getting the width of
only the first C<n> characters of a string, as you can use the C<substr>
method.

=head2 Acknowledgements

Thanks to Jeff Quast (jquast), the author of the
Python module, which in turn is based on
the C library by Markus Kuhn.

=end pod
