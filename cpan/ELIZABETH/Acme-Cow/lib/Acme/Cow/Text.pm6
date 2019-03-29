use v6.c;

role Acme::Cow::Text:ver<0.0.2>:auth<cpan:ELIZABETH> {
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

    method as_string() { ... }
    method print($handle = $*OUT) { $handle.print(self.as_string) }
    method sink() { self.print }

}

=begin pod

=head1 NAME

Acme::Cow::Text - role for handling texts for Acme::Cow

=head1 SYNOPSIS

=begin code :lang<perl6>

  use Acme::Cow::Text;

  class Acme::Cow does Acme::Cow::Text {
  }

  class Acme::Cow::TextBalloon does Acme::Cow::Text {
  }

=end code

=head1 DESCRIPTION

Acme::Cow::Text is a support role with no servicable parts inside.

=head1 METHODS

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

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

=head1 COPYRIGHT AND LICENSE

Original Perl 5 version: Copyright 2002 Tony McEnroe,
Perl 6 adaptation: Copyright 2019 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
