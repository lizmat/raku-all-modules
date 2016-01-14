#!/usr/bin/env perl

use strict;
use warnings;
use Mojo::DOM;
use Mojo::Util qw/spurt  b64_decode  encode  decode  slurp/;
use Mojo::JSON qw/encode_json/;
use Mojo::UserAgent;
use 5.020;
use experimental 'postderef';

my $dom = Mojo::DOM->new( decode 'utf8', slurp 'out.html' );

# Mojo::UserAgent->new
    #->get(b64_decode 'aHR0cDovL3RpbWUuaXMvdGltZV96b25lcw==')->res->dom;

my @tzs;
for my $d ( $dom->find('.section')->each ) {
    my $tz = { offset => $d->at('h1')->all_text =~ s/UTC\+?//r };
    $tz->{offset} =~ s/:(\d+)// and $tz->{offset} += $1/60;

    my @countries = Mojo::DOM->new("<zof>$d</zof>")->find('zof > * > div > ul > li ')->each;
    for my $cont_d ( @countries ) {
        my $name = $cont_d->children('a')->first->all_text;
        my @cities = $cont_d->find('li a')->map('all_text')->to_array->@*;
        push $tz->{countries}->@*, +{
            name   => $name,
            cities => \@cities,
        };
    }

    push @tzs, $tz;
}

use Acme::Dump::And::Dumper;
my $dump = DnD \@tzs;
$dump =~ s/\A\s*\$VAR1\s+=\s+\[\s*|\s*\];\s*\z//g;
$dump =~ s/\t/  /g;
$dump =~ s/(\s*)[\]]/,$1]/g;
$dump =~ s/\\x\{([^\}]+)\}/\\x[$1]/g;

spurt encode('utf8', $dump) => 'out.p6';

# spurt encode_json(\@tzs) => '_dev/tzs.json';

__END__

<div class="section even">
    <h1>UTC-9</h1>
    <div class="cloud scloud w90">
        <ul>
            <li id="c10">
                <a class="s1 country multizone bold" href="French_Polynesia">French Polynesia</a>
                <ul>
                    <li><a class="s4" href="Rikitea">Rikitea</a></li>
                </ul>
            </li>
            <li id="c9">
                < class="s2 country multizone bold" href="United_States">United States</a>
                <ul>
                    <li><a class="s3 multizone" href="Alaska">Alaska</a></li>
                    <li><a class="s5" href="Anchorage">Anchorage</a></li>
                </ul>
            </li>
        </ul>
    </div>
</div>
