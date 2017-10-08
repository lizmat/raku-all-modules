#!/usr/bin/env perl

use strict;
use warnings;
use Mojo::SQLite;
use Mojo::UserAgent;

my $sql = Mojo::SQLite->new('sqlite:factoids.db');

for ( @{ get_facts() } ) {
    $sql->db->query(
        'INSERT INTO factoids (fact, def) VALUES(?, ?)',
        @$_{qw/fact def/},
    );
}

sub get_facts {
    my $dom = Mojo::UserAgent->new->get('http://doc.perl6.org/type.html')
                ->res->dom->at('#content table');

    return $dom->find('tr')->map(sub {
        my $fact = $_->at('td:first-child + td a')->all_text;
        my $def  = $_->at('td:first-child')->all_text . " $fact ["
                . $_->at('td:last-child')->all_text . ']: '
                . 'http://doc.perl6.org/type'
                . $_->at('td:first-child + td a')->{href};

        return +{
            fact => $fact,
            def  => $def,
        };
    })->to_array;
}