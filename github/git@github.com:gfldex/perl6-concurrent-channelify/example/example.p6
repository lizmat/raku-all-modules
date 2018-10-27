use v6;

use Concurrent::Channelify;

my \l1 = (10_000_000..10_050_000).grep({.is-prime});

for my $c := channelify(l1) {
    $c.channel.close if $_ > 10_010_000;
    say $_
}

my \l2 = <a b c>;

for l2⇒ {
    say $_
}
