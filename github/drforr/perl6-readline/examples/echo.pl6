#!/usr/bin/env perl6
use v6;
use Readline;

my $readline = Readline.new;
my %history;
while my $response = $readline.readline( "prompt here (<cr> to exit)> " ) {
  if $response ~~ /ding/ {
    $readline.ding;
  }
  elsif $response ~~ /clear/ {
    $readline.clear-history;
  }
  elsif $response ~~ /is \s+ stifled/ {
    say $readline.history-is-stifled ?? "Yes" !! "No";
  }
  elsif $response ~~ /unstifle/ {
    $readline.unstifle-history;
  }
  elsif $response ~~ /stifle/ {
    $readline.stifle-history( 1 );
  }
  elsif $response ~~ /\S/ {
    unless %history{$response} {
      $readline.add-history( $response );
      %history{$response} = 1;
    }
  }
  say "[$response]";
}
