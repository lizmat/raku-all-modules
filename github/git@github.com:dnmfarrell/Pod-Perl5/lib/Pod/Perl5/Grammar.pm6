grammar Pod::Perl5::Grammar
{
  token TOP
  {
    ^ [ <pod-section> | <!before <pod-section> > .]*
  }

  token pod-section
  {
    # start with a command block
    <command-block>

    # any number of pod sections thereafter
    [
     <command-block>|<paragraph>|<verbatim-paragraph>|<blank-line>
    ]*

    # must end on =cut or the end of the string
    [
      <cut>|$
    ]
  }

  #######################
  # Text
  #######################
  token verbatim-paragraph
  {
    <verbatim-text-line> [ <verbatim-text-line> | <blank-line> <before <verbatim-text-line>> ]+
  }

  # verbatim text is text that begins on a newline with horizontal whitespace
  token verbatim-text-line
  {
    ^^\h+ <singleline-text> \n
  }

  token paragraph
  {
    ^^ <!before \=> <!before \h> <multiline-text>
  }

  token any-text { . }

  token no-vertical { \V }

  # a complete blank line, can contain horizontal whitesapce
  token blank-line
  {
    ^^ \h* \n
  }

  # name matches text with no whitespace and not containing >, /, |
  token name
  {
    <-[\s\>\/\|]>+
  }

  # matches any text except vertical whitespace
  token singleline-text
  {
    \V+
  }

  # same as singleline-text but excludes other formatting codes
  token singleline-format-text
  {
    <-[\v\>\/\|]>+
  }

  # section has the same definition as <singleline-format-text>, but we have a different token
  # in order to be able to distinguish between text and section when they're
  # both present in a link tag eg. "L<This is text|Module::Name/ThisIsTheSection>"
  token section
  {
    <-[\v\>\/\|]>+
  }

  # multiline text can break over lines, but not blank lines
  # can include other format codes
  token multiline-text
  {
    [ <format-code> | <!before <blank-line>> <any-text> ]+
  }

  token format-text
  {
    [ <format-code> | <!before <blank-line>> <!before \>> <any-text> ]+
  }

  ########################
  # command blocks
  ########################
  proto token command-block          { * }
  multi token command-block:pod      { ^^\=pod \h* \n }
  multi token command-block:encoding { ^^\=encoding \h+ <name> \h* \n }

  # separate to enable pod-section termination
  token cut { ^^\=cut \h* \n }

  # list processing
  multi token command-block:over-back
  {
    <over>
    [
      <_item> | <paragraph> | <verbatim-paragraph> | <blank-line> |
      <command-block:_for> | <command-block:begin-end> |
      <command-block:over-back>
    ]*
    <back>
  }

  token over  { ^^\=over \h* [ <after \h> <[0..9]>+ ]? \n }
  token _item {
                ^^\=item \h+ <bullet-point> \h* <multiline-text>?
                [
                 <paragraph> | <verbatim-paragraph> | <blank-line>
                ]*
              }
  token back  { ^^\=back \h* \n }

  token bullet-point { \* | <[0..9]>+ }

  # format processing
  # begin/end blocks cannot be nested
  # so we store the current begin block name
  # to use for matching the end block
  my $begin_end_name;

  multi token command-block:begin-end { <begin> <begin-end-content> <_end> }

  token begin
  {
    ^^\=begin \h+ <name> \h* \n
    { $begin_end_name = $/<name>.Str }
  }

  # end() causes a namespace clash, changed to _end
  token _end { ^^\=end \h+ $begin_end_name \h* \n }

  token begin-end-content
  {
    [ <!before <_end>> . ]*
  }

  multi token command-block:_for  { ^^\=for \h <name> \h+ <singleline-text> \n }
  multi token command-block:head1 { ^^\=head1 \h+ <singleline-text> \n }
  multi token command-block:head2 { ^^\=head2 \h+ <singleline-text> \n }
  multi token command-block:head3 { ^^\=head3 \h+ <singleline-text> \n }
  multi token command-block:head4 { ^^\=head4 \h+ <singleline-text> \n }

  ##########################
  # formatting codes
  ##########################
  proto token format-code            { * }
  multi token format-code:italic     { I\< <format-text> \>  }
  multi token format-code:bold       { B\< <format-text> \>  }
  multi token format-code:code       { C\< <format-text> \>  }
  multi token format-code:escape     { E\< <format-text> \>  }
  multi token format-code:filename   { F\< <format-text> \>  }
  multi token format-code:singleline { S\< <format-text> \>  }
  multi token format-code:index      { X\< <format-text> \>  }
  multi token format-code:zeroeffect { Z\< <format-text> \>  }

  # links are more complicated
  multi token format-code:link
  {
    L\<[
        <url>
        | [ <singleline-format-text> \| <url> ]
        | [ <name> \| <section> ]
        | [ <name> [ \|? \/ <section> ]? ]
        | [ \/ <section> ]
        | [ <singleline-format-text> \| <name> \/ <section> ]
    ]\>
  }

  token url
  {
    [ [ [ https? | ftp | file ] '://' ] | [mailto:] ]
    <-[\v\>\|]>+
  }
}
