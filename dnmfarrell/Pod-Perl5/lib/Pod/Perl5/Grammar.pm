grammar Pod::Perl5::Grammar
{
  token TOP
  {
    ^ [ <pod-section> | <?!before <pod-section> > .]* $
  }

  token pod-section
  {
    # start with a command block
    <command-block>

    # any number of pod sections thereafter
    [
     <command-block>|<paragraph>|<verbatim_paragraph>|<blank_line>
    ]*

    # must end on =cut or the end of the string
    [
      <command-block:cut>|$
    ]
  }

  #######################
  # Text
  #######################
  token verbatim_paragraph
  {
    <verbatim_text> <blank_line>
  }

  token paragraph
  {
    <?!before [\=|\s]> <paragraph_node>+  <blank_line>
  }

  token paragraph_node
  {
    [ <format-code> | [<?!before [<format-code>|<blank_line>]> .]+ ]
  }

  # verbatim text is text that begins on a newline with horizontal whitespace
  # is terminated by a blank line
  token verbatim_text
  {
    ^^\h+? \S [ <?!before <blank_line>> . ]*
  }

  # a complete blank line, can contain horizontal whitesapce
  token blank_line
  {
    ^^ \h*? \n
  }

  # name matches text with no whitespace and not containing >, /, |
  token name
  {
    <-[\s\>\/\|]>+
  }

  # matches any text except vertical whitespace
  token singleline_text
  {
    \V+
  }

  # same as <name> except can contain horizontal whitespace
  token singleline_format_text
  {
    <-[\v\>\/\|]>+
  }

  # section has the same definition as <singleline_format_text>, but we have a different token
  # in order to be able to distinguish between text and section when they're
  # both present in a link tag eg. "L<This is text|Module::Name/ThisIsTheSection>"
  token section
  {
    <-[\v\>\/\|]>+
  }

  # multiline text can break over lines, but not blank lines.
  token multiline_text
  {
    [ <format-code> | <?!before [ <blank_line> | \> ]> . ]+
  }


  ########################
  # command blocks
  ########################
  proto token command-block { * }

  multi token command-block:pod      { ^^\=pod \h* \n }
  multi token command-block:cut      { ^^\=cut \h* \n }
  multi token command-block:encoding { ^^\=encoding \h+ <name> \h* \n }

  # list processing
  multi token command-block:over_back
  {
    <over>
    [
      <_item> | <paragraph> | <verbatim_paragraph> | <blank_line> |
      <command-block:_for> | <command-block:begin_end> | <command-block:pod> | 
      <command-block:encoding> | <command-block:over_back>
    ]*
    <back>
  }

  token over      { ^^\=over [\h+ <[0..9]>+ ]? \n }
  token _item     { ^^\=item \h+ <name>
                    [
                      [ \h+ <paragraph>  ]
                      | [ \h* \n <blank_line> <paragraph>? ]
                    ]
                  }
  token back      { ^^\=back \h* \n }

  # format processing
  # begin/end blocks cannot be nested
  # so we store the current begin block name
  # to use for matching the end block
  my $begin_end_name;

  multi token command-block:begin_end { <begin> <begin_end_content> <_end> }
  token begin     { ^^\=begin \h+ <name> \h* \n { $begin_end_name = $/<name>.Str } }
  # end() causes a namespace clash, changed to _end
  token _end       { ^^\=end \h+ $begin_end_name \h* \n }

  token begin_end_content
  {
  [ <?!before <_end>> . ]*
  }

  multi token command-block:_for      { ^^\=for \h <name> \h+ <singleline_text> \n }

  multi token command-block:head1     { ^^\=head1 \h+ <singleline_text> \n }
  multi token command-block:head2     { ^^\=head2 \h+ <singleline_text> \n }
  multi token command-block:head3     { ^^\=head3 \h+ <singleline_text> \n }
  multi token command-block:head4     { ^^\=head4 \h+ <singleline_text> \n }

  ##########################
  # formatting codes
  ##########################
  proto token format-code  { * }
  multi token format-code:italic        { I\< <multiline_text>  \>  }
  multi token format-code:bold          { B\< <multiline_text>  \>  }
  multi token format-code:code          { C\< <multiline_text>  \>  }
  multi token format-code:escape        { E\< <singleline_format_text> \>  }
  multi token format-code:filename      { F\< <singleline_format_text> \>  }
  multi token format-code:singleline    { S\< <singleline_format_text> \>  }
  multi token format-code:index         { X\< <singleline_format_text> \>  }
  multi token format-code:zeroeffect    { Z\< <singleline_format_text> \>  }

  # links are more complicated
  multi token format-code:link          { L\<
                         [
                            [ <url>  ]
                          | [ <singleline_format_text> \| <url> ]
                          | [ <name> \| <section> ]
                          | [ <name> [ \|? \/ <section> ]? ]
                          | [ \/ <section> ]
                          | [ <singleline_format_text> \| <name> \/ <section> ]
                         ]
                        \>
                      }
  token url           { [ https? | ftp | file ] '://' <-[\v\>\|]>+ }


  ########################
  # Diagnostics
  ########################

}
