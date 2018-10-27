use Pod::PerlTricks::ToHTML;
use JSON::Tiny;

# this class is intended for use with AngularJS
# the head attribute contains metadata about the document: title, author, publish-date etc
# the body attribute contains the main article text in HTML
# The entire json is added to the .ast/.made slot in the match object

class Pod::PerlTricks::ToJSON is Pod::PerlTricks::ToHTML
{
  # TODO need to correctly escape the strings for JSON here
  method TOP ($match)
  {
    # parse the head pairs into JSON
    $.head = to-json(@.meta);
    $.body = to-json(
      (self.stringify-match($match) ~ self.build-footnotes).subst(/\n ** 3..*/, {"\n\n"}, :g));
    $match.make(to-json({"head" => @.meta, "body" => $.body}));
  }

  multi method command-block:encoding ($match)
  {
    # "utf8" is a common Pod encoding, it should be UTF-8 in HTML
    my $pod_encoding = $match<name>.made;
    my $html_encoding = $pod_encoding eq 'utf8' ?? 'UTF-8' !! $pod_encoding;

    # save in meta to be used in <head> later
    @.meta.push("charset" => $html_encoding);

    # make an empty string so the encoding is not returned inline
    $match.make('');
  }

  multi method command-block:chapter ($match)
  {
    @.meta.push("chapter" => $match<singleline-text>.made);
    $match.make('');
  }

  multi method command-block:title ($match)
  {
    @.meta.push("title" => $match<singleline-text>.made);
    $match.make('');
  }

  multi method command-block:subtitle ($match)
  {
    @.meta.push("subtitle" => $match<singleline-text>.made);
    $match.make('');
  }

  multi method command-block:section ($match)
  {
    @.meta.push("section" => $match<singleline-text>.made);
    $match.make('');
  }

  multi method command-block:author-name ($match)
  {
    @.meta.push("author" => $match<singleline-text>.made);
    $match.make('');
  }

  multi method command-block:author-bio ($match)
  {
    @.meta.push("author-bio" => $match<multiline-text>.made);
    $match.make('');
  }

  multi method command-block:author-image ($match)
  {
    @.meta.push("author-image" => $match<format-code><url>.Str);
    $match.make('');
  }

  multi method command-block:synopsis ($match)
  {
    @.meta.push("description" => $match<singleline-text>.made);
    $match.make('');
  }

  multi method command-block:lang ($match)
  {
    @.meta.push("lang" => $match<name>.made);
    $match.make('');
  }

  multi method command-block:tags ($match)
  {
    @.meta.push("keywords" => [$match<name>.values».made]);
    $match.make('');
  }

  multi method command-block:publish-date ($match)
  {
    @.meta.push("publish-date" => $match<datetime>.made.Str);
    $match.make('');
  }

  multi method command-block:cover-image ($match)
  {
    @.meta.push("cover-image" => $match<format-code><url>.Str.subst(/^file\:\/\//, ''));
    $match.make('');
  }
}
