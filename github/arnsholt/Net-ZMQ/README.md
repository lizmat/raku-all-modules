# Net::ZMQ

Net::ZMQ is a Perl 6 library that may be used to interact with ZeroMQ
library.

```
use Net::ZMQ4;            # Your main import
use Net::ZMQ4::Constants; # Basic constants

my Net::ZMQ4::Context $ctx .= new;

my Net::ZMQ4::Socket $Rize .= new($ctx, ZMQ_PULL);
$Rize.bind("tcp://127.0.0.1:2910");
my Net::ZMQ4::Socket $Sharo .= new($ctx, ZMQ_PUSH);
$Sharo.connect("tcp://127.0.0.1:2910");

# Single message
$Sharo.send('Kuru Kuru');
# Splitted message
$Sharo.sendmore('Cats', 'Dogs', 'Rabbits');

my $msg = $Rize.receive; # Pure ZMQ message
say $msg.data;           # bytes
say $msg.data-str;       # 'Kuru Kuru'
$msg.close;              # Don't forget to close your messages!

# Multi-receive
loop {
    my $msg = $Rize.receive(0); # Can take flags as arguments, 0 is default
    say $msg.data-str;
    $msg.close;
    unless $Rize.getopt(ZMQ_RCVMORE) == 1 {
        last; # If there are no pieces
    }
}
# Says:
# Cats
# Dogs
# Rabbits
```

# Supported version

Main supported ZMQ version is 4.1. Support of 4.2 is planned.

# Issues

If you noticed a bug, have a desire to see some feature implemented,
feel free to open a ticket on github's
[issues](https://github.com/arnsholt/Net-ZMQ/issues) page of the
project.

# Authors

The library was written by Arne
Skjærholt([arnsholt](https://github.com/arnsholt) on github) with a
help of many others(see
[Contributors](https://github.com/arnsholt/Net-ZMQ/graphs/contributors)
page).

[Altai-man](https://github.com/Altai-man) made small cosmetic changes
too.

# Contributing

The project is still relatively unstable and thus wants some love. :)
All new issues and pull requests are welcome.

Efforts may be spend on:

* Want to support a legacy version? Write a compatibility layer for
  the version you want as, for example, ZMQX::Compat, where `X` can be
  desired version.
* If you feel like a strong mage, you can try your luck with improving
  library's stability. Catch segfaults, fix memory leaks - any
  improvements in this difficult field will be greatly appreciated.
* Want to help project while writing Perl 6? Contribute examples!
* Spotted a typo in this README? Want to write more documentation?
  Feel free to pull request additional docs!
