use v6.c;

use Acme::Cow:auth<cpan:ELIZABETH>;

unit class Acme::Cow::Example:ver<0.0.4>:auth<cpan:ELIZABETH> is Acme::Cow;

my $generic_ascii_art = Q:to/EOC/;
{$balloon}
                       {$tr} 
     {$el}{$er}               {$tr}
 ___________________
/ Insert cute ASCII \
\ artwork here.     /
 -------------------
      {$U}
EOC

method new(|c) { callwith( over => 24, |c ) }
method as_string() { callwith($generic_ascii_art) }

=begin pod

=head1 NAME

Acme::Cow::Example - How to write a "derived cow"

=head1 SYNOPSIS

  use Acme::Cow;
  class Acme::Cow::MyCow is Acme::Cow {
    
  my $my_cow = Q:to/EOC/;
  ... template goes here ...
  EOC

  method new(|c) { callwith( ..., |c ) }
  method as_string { callwith($my_cow) }

=head1 DESCRIPTION

First, put together your template as described in L<Acme::Cow>.
It is recommended that you store this template in a variable.
B<Your template should not have tab characters in it.>  This will
cause ugly things to happen.

Your C<new> method will likely want to look a lot like this:

    method new(|c) { callwith( ..., |c ) }

The ... indicates any additional overrides you need.  If there are none,
you can skip creating your own C<new> method altogether.  Overrides can be
specified just the same as your call to new.  For instance, if you want to
have a default of C<24> for the C<over> attribute:

    method new(|c) { callwith( over => 24, |c ) }

Assuming you stored the template as C<$my_cow> then
your C<as_string> method will likely want to be like this:

    method as_string() { callwith($my_cow) }

Below, we present the actual code in this module, so you can see
it in action.  Yes, you can use this module to produce ASCII art.
No, it won't be very exciting.

=head1 Acme::Cow::Example code

  unit class Acme::Cow::Example:ver<0.0.4>:auth<cpan:ELIZABETH> is Acme::Cow;

  my $generic_ascii_art = Q:to/EOC/;
  {$balloon}
                         {$tr} 
       {$el}{$er}               {$tr}
   ___________________
  / Insert cute ASCII \
  \ artwork here.     /
   -------------------
        {$U}
  EOC

  method new(|c) { callwith( over => 24, |c ) }
  method as_string() { callwith($my_cow) }

=head1 HIGHLIGHTS

The C<{$balloon}> directive is flush left, but due to the call to
C<over()> in the C<new> method, it will be shoved over 24 spaces
to the right, to line up with the thought/speech lines (represented
by C<{$tr}>).

=head1 SAVING WORK

Included with the C<Acme::Cow> distribution is a short program
called C<cowpm> which takes care of most of the boilerplate stuff
for you.  It's almost as simple as I<just add ASCII art> but there's
still a bit that you have to fill in.  It has its own documentation;
you should peruse L<cowpm>.

=head1 SEE ALSO

L<Acme::Cow>, L<cowpm>

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

=head1 COPYRIGHT AND LICENSE

Original Perl 5 version: Copyright 2002 Tony McEnroe,
Perl 6 adaptation: Copyright 2019 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
