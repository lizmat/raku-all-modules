use Pod::Perl5::ToHTML;
use Pod::PerlTricks::Grammar;

class Pod::PerlTricks::ToHTML is Pod::Perl5::ToHTML
{
  # these are appended to the bottom of the <body> element
  # see format-code:note
  has @.footnotes = [];
  has $.chapter_count = 0;

  # language is an attribute of the root element
  has $.lang is rw;

  # override TOP to handle footnotes
  method TOP ($match)
  {
    $.head = @.meta.elems ?? @.meta.values.join("\n") !! '';
    $.body = (self.stringify-match($match) ~ self.build-footnotes).subst(/\n ** 3..*/, {"\n\n"}, :g);
    $match.make("<html{$.lang || ''}>\n{$.head ?? "<head>\n" ~ $.head ~ "\n</head>\n" !! ''}<body>\n{$.body}\n</body>\n</html>\n");
  }

  # foot notes are an unordered list inside a div
  method build-footnotes ()
  {
    return '' unless @.footnotes.elems;

    my $footnotes_string = "<div class=\"footnotes\">\n<ul>\n";
    for 0..(@.footnotes.elems - 1)
    {
      $footnotes_string ~= "<li id=\"{$.chapter_count}_{$_ + 1}\">[{$_ + 1}] {@.footnotes[$_]}</li>\n";
    }
    @.footnotes = [];
    return $footnotes_string ~ "</ul>\n</div>\n";
  }

  ########################
  # formatting codes
  ########################
  multi method format-code:data ($match)
  {
    $match.make("<span class=\"data\">{$match<format-text>.made}</span>");
  }

  multi method format-code:github ($match)
  {
    my $reponame = $match<name>[*-1].made;

    my $repodir = $match<name>.values.join('/');

    $match.make("<a href=\"https://github.com/{$repodir}\">{$reponame}</a>");
  }

  multi method format-code:hashtag ($match)
  {
    my $hashtag = $match<name>.made;
    $match.make("<a href=\"https://twitter.com/search?q=$hashtag\">#{$hashtag}</a>");
  }

  # create a footnote to be appended to the document body
  # and an internal link pointing to it using superscript
  multi method format-code:note ($match)
  {
    my $footnote = $match<format-text>.made;
    @.footnotes.push($footnote);
    my $footnote_index = @.footnotes.elems;
    $match.make("<sup><a href=\"#{$.chapter_count}_{$footnote_index}\">{$footnote_index}</a></sup>");
  }

  multi method format-code:terminal ($match)
  {
    $match.make("<span class=\"terminal\">{$match<format-text>.made}</span>");
  }

  multi method format-code:twitter ($match)
  {
    my $name = $match<name>.made;
    $match.make("<a href=\"https://twitter.com/{$name}\">{$name}</a>");
  }

  # using en.wikipedia.org, what about other langs?
  multi method format-code:wikipedia ($match)
  {
    my $wikiname = $match<singleline-format-text>.made;
    $match.make("<a href=\"https://en.wikipedia.org/wiki/{$wikiname}\">{$wikiname}</a>");
  }

  ########################
  # command directives
  ########################

  # table handling
  multi method command-block:table ($match)
  {
    my @table_tags = '<table>', $match<header-row>.made;

    for $match<row>.values -> $row
    {
      @table_tags.push("<tr>{$row.made}</tr>");
    }
    @table_tags.push("</table>\n\n");
    $match.make(join("\n", @table_tags));
  }
  method header-row ($match)
  {
    my $cells;

    for $match<header-cell>.values -> $cell
    {
      $cells ~= $cell.made;
    }
    $match.make($cells);
  }
  method row ($match)
  {
    my $cells;

    for $match<cell>.values -> $cell
    {
      $cells ~= $cell.made;
    }
    $match.make($cells);
  }
  method header-cell ($match)
  {
    $match.make("<th>{$match}</th>");
  }
  method cell ($match)
  {
    $match.make("<td>{$match}</td>");
  }

  multi method command-block:include ($match)
  {
    for $match<format-code>
    {
      my $filepath = $_<url>.Str.subst(/^file\:\/\//, '');
      die 'Error parsing =include block L<>, should be in the format: L<file://path/to/file.pod>'
        unless $filepath;

      # can't use current self - it has state!
      my $actions  = self.new;
   
      # now parse the file
      my $submatch = Pod::PerlTricks::Grammar.parsefile($filepath, :$actions);
      CATCH { die "Error parsing =include directive $_" }

      # copy any meta directives out of the sub-action class
      for $actions.meta
      {
        @.meta.push($_);
      }
      # get the inline pod
      # TODO handle more than 1 pod section ?
      $match.make(self.stringify-match($submatch<pod-section>[0]));
    }
  }

  multi method command-block:chapter ($match)
  {
    my $previous_chapter_footnotes = self.build-footnotes();
    $.chapter_count++;
    $match.make("{$previous_chapter_footnotes}<div class=\"chapter\">{$match<singleline-text>.made}</div>\n");
  }

  # save in meta to be used in <head> later
  multi method command-block:title ($match)
  {
    @.meta.push("<title>{$match<singleline-text>.made}</title>");
    $match.make("<div class=\"title\">{$match<singleline-text>.made}</div>\n");
  }

  multi method command-block:subtitle ($match)
  {
    $match.make("<div class=\"subtitle\">{$match<singleline-text>.made}</div>\n");
  }

  multi method command-block:section ($match)
  {
    $match.make("<div class=\"section\">{$match<singleline-text>.made}</div>\n");
  }

  # "author" is an official metadata name so we add it to meta
  # the bio and pic are inline elements which get a class identifying them
  multi method command-block:author-name ($match)
  {
    @.meta.push("<meta name=\"author\" content=\"{$match<singleline-text>.made}\">");
    $match.make('');
  }

  multi method command-block:author-bio ($match)
  {
    $match.make("<p class=\"author-bio\">{$match<multiline-text>.made}</p>\n");
  }

  multi method command-block:author-image ($match)
  {
    $match.make( self.create-img($match<format-code>,['author-image']) );
  }

  # synopsis maps to meta "description"
  multi method command-block:synopsis ($match)
  {
    @.meta.push("<meta name=\"description\" content=\"{$match<singleline-text>.made}\">");
    $match.make('');
  }

  # this will be added to the <html> node later
  multi method command-block:lang ($match)
  {
    $.lang = " lang=\"{$match<name>.made}\"";
    $match.make('');
  }

  multi method command-block:tags ($match)
  {
    @.meta.push("<meta name=\"keywords\" content=\"{$match<name>.values.join(",")}\">");
    $match.make('');
  }

  # date time handling
  multi method date     ($match) { $match.make('') }
  multi method time     ($match) { $match.make('') }
  multi method timezone ($match) { $match.make('') }
  multi method datetime ($match) { $match.make($match.Str) }

  multi method command-block:publish-date ($match)
  {
    $match.make("<div class=\"publish-date\">{$match<datetime>.made}</div>\n");
  }

  # images
  multi method command-block:image ($match)
  {
    my $link = $match<format-code>;
    $match.make(self.create-img($link));
  }

  # cover-image is like image except it gets the cover class
  multi method command-block:cover-image ($match)
  {
    $match.make(self.create-img($match<format-code>, ['cover']) ~ "\n" );
  }

  method create-img ($link, @html_classes?)
  {
    my ($url, $text) = ("","");

    if $link<url>:exists and $link<singleline-format-text>:exists
    {
      $text = $link<singleline-format-text>.made;
      $url  = $link<url>.made.subst(/^file\:\/\//, '');
    }
    elsif $link<url>:exists
    {
      $text = $link<url>.made.subst(/^file\:\/\//, '');
      $url  = $link<url>.made.subst(/^file\:\/\//, '');
    }
    else
    {
      die 'Unable to parse L<> format code for create-img';
    }
    my $class_txt = @html_classes.elems ?? " class=\"{@html_classes.join(' ')}\"" !! '';
    return "<img src=\"{$url}\" alt=\"{$text}\"{$class_txt}>";
  }

  # overwrite begin/end to handle html, data, terminal and code
  # remove some leading and trailing vertical whitespace
  multi method command-block:begin-end ($match)
  {
    my $begin_name = $match<begin><name>.made;

    if $begin_name ~~ m:i/^ HTML $/
    {
      $match.make("{$match<begin-end-content>.Str.subst(/[^\n]|[\v ** 1..2$]/,'', :g)}");
    }
    elsif $begin_name ~~ m:i/^ DATA $/
    {
      $match.make("<pre class=\"data\">{$match<begin-end-content>.Str.subst(/[^\n]|[\v ** 1..2$]/,'', :g)}</pre>\n");
    }
    elsif $begin_name ~~ m:i/^ CODE $/
    {
      $match.make("<pre><code>{$match<begin-end-content>.Str.subst(/[^\n]|[\v ** 1..2$]/,'', :g)}</code></pre>\n");
    }
    elsif $begin_name ~~ m:i/^ TERMINAL $/
    {
      $match.make("<pre class=\"terminal\">{$match<begin-end-content>.Str.subst(/[^\n]|[\v ** 1..2$]/,'', :g)}</pre>\n");
    }
    else
    {
      $match.make('');
    }
  }
}
