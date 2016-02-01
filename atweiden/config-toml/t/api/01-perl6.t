use v6;
use lib 'lib';
use Test;
use Config::TOML;

plan 1;

subtest
{
    # parse toml from string
    my $toml = Q:to/EOF/;
    [server]
    host = "192.168.1.1"
    ports = [ 8001, 8002, 8003 ]
    EOF
    my %toml-from-string = from-toml($toml);

    # parse toml from file
    my $file = 't/data/server.toml';
    my %toml-from-file = from-toml(:$file);

    is(
        %toml-from-string<server><host>,
        '192.168.1.1',
        q:to/EOF/
        ♪ [Is expected value?] - 1 of 5
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ %toml-from-string<server><host> eq '192.168.1.1'
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        %toml-from-string<server><ports>[0],
        8001,
        q:to/EOF/
        ♪ [Is expected value?] - 2 of 5
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ %toml-from-string<server><ports>[0] == 8001
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        %toml-from-string<server><ports>[1],
        8002,
        q:to/EOF/
        ♪ [Is expected value?] - 3 of 5
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ %toml-from-string<server><ports>[1] == 8002
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        %toml-from-string<server><ports>[2],
        8003,
        q:to/EOF/
        ♪ [Is expected value?] - 4 of 5
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ %toml-from-string<server><ports>[2] == 8003
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    # check for equivalence
    is-deeply(
        %toml-from-string,
        %toml-from-file,
        q:to/EOF/
        ♪ [Equivalance] - 5 of 5
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ from-toml($content) == from-toml(:$file)
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# vim: ft=perl6
