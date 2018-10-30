#!/usr/bin/env perl6
use v6.c;
use Informative;
=comment
  Show a box with some information on screen, has a destructor x on window, but removes itself after 10s.
  Notice that there is a countdown time for information.
  The string can be marked up with pango markup. 
  
inform( 'This is <span color="blue">blue</span> and <span color="red" weight="bold">red</span> information'  );
=comment
  The label shown in the box is 'This is blue and red information' (with colours).
  The default title is 'Inform'

=comment 
  New title and for a shorter time (5s), note that a timer of 0 is forever.
  
my $popup = inform( 'Shorter time span for me', :timer(5), :title<More> );
=comment
  The title of the window is now 'More'

=comment 
  The 'Informing' object in $popup can be reused with changes in message, countdown and timer.
  The title, buttons and entries are only allowed when creating a new 'Informing' object.
  
$popup.show( 'See no countdown, but timer is unchanged', :!show-countdown );
=comment
  The timer is now no longer showing

=comment
  Add some buttons
  
my $gui-response = inform( 'Do you want to continue?', 
    :buttons( OK=>'OK',b2=>'Not on your life', 'Cancel'=> "I don't want to")
    ); 
say "We have {$gui-response.response} ";
=comment
  The box contains the label 'Do you want to continue' and has three buttons 
  with labels 'OK', 'Not on your life' and "I don't want to"
  The name of the button clicked (OK, b2, Cancel) is printed

=comment
  Access response 
  
say 'Ok continuing' if $gui-response.response eq 'OK';
=comment
  Check other responses
  
say 'I am heedful of your desires' if $gui-response.response ~~ any <b2 Cancel>;
=comment
  Check whether the destruct x was clicked
  
say 'So you don\'t like the options I gave you, huh?' if $gui-response.response eq '_destruct';

=comment
  Add an entry widget and some buttons
  Note that if an entry widget is requested, but no buttons are requested, then
  Cancel and OK are added automatically. 
  An entry widget without buttons is not allowed (design decision)
  
my $data = inform('Give me some things to clean',
    :buttons(Cancel => 'None today', :Response('Here you go')),
    :entries( Laundry => 'Enter your laundry list',)
    );
=comment
  Box contains a label, then one or more entry widgets, then a row of boxes. 
  The formating will depend on gtk defaults.
  NOTE: 'buttons' and 'entries' each expect a list of pairs, not a hash. So the comma
  after '...laundry list' and before the bracket is essential to force a list. With
  two elements, as in the buttons expression, a list already forms. 

if $data.response eq 'Cancel' { say 'Great, more free time for me' }
elsif $data.response eq 'Response' {
  for $data.data<Laundry>.comb(/\w+/) { say "I will clean your $_" }
}

=comment
    An entry widget can mask input, as in password requests, by adding _pw or -pw onto the
    name of the entry.

my $login = inform('Please supply your username and password', 
    :entries(un => 'User name', pw_pw => 'Password')
    );

if $login.response eq 'OK' { say "user name is \<{$login.data<un>}> and password is \<{$login.data<pw_pw>}>" };