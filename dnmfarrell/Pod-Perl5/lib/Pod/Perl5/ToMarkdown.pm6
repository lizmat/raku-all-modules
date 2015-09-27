class Pod::Perl5::ToMarkdown
{
  # stringify all captures .asts
  sub stringify-match ($match)
  {
    my $pod = '';
    for $match.caps -> $value
    {
      $pod ~= $value.value.made;
    }
    return $pod;
  }

  method TOP ($match)
  {
    my $markdown = stringify-match($match);
    # remove double blank lines
    $match.make( $markdown.subst(/\n ** 3..*/, {"\n\n"}, :g) );
  }

  method pod-section ($match)
  {
    $match.make(stringify-match($match));
  }

  #######################
  # Text
  #######################
  method verbatim-paragraph ($match)
  {
    $match.make($match.Str);
  }

  method paragraph ($match)
  {
    $match.make("{$match<multiline-text>.made}\n");
  }

  method any-text        ($match) { $match.make($match.Str) }
  method no-vertical     ($match) { $match.make($match.Str) }
  method blank-line      ($match) { $match.make("\n")       }
  method name            ($match) { $match.make($match.Str) }
  method singleline-text ($match) { $match.make($match.Str) }
  method singleline-format-text
                         ($match) { $match.make($match.Str) }

  method format-text ($match)
  {
    $match.make(stringify-match($match));
  }

  method multiline-text ($match)
  {
    $match.make(stringify-match($match).subst(/\n$/, ''));
  }

  method section ($match) { $match.make($match.Str) }

  ########################
  # command blocks
  ########################
  method cut ($match) { $match.make('') }

  multi method command-block:head1 ($match)
  {
    $match.make("# {$match<singleline-text>.made}\n");
  }

  multi method command-block:head2 ($match)
  {
    $match.make("## {$match<singleline-text>.made}\n");
  }

  multi method command-block:head3 ($match)
  {
    $match.make("### {$match<singleline-text>.made}\n");
  }

  multi method command-block:head4 ($match)
  {
    $match.make("#### {$match<singleline-text>.made}\n");
  }

  multi method command-block:begin-end ($match)
  {
    if $match<begin><name>.made.match(/^ [HTML|MARKDOWN] $/, :i)
    {
      $match.make($match<begin-end-content>.Str);
    }
    else
    {
      $match.make('');
    }
  }

  multi method begin-end-content ($match) { $match.make('') }
  multi method begin             ($match) { $match.make('') }
  multi method _end              ($match) { $match.make('') }

  multi method command-block:_for ($match)
  {
    if $match<name>.made.match(/^ [HTML|MARKDOWN] $/, :i)
    {
      $match.make($match<singleline-text>.made);
    }
    else
    {
      $match.make('');
    }
  }

  multi method command-block:encoding ($match)
  {
    # markdown doesn't have encoding, and there is no <head> element, so ignore
    $match.make('');
  }

  multi method command-block:over-back ($match)
  {
    $match.make(stringify-match($match));
  }

  my $indent_level = -1;
  my $indent_text  = '    ';

  method over ($match) { $match.make(''); $indent_level++ }
  method back ($match) { $match.make(''); $indent_level-- }

  # calculate indentation level
  # if it's numerical, append a period
  method bullet-point ($match)
  {
    $match.make(
      $indent_text x $indent_level
      ~ ($match.Str ~~ /\*/ ?? '* ' !! "{$match.Str}. ")
    );
  }

  # markdown bullet point text begins with a space
  method _item ($match)
  {
    $match.make(stringify-match($match));
  }

  method command-block:pod ($match) { $match.make('') }

  ########################
  # formatting codes
  ########################
  multi method format-code:italic ($match)
  {
    $match.make("*{$match<format-text>.made}*");
  }

  multi method format-code:bold ($match)
  {
    $match.make("__{$match<format-text>.made}__");
  }

  multi method format-code:code ($match)
  {
    $match.make("`{$match<format-text>.made}`");
  }

  # html encode this
  multi method format-code:escape ($match)
  {
    $match.make("&{$match<format-text>.made};");
  }

  # spec says to display in italics
  multi method format-code:filename ($match)
  {
    $match.make("*{$match<format-text>.made}*");
  }

  # singleline shouldn't break across lines ...
  multi method format-code:singleline ($match)
  {
    $match.make($match<format-text>.made);
  }

  # perlpod says index should be an empty string
  multi method format-code:index ($match)
  {
    $match.make('');
  }

  # literally capture any text between zeroeffect
  multi method format-code:zeroeffect ($match)
  {
    $match.make($match<format-text>.Str);
  }

  multi method format-code:link ($match)
  {
    my ($url, $text) = ("","");

    if $match<url>:exists and $match<singleline-format-text>:exists
    {
      $text = $match<singleline-format-text>.made;
      $url  = $match<url>.made;
    }
    elsif $match<url>:exists
    {
      $text = $match<url>.made;
      $url  = $match<url>.made;
    }
    elsif $match<singleline-format-text>:exists and $match<name>:exists and $match<section>:exists
    {
      $text = $match<singleline-format-text>.made;
      $url  = build_url($match<name>.made, $match<section>.made);
    }
    elsif $match<name>:exists and $match<section>:exists
    {
      $text = "{$match<name>.made}#{$match<section>.made}";
      $url  = build_url($match<name>.made, $match<section>.made);
    }
    elsif $match<name>:exists
    {
      $text = $match<name>.made;
      $url  = build_url($match<name>.made);
    }
    else #must just be a section on current doc
    {
      $text = $<section>.made;
      $url  = "#{$match<section>.made}";
    }

    # replace "::" with slash for the perldoc URLs
    if $url ~~ /^https?\:\/\/perldoc\.perl\.org/
    {
      $url = $url.subst('::', {'/'}, :g);
    }
    $match.make("[$text]($url)");
  }

  method url ($match)
  {
    $match.make( $match.Str );
  }

  # decide whether to link to perldoc or metacpan
  # modules usually begin with a capital letter
  sub build_url (Str:D $path, $section?)
  {
    return $path ~~ /^<[A..Z]>/
      ?? "https://metacpan.org/pod/{$path}{ $section ?? qq/#$section/ !! ''}"
      !! "http://perldoc.perl.org/{$path}.html{ $section ?? qq/#$section/ !! ''}";
  }
}

# vim: filetype=perl6
