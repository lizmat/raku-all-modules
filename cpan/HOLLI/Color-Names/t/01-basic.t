use v6;

use Test;


lives-ok {
  use Color::Names::X11 :colors;
  my $colors = Color::Names::X11.color-data;
  is-deeply $colors, COLORS, "Bring your canvas bags";
}, "X11";

lives-ok {
  use Color::Names::XKCD :colors;
  my $colors = Color::Names::XKCD.color-data;
  is-deeply $colors, COLORS, "to the supermarket";
}, "XKCD";

lives-ok {
  use Color::Names::CSS3 :colors;
    my $colors = Color::Names::CSS3.color-data;
    is-deeply $colors, COLORS, "-- Tim Minchin";
}, "CSS3";

lives-ok {
  use Color::Names;
}, "Color::Names";
done-testing;
