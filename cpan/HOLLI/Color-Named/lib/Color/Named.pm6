use v6;

use Color;
use Color::Names;

my %colors;
my @color-sources;

sub EXPORT( *@import-list )
{
  @color-sources = @import-list;
  return {};
}

class Color::Named is Color
{
  has $.name;
  has $.pretty-name;

  multi method new( Str:D :$name )
  {
    %colors = |Color::Names.color-data( @color-sources )
      unless %colors.elems > 0;

    my $color = %colors{ normalize-color-name($name) };

    return self.bless( :$name, :pretty-name($color<name>), :r($color<rgb>[0]), :g($color<rgb>[1]), :b($color<rgb>[2]) )
      if $color ;

    die "Unknown color";
  }

  method Str {
    return $!pretty-name ?? $!pretty-name !! nextsame;
  }

  sub normalize-color-name( Str:D $event-name ) {
    return $event-name.lc.subst( / <-[ a .. z ]> / , "", :g );
  }
}
