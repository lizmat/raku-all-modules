Unicode::UTF8-Parser
============

Rakudo's built-in UTF8 parser will wait for a possible combining character
before getc() returns. Using this module, you can read bytes from $*IN and
use this module to get unicode characters

    use Unicode::UTF8-Parser;

    my $stdin = supply { while (my $b = $*IN.read(1)[0]).defined { emit($b) } };
    my $utf8 = parse-utf8-bytes($stdin);

    $utf8.tap({ say "got $_" });

The module exports the sub parse-utf8-bytes, which take a supply as input
and returns a new supply.

If there are Non-UTF8 bytes in the stream, they will be emitted as Int.
You have to implement handling of these yourself ($val ~~ Int).
