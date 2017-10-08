use v6;
unit class Graffiks::Objloader;

use NativeCall;
use Graffiks::Object;

sub gfks_load_obj(int32, Str) returns Graffiks::Object is native("libgraffiks") { * }

method load ($filepath, :$forward, :$deferred) {
  my $flags = 0;

  if ($forward) {
    $flags +|= 0x02;
  }

  if ($deferred) {
    $flags +|= 0x01;
  }

  return gfks_load_obj($flags,$filepath);
}
