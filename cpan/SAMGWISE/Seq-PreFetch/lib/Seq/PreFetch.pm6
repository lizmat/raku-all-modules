use v6.c;
unit class Seq::PreFetch:ver<0.1.0>;

=begin pod

=head1 NAME

Seq::PreFetch - Asynchronously pre-fetch the next item of a Seq

=head1 SYNOPSIS

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

=head1 DESCRIPTION

Seq::PreFetch asynchronously pre-fetches the next item of a Seq before you pull from the Seq.
It provides the sub pre-fetch which wraps a Seq with a pre-fetching Seq.

This pattern allows you to consume one value from a Seq and begin concurrently calculating the next value of a Seq ready for the next time you need a value.
Time efficiency gains can be made for operations where the time cost of a consuming loop is greater than the cost of starting a thread to pre-fetch.

As demonstrated in the synopsis example, The two operations do not block so the longer sleep in the loop defines the duration after the first iteration.

=head1 AUTHOR

Sam Gillespie <samgwise@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2017 Sam Gillespie

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

sub pre-fetch(Seq:D $s, --> Seq) is export {
  my Promise $next;
  gather for 0..* -> $n {
    if $next.defined {
      my $current = await $next;
      $next = start { $s[$n] };
      last if $current ~~ Any:U;
      take $current;
    }
    else {
      # Start condition
      $next = start { $s[$n] };
    }
  }
}
