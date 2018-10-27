#!/usr/bin/env perl6

use v6;
use Pod::Render;

#-------------------------------------------------------------------------------
=begin pod

=TITLE pod-render.pl6

=SUBTITLE Program to render Pod documentation

=head1 Synopsis

  pod-render.pl6 --pdf bin/pod-render.pl6

=head1 Usage

  pod-render.pl6 [options] <pod-file>

=head2 Arguments

=head3 pod-file

This is the file in which the pod documentation is written and must be rendered.

=head2 Options

=head3 --pdf

Generate output in pdf format. Result is placed in current directory or in the
C<./doc> directory if it exists. Pdf is generated using the program
B<wkhtmltopdf> so that must be installed.

=head3 --html

Generate output in html format. This is the default. Result is placed in current
directory or in the C<./doc> directory if it exists.

=head3 --md

Generate output in md format. Result is placed in current directory or in the
C<./doc> directory if it exists.

=head3 --style=some-prettify-style

This program uses the Google prettify javascript and stylesheets to render the
code. The styles are C<default>, C<desert>, C<doxy>, C<sons-of-obsidian> and
C<sunburst>. By default the progam uses, well you guessed it, 'default'. This
option is only useful with C<--html> and C<--pdf>. There is another style which
is just plain and simple and not used with the google prettifier. This one is
selected using C<pod6>.

It is possible to specify one or more of the output format options generating
more than one document at once.

=end pod
#-------------------------------------------------------------------------------

sub MAIN (
  Str $pod-file,
  Bool :$pdf = False, Bool :$html = False, Bool :$md = False,

  Str :$style = 'default'
) {

  my Pod::Render $pr .= new;

  $pr.render( 'html', $pod-file, :$style) if $html;
  $pr.render( 'pdf', $pod-file, :$style) if $pdf;
  $pr.render( 'md', $pod-file) if $md;

  # Default is html
  $pr.render( 'html', $pod-file, :$style) unless $html or $pdf or $md;
}
