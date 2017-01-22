unit module Acme::Flutterby;
class Flutterby is export {

    has Int $.foodage is rw;
    has Int $.happiness is rw;
    has Bool $.tired is rw;

    method feed () {
        $.foodage++;
        if (self.foodage < 10) {
            self.happiness++;
        } else {
            self.happiness--;
        }
        return self.foodage < 9;
    }

    method play() {
        if (self.tired) {
            self.happiness -= 5;
            return False;
        }
        my $play = 20.rand().Int;
        self.happiness += 2;

        if ($play > 10) {
            self.tired = True;
        } else {
            self.tired = False;
        }
        return not self.tired;
    }

    method nap {
        sleep 1/3;
        if (!self.tired ) {
            self.happiness -= 1;
            return;
        }

        self.tired = False;
        return;
    }

    method sacrifice(Str :$to-who!) {
        if (lc($to-who) ne 'perl_gods') {
            say("You can only sacrifice to a Perl God");
        }
        if (self.happiness > 10) {
            say "Congradulations!! Your sacrificial Flutterby has appeased the Perl gods :) !";
            exit 0;
        } else {
            say("Sorry, your Flutterby was not happy enough.  Try to raise it better next time :( !");
            exit self.happiness - 10;
        }
    }
}

=begin pod

=head1 NAME

Acme::Flutterby - An object-oriented interface to a butterfly.  In what else but Perl 6.

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

  use Acme::Flutterby;
  my $Flutterby = Flutterby->new;
  $Flutterby.feed;
  $Flutterby.play;
  $flutterby.sacrifice(to-who=>'perl_gods');

=head1 DESCRIPTION

This module provides a simplistic, but powerful, interface to a Butterfly.

=head1 OBJECT INTERFACE

=over

=item B<new>

Create a new buterfly, all by yourself! :)

=cut

=item B<feed>

A well-fed butterfly is a happy butterfly.
The Perl gods like happy butterflies.
Too much food makes a sad butterfly though. :(
No one likes a sad butterfly.

[Technical details: returns True for a happy hungry butterfly, and returns False
for a big full butterfly. ]

=cut

=item B<play>

A good butterfly trainer should play often with their butterfly,
as this makes them happy.
Butterflies get tired though, and then they don't like to play,
they need rest instead then.

[Technical details: returns True for a butterfly that wants to play more,
and returns False for a butterfly that needs a nap. ]

=cut
=item B<nap>

Sometimes, even a big butterfly get tired.
When butterflies are tired, they need a nap to make them
feel better! But, if the butterfly isn't tired, making it
try to take a nap will make it a sad butterfly. :(

=cut

=item B<sacrifice>

Ah, we finally have reached the last goal of all good butterflies. Sacrificing to the Perl gods.
You'd best hope your butterfly was happy enough, or death to your Perl script will come! :(

=back
=cut

=head1 AUTHOR

John Scoles <byterock@cpan.org>

=head1 LICENSE

Copyright (c) John Scoles

This module may be used, modified, and distributed under BSD license. See the beginning of this file for said license.

=head1 SEE ALSO

=cut

=end pod
