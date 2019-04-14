use v6.d;
unit class Pygments:ver<0.0.1>;

use Inline::Python;

my Inline::Python $py;

method !ip {
    return $py if $py.defined;

    $py .= new;
    $py.run: q:to/SETUP/;
    from pygments import highlight
    from pygments.lexers import get_lexer_by_name, guess_lexer
    from pygments.formatters import get_formatter_by_name
    from pygments.styles import STYLE_MAP, get_style_by_name
    SETUP

    $py.run: %?RESOURCES<perl.py>.slurp;

    $py
}

method call($name, |c) {
    self!ip().call('__main__', $name, |c)
}

method highlight(Str $code, $lexer = Any, :$formatter = 'html', *%options) is export {
    my $l = do given $lexer {
        when 'perl6' { self.call('Perl6Lexer') }
        when *.defined { self.call('get_lexer_by_name', $lexer) }
        default { self.call('guess_lexer', $code) }
    };

    my $f = $.formatter($formatter, |%options);
    self!ip().call('pygments', 'highlight', $code, $l, $f)
}

method formatter($name, *%options) is export {
    self.call('get_formatter_by_name', $name, |%options)
}

method style(Str $name = 'default') {
    self!ip().call('pygments.styles', 'get_style_by_name', $name)
}

method styles {
    self!ip().run('list(STYLE_MAP.keys())', :eval).map: *.decode
}

=begin pod

=head1 NAME

Pygments - Wrapper to python pygments library.
=head1 SYNOPSIS

Printing some code with a terminal formatter.

  use Pygments;

  my $code = q:to/ENDCODE/;
  grammar Parser {
      rule  TOP  { I <love> <lang> }
      token love { '♥' | love }
      token lang { < Perl Rust Go Python Ruby > }
  }

  say Parser.parse: 'I ♥ Perl';
  # OUTPUT: ｢I ♥ Perl｣ love => ｢♥｣ lang => ｢Perl｣

  say Parser.parse: 'I love Rust';
  # OUTPUT: ｢I love Rust｣ love => ｢love｣ lang => ｢Rust｣
  ENDCODE

  # Output to terminal with line numbers.
  Pygments.highlight(
      $code, "perl6", :formatter<terminal>,
      :linenos(True)
  ).say;

Also it can be used with C<Pod::To::HTML>:

  use Pygments;

  # Set the pod code callback to use pygments before *use* it
  my %*POD2HTML-CALLBACKS;
  %*POD2HTML-CALLBACKS<code> = sub (:$node, :&default) {
      Pygments.highlight($node.contents.join('\n'), "perl6",
                         :style(Pygments.style('emacs')),
                         :full)
  };
  use Pod::To::HTML;
  use Pod::Load;

  pod2html(load('some.pod6'.IO)).say

=head1 DESCRIPTION

Pygments is a wrapper for the L<pygments|http://pygments.org> python library.

=head1 METHODS

There's no need to instantiate the C<Pygments> class. All the methods can be called
directly.

=head2 highlight

=for code
method highlight(Str $code, $lexer, :$formatter = 'html', *%options)

Highlight the C<$code> with the lexer passed by paramenter. If no lexer is provided,
pygments will try to guess the lexer that will use.

=head2 style

=for code
method style(Str $name = 'default')

Get a single style with name C<$name>

=head2 styles

=for code
method styles

Return a list of all the available themes.

=head1 AUTHOR

Matias Linares <matiaslina@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2019 Matias Linares

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
=end pod
