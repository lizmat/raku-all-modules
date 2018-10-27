use v6;
unit class Statistics::LinearRegression;

sub prefix:<Σ> { [+]($^a);}
sub Σ(@a) { [+](@a); }

sub calc-slope(@x, @y) is export(:ALL) {
    my \N = +@x;
    my $n = N * Σ(@x Z* @y) - Σ@x*Σ@y;
    my $d = N * Σ@x.map(*²) - (Σ@x)²;
    $n/$d;
}

sub calc-intercept(@x, @y, $slope) is export(:ALL) {
    (Σ@y - $slope * Σ@x) / @x;
}    

sub get-parameters(@x, @y) is export(:ALL) {
    my $slope = calc-slope(@x,@y);
    my $intercept = calc-intercept(@x,@y,$slope);
    return ($slope, $intercept);
}

sub value-at($x, $slope, $intercept) is export(:ALL) {
    $x*$slope + $intercept;
}

class LR is export {
    has $.slope;
    has $.intercept;

    multi method new(@x, @y) {
        my ($slope, $intercept) = get-parameters(@x,@y);
        self.bless(:$slope, :$intercept);
    }

    multi method new($slope, $intercept) {
        self.bless(:$slope, :$intercept);
    }

    method get-parameters() {
        ($.slope, $.intercept);
    }

    method at($x) {
        value-at($x, $.slope, $.intercept);
    }

}
=begin pod

=head1 NAME

Statistics::LinearRegression - simple linear regression

=head1 SYNOPSIS

Gather some data

  my @arguments = 1,2,3;
  my @values = 3,2,1;

Build model and predict value for some x using object

  use Statistics::LinearRegression;
  my $x = 15;
  my $y = my LR.new(@arguments, @values).at($x);

If you prefer bare functions, use :ALL

  use Statistics::LinearRegression :ALL;
  my ($slope, $intercept) = get-parameters(@arguments, @values);
  my $x = 15;
  my $y = value-at($x, $slope, $intercept);


=head1 DESCRIPTION

LinearRegression finds slope and intercept parameters of linear function by minimizing mean square error.

Value at y is calculated using C<y = slope × x + intercept>

=head1 TODO

=item R^2 and p-value calculation 
=item support for other objective functions

=head1 CHANGES

=item 1.1.0 LR class exported by default, bare subroutines need :ALL

=head1 AUTHOR

Paweł Szulc <pawel_szulc@onet.pl>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 Paweł Szulc

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
