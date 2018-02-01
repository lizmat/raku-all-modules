#! /usr/bin/env perl6
use v6;
use Seq::PreFetch;

sub slow-and-lazy( --> Seq) {
  gather for 1..* {
    # a time expensive option... like sleep
    sleep 0.5;
    .take
  }
}

my $moment = now;
for slow-and-lazy.&pre-fetch {
  .say;
  say "Delta: { now - $moment }";
  $moment = now;
  sleep 1;
}
