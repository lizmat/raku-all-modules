use Pod::Perl5::Grammar;

grammar Pod::Perl5::PerlTricks::Grammar is Pod::Perl5::Grammar
{
  # new formatting codes!
  multi token format-code:data      {  D \< <multiline_text> \> }
  multi token format-code:github    {  G \< <singleline_format_text> \> }
  multi token format-code:hashtag   { '#'\< <name> \> }
  multi token format-code:metacpan  {  M \< <name> \> }
  multi token format-code:note      {  N \< <multiline_text> \> }
  multi token format-code:terminal  {  T \< <multiline_text> \> }
  multi token format-code:twitter   { '@'\< <name> \> }
  multi token format-code:wikipedia {  W \< <singleline_format_text> \> }

  # new command blocks!

  # include will have the grammar parse the included file too
  # useful for boilerplate metadata like author data
  multi token command-block:include {
    ^^\=include \h+ <file> \n

    # now parse the file
    {
      $<file>.make(self.parsefile($<file>, :actions($*ACTIONS)));
      CATCH { die "Error parsing =include directive $_" }
    }
  }

  # filepath to other pod
  token file { \V+ }

  # author metadata
  multi token command-block:author-name  { ^^\=author\-name  \h+ <singleline_text> \n }
  multi token command-block:author-bio   { ^^\=author\-bio   \h+ <singleline_text> \n }
  multi token command-block:author-image { ^^\=author\-image \h+ <format-code:link>\n }

  # article metadata
  multi token command-block:tags { ^^\=tags [\h+ <name> ]+ \n }

  # these regexes on need to be on multiple lines to avoid warnings ...
  # YYYY-MM-DD
  token date {
    <[0..9]> ** 4 \- <[0..1]> <[0..9]> \- <[0..3]> <[0..9]>
  }

  # HH:MM:SS
  token time {
    <[0..2]> <[0..9]> \: <[0..6]> <[0..9]> \: <[0..6]> <[0..9]>
  }

  # Z or -/+HH:MM
  token timezone {
    Z | <[-+]> <[0..2]> <[0..9]> \: <[0..6]> <[0..9]>
  }

  token datetime  { <date> T <time> <timezone>? }

  # the date the article should be/was published
  # this is the ISO 8601 format:
  #   UTC:  "1963-11-23T17:15:00Z"
  #   EST:  "1963-11-23T17:15:00-05:00"
  multi token command-block:publish-date
  {
    ^^\=publish\-date \h+ <datetime> \n
    {
      $<datetime>.make(DateTime.new($/<datetime>.Str));
      CATCH { die "Error parsing =publish-date $_" }
    }
  }

  multi token command-block:chapter  { ^^\=chapter \h+ <singleline_text> \n }
  multi token command-block:title    { ^^\=title \h+ <singleline_text> \n }
  multi token command-block:subtitle { ^^\=subtitle \h+ <singleline_text> \n }
  multi token command-block:section  { ^^\=section \h+ <singleline_text> \n }

  # images
  multi token command-block:image       { ^^\=image \h+ <format-code:link> \n }
  multi token command-block:cover-image { ^^\=cover\-image \h+ <format-code:link> \n }

  # table
  multi token command-block:table
  {
    ^^\=table \h* \n
    <blank_line>?
    <header_row>
    <row>+
    <blank_line>
  }
  token header_row  { ^^ \h* <header_cell> [<divider> <header_cell>]* \n }
  token row         { ^^ \h* <cell> [<divider> <cell>]* \n }
  token header_cell { [<!before <divider>>\V]+ }
  token cell        { [<!before <divider>>\V]+ }
  token divider     { \h+\|\h+ }
}
