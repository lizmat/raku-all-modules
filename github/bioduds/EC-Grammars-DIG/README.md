EC-Grammars-DIG
===============

EC::Grammars::DIG is a module that provides a very easy and clear way to parse the dig command.

It is part of the project HON, a blockchain that is being written in Perl6.

Main features of this module
- run dig command and receive main results parsed
- GNU Licensed - Software Livre

This module performs generic parsing on rules and tokens.

Contents
========

Base Grammar
------------
- `EC::Grammars::DIG`  - Digs into dig with url

Parser Actions
--------------
`EC::Grammars::DIG` will provide important information parsed like the IPs, the urls,
used mainly for seeded out digs for P2P networks. A simple usage would be:

    use EC::Grammars::DIG;
    my $proc = run 'dig', URL_YOU_WANT_TO_DIG_HERE, :out, :err;
    with $proc.err { say "Error running dig"; die; }
    my $output = $proc.out.slurp: :close;
    my $dig = EC::Grammars::DIG.new.parse( $output, :actions( EC:Grammars::DIG::Actions.new ) );
    say $dig<DATE>; ## you may here query which ever tokens or rules desired
    ## TO ITERATE USE, FOR INSTANCE:
    for $dig<ANSWER> -> $answers {
    say $answers<IP>; ## for instance

## Actions Options

- **`:lax`** Pass back, don't drop, quantities with unknown dimensions.

Installation
------------

With zef: 

    zef install EC::Grammars::DIG

You'll first need to download and build Rakudo Star or better (http://rakudo.org/downloads/star/ - don't forget the final `make install`):

Ensure that `perl6` and `panda` are available on your path, e.g. :

    % export PATH=~/src/rakudo-star-2015.07/install/bin:$PATH

You can then use `panda` to test and install `CSS::Grammar`:

    % panda install EC::Grammars::DIG

To try parsing some content:

    % perl6 -MCSS::EC::Grammars::DIG -e"say EC::Grammars::DIG.parse( run 'dig', 'YOUR_URL_TO_DIG')"

See Also
--------
- HON Post of Module: https://steemit.com/blockchain/@bitworkers/perl6-hon-decentralized-justice-deep-study-of-blockchain-code-this-effort-resulted-in-this-module 
- HON Proposition: https://steemit.com/blockchain/@bitworkers/escrowchain-an-idea-to-build-an-escrow-blockchain-with-arbitration-currency

References
----------
This module been built from the W3C CSS Specifications. In particular:

- Module Building - https://docs.perl6.org/language/modules
