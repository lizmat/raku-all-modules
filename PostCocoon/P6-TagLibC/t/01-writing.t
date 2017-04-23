use v6;
use Test;
use lib 'lib';
use TagLibC::Wrapper;

my $dir = IO::Path.new($?FILE).dirname;
my $testfile = $dir ~ "/test.mp3";
my $abusefile = $dir ~ "/abuse.mp3";
IO::Path.new($testfile).copy($abusefile);

my $track = TagLibC::Wrapper.new($abusefile);

my %testVars =
  artist => "Sinister Pain",
  title  => "4D",
  album  => "Edited & Thrown Away",
  year   => 2011,
  genre  => "Drum and Bass",
  track  => 1;


plan ((%testVars.end + 1) * 3 + 1);

for %testVars.kv -> $key, $value {
  lives-ok {
    $track."$key"($value);
  }, "Look if I can set \"$key\" without any problems";
  my $got = $track."$key"();
  ok $got eq $value, "Can read immeditially after write $key, expected \"$value\", got \"$got\"";
}

lives-ok {
  $track.save();
  $track.destroy();
}, "look if I can write a file without problems";

my $track2 = TagLibC::Wrapper.new($abusefile);
for %testVars.kv -> $key, $value {
  my $got = $track2."$key"();
  ok $got eq $value, "Can read $key, expected \"$value\", got \"$got\"";
}
IO::Path.new($abusefile).unlink();
