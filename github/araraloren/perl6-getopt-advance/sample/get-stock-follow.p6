#!/usr/bin/env perl6

use JSON::Fast;
use Inline::Perl5;
use Getopt::Advance;
use Getopt::Advance::Helper;
use WWW::Mechanize:from<Perl5>;

constant SNOWBALL = 'https://www.xueqiu.com/S';
constant FOLLOW   = 'https://www.xueqiu.com/recommend/pofriends.json?type=1&code=%s&start=0&count=14';
constant SHANGHAI = 'SH';
constant SHENZHEN = 'SZ';

# Getopt::Advance::Utils::Debug::setLevel(0);

getopt do given OptionSet.new {
    .append(
        "h|help=b"      => 'print help message',
        "v|version=b"   => 'print version message',
        "d|debug=b"     => 'print debug message',
    );
    .push(
        'prefix=s',
        'set the prefix of the stack information page ',
        value => SNOWBALL,
    );
    .insert-pos(
        'id',
        'get the stock follow number according id',
        * - 1,
        sub ($os, $arg) {
            note "Got a value $arg" if $os<d>;
            given $arg.value {
                if $_ !~~ /^\d+$/ {
                    note "Not a stock id" if $os<d>;
                    return False;
                }
                note "Get stock follow number for " ~ .Str if $os<d>;
                getstockFollow .Str;
                True;
            }
        },
    );
    .insert-pos(
        'file',
        'read stock id from file, get all the follow number',
        * - 1,
        sub ($os, $arg) {
            note "Got a value $arg" if $os<d>;
            given $arg.value.IO {
                if ! .e || ! .f || ! .r {
                    note "Got file can read!" if $os<d>;
                    return False;
                }
                note "Read file line by line" if $os<d>;
                for .lines -> $line {
                    getstockFollow $line.trim;
                }
                True;
            }
        },
    );
    .self;
}, :autohv;

sub getstockFollow($id) {
    my $realid = (getstockExchange $id) ~ $id;
    my $www = WWW::Mechanize.new(agent => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:59.0) Gecko/20100101 Firefox/59.0');
    my $resp = $www.get(getstockURL $id);

    $resp = $www.get(sprintf FOLLOW, $realid);
    if $resp.decoded_content.decode("UTF8") ~~ /^'{"totalcount":' \s* (\d+)/ {
        say $0.Str;
    } else {
        say "NA";
    }
}

sub getstockURL($id) {
    return SNOWBALL ~ '/' ~ (getstockExchange $id) ~ $id;
}

sub getstockExchange($id) {
    given $id {
        if .starts-with('60') {
            return SHANGHAI;
        }
        if .starts-with('00') {
            return SHENZHEN;
        }
        if .starts-with('30') {
            return SHENZHEN;
        }
    }
}
