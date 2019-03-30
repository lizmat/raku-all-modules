use v6.c;

use Acme::Cow::TextBalloon:ver<0.0.3>:auth<cpan:ELIZABETH>;

class Acme::Cow:ver<0.0.3>:auth<cpan:ELIZABETH> {
    has  Str $.el   is rw = 'o';
    has  Str $.er   is rw = 'o';
    has  Str $.U    is rw = '  ';
    has  Str $.File;
    has  Int $.over = 0;
    has  Int $.wrap = 40;
    has Bool $.fill = True;
    has  Str $.mode = 'say';
    has      @.text;

    multi method over()             { $!over }
    multi method over(Int() $!over) { $!over }

    multi method wrap()             { $!wrap }
    multi method wrap(Int() $!wrap) { $!wrap }

    multi method fill()              { $!fill }
    multi method fill(Bool() $!fill) { $!fill }

    multi method think()    { $!mode = 'think' }
    multi method think(*@_) { $!mode = 'think'; self.text(@_) }

    multi method say()    { $!mode = 'say' }
    multi method say(*@_) { $!mode = 'say'; self.text(@_) }

    multi method text()    { @!text }
    multi method text(@_)  { @!text = @_ }
    multi method text(*@_) { @!text = @_ }

    method print($handle = $*OUT) { $handle.print(self.as_string) }

    my $default-cow = q:to/EOC/;
    {$balloon}
            {$tl}   ^__^
             {$tl}  ({$el}{$er})\_______
                (__)\       )\/\
                 {$U} ||----w |
                    ||     ||
    EOC

    method as_string($cow?) {
        self.process_template(
          ($cow // ($.File ?? $.File.IO.slurp !! $default-cow)),
          balloon => Acme::Cow::TextBalloon.new(
            :$.fill, :@.text, :$.over, :$.mode, :$.wrap).as_string.chomp,
          el => $.el,
          er => $.er,
          U  => $.U,
          tl => $.mode eq 'think' ?? 'o' !! '\\',
          tr => $.mode eq 'think' ?? 'o' !! '/',
        )
    }

    # Text::Template in a nutshell
    method process_template($text, *%mapper) {
        $text.subst(/ '{$' (\w+) '}' /, -> $/ { %mapper{$0} }, :g)
    }

    method distribution() { $?DISTRIBUTION }
}

=begin pod

=head1 NAME

Acme::Cow - Talking barnyard animals (or ASCII art in general)

=head1 SYNOPSIS

=begin code :lang<perl6>

  use Acme::Cow;

  my Acme::Cow $cow .= new;
  $cow.say("Moo!");
  $cow.print;

  my $sheep = Acme::Cow::Sheep.new;    # Derived from Acme::Cow
  $sheep.wrap(20);
  $sheep.think;
  $sheep.text("Yeah, but you're taking the universe out of context.");
  $sheep.print($*ERR);

  my $duck = Acme::Cow.new(File => "duck.cow");
  $duck.fill(0);
  $duck.say(`figlet quack`);
  $duck.print($socket);

=end code

=head1 DESCRIPTION

Acme::Cow is the logical evolution of the old cowsay program.  Cows
are derived from a base class (Acme::Cow) or from external files.

Cows can be made to say or think many things, optionally filling
and justifying their text out to a given margin.

Cows are nothing without the ability to print them, or sling them
as strings, or what not.

=head1 METHODS

=head2 new

  my $cow = Acme::Cow.new(
    over => 0,    # optional
    wrap => 40,   # optional
    fill => True, # optional

    text => "hello world",  # specify the text of the cow
    File => "/foo/bar",     # specify when loading cow from a file
  );

Create a new C<Acme::Cow> object.  Optionally takes the following named
parameters:

has  Str $.el   is rw = 'o';
has  Str $.er   is rw = 'o';
has  Str $.U    is rw = '  ';


=head2 over

Specify (or retrieve) how far to the right (in spaces) the text
balloon should be shoved.

=head2 wrap

Specify (or retrieve) the column at which text inside the balloon
should be wrapped.  This number is relative to the balloon, not
absolute screen position.

The number set here has no effect if you decline filling/adjusting
of the balloon text.

=head2 think

Tell the cow to think its text instead of saying it.  Optionally takes the
text to be thought.

=head2 say

Tell the cow to say its text instead of thinking it.  Optionally takes the
text to the said.

=head2 text

Set (or retrieve) the text that the cow will say or think.

Expects a list of lines of text (optionally terminated with newlines) to
be displayed inside the balloon.

=head2 print

Print a representation of the cow to the specified filehandle
($*OUT by default).

=head2 fill

Inform the cow to fill and adjust (or not) the text inside its balloon.
By default, text inside the balloon is filled and adjusted.

=head2 as_string

Render the cow as a string.

=head1 WRITING YOUR OWN COW FILES

{$balloon} is the text balloon; it should be on a line by itself,
flush-left.  {$tl} and {$tr} are what goes to the text balloon from
the thinking/speaking part of the picture; {$tl} is a backslash
("\") for speech, while {$tr} is a slash ("/"); both are a lowercase
letter O ("o") for thought.  {$el} is a left eye, and {$er} is a
right eye; both are "o" by default.  Finally {$U} is a tongue,
because a capital U looks like a tongue.  (Its default value is "U ".) 

There are two methods to make your own cow file: the standalone
file and the Perl module.

For the standalone file, take your piece of ASCII art and modify
it according to the rules above.  Note that the
balloon must be flush-left in the template if you choose this method.
If the balloon isn't meant to be flush-left in the final output,
use its C<over()> method.

For a Perl module, declare that your module is a subclass of C<Acme::Cow>.
You may do other
modifications to the variables in the template, if you wish:
many examples are provided with the C<Acme::Cow> distribution.

=head1 HISTORY

They're called "cows" because the original piece of ASCII art was
a cow.  Since then, many have been contributed (i.e. the author
has stolen some) but they're still all cows.

=head1 SEE ALSO

L<perl>, L<cowsay>, L<figlet>, L<fortune>, L<cowpm>

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

=head1 COPYRIGHT AND LICENSE

Original Perl 5 version: Copyright 2002 Tony McEnroe,
Perl 6 adaptation: Copyright 2019 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
