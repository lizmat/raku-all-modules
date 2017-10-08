use v6;
use Test;
use lib 'lib';
use TagLibC::Wrapper;

my $dir = IO::Path.new($?FILE).dirname;

my $track = TagLibC::Wrapper.new($dir ~ "/test.mp3");
my %testVars =
  artist => "Sinister Souls",
  title  => "3D",
  album  => "Edited & Forgotten",
  year   => 2014,
  genre  => "",
  track  => 3;

plan (%testVars.end + 1 + 3);

ok (defined $track), "Get defined return";

for %testVars.kv -> $key, $value {
  my $got = $track."$key"();
  ok $got eq $value, "Can read $key, expected \"$value\", got \"$got\"";
}

$track.destroy;
dies-ok {
  $track.artist;
}, "Check if dies by trying to get tag after destroy";

dies-ok {
  TagLibC::Wrapper.new("/nonexistentfile");
}, "Check if dies by trying to initialize non-existent file"
