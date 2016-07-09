
module Text::Wrap {
  sub wrap-text(
    Str $text,
    Int :$width is copy where * > 0 = 80,
    Regex :$paragraph = rx/\n ** 2..*/,
    Bool :$hard-wrap = False,
    Str :$prefix = '',
  ) is export {
    my $result = '';

    $width -= $prefix.chars;

    my @paragraphs = $paragraph.defined ?? $text.split($paragraph) !! [$text];

    while @paragraphs {
      my $p = @paragraphs.shift;
      my $line = '';

      for $p.words -> $word {
        if $line.chars + 1 + $word.chars <= $width || (!$line.chars && $word.chars <= $width) {
            $line ~= $line ?? ' ' ~ $word !! $word;
        }
        else {
          $result ~= $prefix ~ $line ~ "\n";

          if $hard-wrap {
            my $copy = $word;

            while $copy.chars > $width {
              $result ~= $prefix ~ $copy.substr(0, $width) ~ "\n";
              $copy.=substr($width);
            }

            $line = $copy;
          }
          else {
            $line = $word;
          }
        }
      }

      $result ~= $prefix ~ $line if $line;
      $result ~= "\n" ~ $prefix ~ "\n" if @paragraphs;
    }

    return $result.trim-leading;
    # return $result;
  }
}

=begin pod

=head1 NAME

Text::Wrap - Wrap texts.

=head1 SYNOPSIS

  use Text::Wrap;

  say wrap-text($some-long-text);
  say wrap-text($some-long-text, :width(50));
  say wrap-text($some-long-text, :paragraph(rx/\n/));
  say wrap-text($text-with-very-long-word, :hard-wrap);

=head1 DESCRIPTION

Text::Wrap provides a single function C<<wrap-text>> that takes arbitrary text
and wraps it to form paragraphs that fit the given width. There are three
optional arguments that modify its behavior.

=item C<<:width(80)>> sets the maximum width of a line. The default is 80
characters. If a single word is longer than this value, a line may become
longer than this in order not to wrap the line in the middle of the word. This
can be changed with C<<:hard-break>>.

=item C<<:hard-break>> makes C<<wrap-text>> break lines in the middle of words
that are longer than the maximum width. It's off by default, meaning that lines
may become longer than the maximum width if the text contains words that are
too long to fit a line.

=item C<<:paragraph(rx/\n ** 2..*/)>> takes a C<<Regex>> object which is used find
paragraphs in the source text in order to retain them in the result. The
default is C<<\n ** 2..*>> (two or more consecutive linebreaks). To discard any
paragraphs from the source text, you can set this to C<<Regex:U>>.

=tem C<<:prefix('')>> takes a string that's inserted in front of every line of
the wrapped text. The length of the prefix string counts into the total line
width, meaning it's subtracted from the given C<<:width>>.

=head1 AUTHOR

Jonas Kramer <jkramer@mark17.net>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 Jonas Kramer.

This library is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.

=end pod

