use v6;
module LCS::BV:ver<0.4.0>:auth<wollmers> {

  our sub LCS($a, $b) is export {

    my ($amin, $amax, $bmin, $bmax) = (0, $a.elems - 1, 0, $b.elems - 1);

    while ($amin <= $amax and $bmin <= $bmax and $a[$amin] eqv $b[$bmin]) {
      $amin++;
      $bmin++;
    }
    while ($amin <= $amax and $bmin <= $bmax and $a[$amax] eqv $b[$bmax]) {
      $amax--;
      $bmax--;
    }

    my $positions;
    $positions{$a[$_]} +|= 1 +< $_  for $amin..$amax;

    my $S = +^0;
    my $Vs = [];
    my ($y,$u);

    # outer loop
    for ($bmin..$bmax) -> $j {
      $y = $positions{$b[$j]} // 0;
      $u = $S +& $y;               # [Hyy04a]
      $S = ($S + $u) +| ($S - $u); # [Hyy04a]
      $Vs[$j] = $S;
    }

    # recover alignment [Hyy04b]
    my $i = $amax;
    my $j = $bmax;
    my @lcs;

    while ($i >= $amin && $j >= $bmin) {
      if ($Vs[$j] +& (1 +< $i)) {
        $i--;
      }
      else {
        unless ($j && +^$Vs[$j-1] +& (1 +< $i)) {
           unshift @lcs, [$i,$j];
           $i--;
        }
        $j--;
      }
    }

    return [(
        map({$[$_, $_]}, (0..($bmin-1))),
        @lcs,
        map({$[++$amax, $_]}, (($bmax+1)..@($b)-1)),
    ).flat ];
  }

}

=begin pod

=head1 NAME

LCS::BV - Bit Vector (BV) implementation of the
                 Longest Common Subsequence (LCS) Algorithm

=begin html

<a href="https://travis-ci.org/wollmers/P6-LCS-BV"><img src="https://travis-ci.org/wollmers/P6-LCS-BV.png" alt="P6-LCS-BV"></a>

=end html

=head1 SYNOPSIS

=begin code

  use LCS::BV;

  $lcs = LCS::BV::LCS($a,$b);

=end code

=head1 ABSTRACT

LCS::BV implements the Longest Common Subsequence (LCS) Algorithm and is
more than double as fast (Jan 2016) than Algorithm::Diff::LCSidx().

=head1 DESCRIPTION

This module is a port from the Perl5 module with the same name.

The algorithm used is based on

  H. Hyyroe. A Note on Bit-Parallel Alignment Computation. In
  M. Simanek and J. Holub, editors, Stringology, pages 79-87. Department
  of Computer Science and Engineering, Faculty of Electrical
  Engineering, Czech Technical University, 2004.

=head2 METHODS

=item LCS($a,$b)

Finds a Longest Common Subsequence, taking two arrayrefs as method
arguments. It returns an array reference of corresponding
indices, which are represented by 2-element array refs.


=head1 SEE ALSO

Algorithm::Diff

=head1 AUTHOR

Helmut Wollmersdorfer E<lt>helmut.wollmersdorfer@gmail.comE<gt>

=end pod
