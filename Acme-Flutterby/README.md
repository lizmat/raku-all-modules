NAME
 
Acme::Flutterby - An object-oriented interface to a butterfly.  In what else but Perl 6.
 
VERSION
 
Version 0.01
 
SYNOPSIS
 
  use Acme::Flutterby;
  my $Flutterby = Flutterby->new;
  $Flutterby.feed;
  $Flutterby.play;
  $flutterby.sacrifice(to-who=>'perl_gods');
 
DESCRIPTION
 
This module provides a simplistic, but powerful, interface to a Butterfly.
 
OBJECT INTERFACE
 

new

Create a new buterfly, all by yourself! :)
 

feed
 
A well-fed butterfly is a happy butterfly.
The Perl gods like happy butterflies.
Too much food makes a sad butterfly though. :(
No one likes a sad butterfly.
 
[Technical details: returns 1 for a happy hungry butterfly, and returns 0
for a big full butterfly. ]
 
play
 
A good butterfly trainer should play often with their butterfly, 
as this makes them happy.
Butterflies get tired though, and then they don't like to play,
they need rest instead then.
 
[Technical details: returns 1 for a butterfly that wants to play more,
and returns for a butterfly that needs a nap. ]
 
nap

Sometimes, even a big butterfly get tired.
When butterflies are tired, they need a nap to make them 
feel better! But, if the butterfly isn't tired, making it
try to take a nap will make it a sad butterfly. :(
 
sacrifice
 
Ah, we finally have reached the last goal of all good butterflies. Sacrificing to the Perl gods. 
You'd best hope your butterfly was happy enough, or death to your Perl script will come! :(
 
AUTHOR
 
John Scoles <byterock@cpan.org>
 
LICENSE
 
Copyright (c) John Scoles 
 
This module may be used, modified, and distributed under BSD license. See the beginning of this file for said license.

