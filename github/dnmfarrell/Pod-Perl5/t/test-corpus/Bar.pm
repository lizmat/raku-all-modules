package Foo::Bar;

use strict;
use warnings;

=head1 NAME

Foo::Bar - Not your ordinary bear!

=head1 SYNOPSIS

  use Foo::Bar;
  my $foo = Foo::Bar->new->bar;

=head1 METHODS

=head2 new

Returns a new C<Foo::Bar>.

=cut

sub new { bless {}, shift }

=head2 bar

Method to C<bar> a foo.

=cut

sub bar { return $_[0] }

=head1 AUTHOR

David Farrell

=head1 LICENSE

See LICENSE file

=cut

1;
