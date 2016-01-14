#!/usr/bin/env perl

use strict;
use warnings;
use Acme::Dump::And::Dumper;
use Mojo::DOM;
use Mojo::Util qw/spurt  b64_decode  encode  decode  slurp/;
use Mojo::JSON qw/encode_json/;
use Mojo::UserAgent;
use 5.020;
use experimental 'postderef';

my $dom = Mojo::UserAgent->new
    ->get(b64_decode 'aHR0cDovL3d3dy50aW1lYW5kZGF0ZS5jb20vdGltZS96b25lcy8=')
        ->res->dom;

my @tzs;
for my $tr ( $dom->find('#tz-abb tbody tr')->each ) {
    my $abbr       = $tr->at('td:first-child a')->all_text;
    next if $abbr eq 'UTC';

    my ( $offset ) = $tr->at('td:last-child   ')->all_text =~ /(-?\d+:\d+)/;
    $offset =~ s/:(\d+)// and $offset += $1/60;

    push @tzs, { abbr => $abbr, offset => $offset };
}

my $dump = DnD \@tzs;
$dump =~ s/\A\s*\$VAR1\s+=\s+\[\s*|\s*\];\s*\z//g;
$dump =~ s/\t/  /g;
$dump =~ s/\\x\{([^\}]+)\}/\\x[$1]/g;

spurt encode('utf8', $dump) => 'out.p6';
