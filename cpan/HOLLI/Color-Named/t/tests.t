use Test;

plan 6;

lives-ok {
  use Color::Named <X11>;
  my $aqua = Color::Named.new( :name("Aqua") );
  ok $aqua.defined;
  ok $aqua.r == 0;
  ok $aqua.g == 255;
  ok $aqua.b == 255;

  my $color = Color.new( "#00FFFF" );
  ok $color.defined;
}

done-testing;
