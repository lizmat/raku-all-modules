
use v6.c;



=begin pod

=head1 NAME 

Acme::Insult::Lala - Construct an insulting epithet in the manner of an old IRC bot

=head1 SYNOPSIS

=begin code

use Acme::Insult::Lala;

my $lala = Acme::Insult::Lala.new;

say $lala.generate-insult;

=end code

=head1 DESCRIPTION

This makes an insulting epithet in the manner of 'lala' an IRC bot
that used to be on the london.pm channel back in the mists of time.

I think I originally got the source data from an analysis of epithets
in Shakespeare plays or something, but I can't actually remember
it was that long ago. Anyhow at some point the lovely Simon Wistow
retrieved the basic code and data and incorporated it in the Perl 5 module
L<Acme::Scurvy::Whoreson::BilgeRat::Backend::insultserver|http://search.cpan.org/~simonw/Acme-Scurvy-Whoreson-BilgeRat-Backend-insultserver-1.0/>.
From whence I retrieved the data and made it into a Perl 6 module.

I suppose you could use it for generating test data or something
but there's nothing more to it than you see in the Synopsis.

=head1 METHODS

=head2 method new

    method new()

The constructor creates the word lists up front so if you are planning
on using this repeatedly it is best to create a single object and re-use
it.

=head2 method generate-insult

    method generate-insult() returns Str

This generates a new random insult based on the internal word lists, as
noted above if you are planning to call this repeatedly it is probably
better to re-use a single object if you can. 

=end pod


class Acme::Insult::Lala {

    has @!noun;
    has @!adjective-one;
    has @!adjective-two;

    submethod BUILD() {
        my %h = %?RESOURCES<lala.txt>.lines>>.split(/\s+/).map( -> ($a, $b, $c) { a => $a, b => $b, c => $c }).flat.classify(*.key, as => *.value);
        @!adjective-one = %h<a>.list;
        @!adjective-two = %h<b>.list;
        @!noun          = %h<c>.list;
    }

    method generate-insult(Acme::Insult::Lala:D:) returns Str {
        (@!adjective-one.pick, @!adjective-two.pick, @!noun.pick).join(' ');
    }

}

# vim: expandtab shiftwidth=4 ft=perl6
