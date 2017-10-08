use Test;
plan 1;
use URI::Escape;
my $uri = "file:///space/pub/music/mp3/Musopen%20DVD/Brahms%20-%20Symphony%20No%201%20in%20C%20Major/Symphony%20No.%201%20in%20C%20Minor,%20Op.%2068%20-%20IV.%20Adagio%20-%20Piu%CC%80%20andante%20-%20Allegro%20non%20troppo,%20ma%20con%20brio.mp3";
my $expected = "t/expected.txt".IO.slurp(:enc('utf8-c8')).chomp;
is uri-unescape($uri, :enc('utf8-c8')), $expected, "uri-unescape works with encoding utf8-c8";