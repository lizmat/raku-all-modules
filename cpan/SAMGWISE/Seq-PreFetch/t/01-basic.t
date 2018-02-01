use v6.c;
use Test;

use-ok 'Seq::PreFetch';
use Seq::PreFetch;

is Seq(1..10).&pre-fetch, 1..10,          "All vaules are returned from finite Seq";
is Seq(1..*).&pre-fetch[0..9], 1..10,     "Slice of vaules are returned from infinite Seq";
dies-ok { throwing-seq.&pre-fetch.say },  "Dies when pre-fetched Seq dies";

done-testing;

# Generate a Seq which throws mid sequence
sub throwing-seq( --> Seq) {
  gather {
    take True,
    die "Oh no! something bad happend!";
    take False,
  }
}
