use v6;

unit class WWW::SilverGoldBull::Response;

has $.data = Nil;
has $.error = Nil;

method is-success() {
  return ?$.data && not ?$.error;
}
