use v6.c;
use Pod::To::HTML;
use Pod::To::Markdown;

#-------------------------------------------------------------------------------
#unit package Pod:auth<https://github.com/MARTIMM>;

#===============================================================================
=begin pod

=TITLE class Pod::Render

=SUBTITLE Render POD documents to HTML, PDF or MD

  class Pod::Render { ... }

=head1 Synopsis

  use Pod::Render;
  my Pod::Render $pr .= new;
  $pr.render( 'html', 'my-excellent-pod-document.pod6');

=end pod
#-------------------------------------------------------------------------------
class Pod::Render:auth<https://github.com/MARTIMM> {

  has Str $!involved = 'Pod::Render';

  #=============================================================================
  =begin pod
  =head1 Methods
  
  =head2 render

    multi method render ( 'html', Str:D $pod-file, Str :$style )
    multi method render ( 'pdf', Str:D $pod-file, Str :$style )
    multi method render ( 'md', Str:D $pod-file )

  Render the document given by C<$pod-file> to one of the output formats html,
  pdf or markdown. To generate pdf the program C<wkhtmltopdf> is used so that
  program must be installed. The style is one of the following styles;
  pod6 default desert doxy sons-of-obsidian sunburst.

  =end pod
  #-----------------------------------------------------------------------------
  multi method render ( 'html', Str:D $pod-file, Str :$style ) {

    my Str $html = self!html( $pod-file.IO.absolute, :$style);

    my Str $html-file;
    if 'doc'.IO ~~ :d {
      $html-file = 'doc/' ~ $pod-file.IO.basename;
    }

    else {
      $html-file = $pod-file.IO.basename;
    }

    $html-file ~~ s/\. <-[.]>+ $/.html/;
    spurt( $html-file, $html);
  }

  #-----------------------------------------------------------------------------
  multi method render ( 'pdf', Str:D $pod-file, Str :$style ) {

    my Str $html = self!html( $pod-file.IO.absolute, :$style);
    $!involved ~= ', wkhtmltopdf';

    my Str $pdf-file;
    if 'doc'.IO ~~ :d {
      $pdf-file = 'doc/' ~ $pod-file.IO.basename;
    }

    else {
      $pdf-file = $pod-file.IO.basename;
    }

    $pdf-file ~~ s/\. <-[.]>+ $/.pdf/;

    # send result to pdf generator
    my Proc $p = shell "wkhtmltopdf - '$pdf-file' &>wkhtml2pdf.log", :in;
#    my Proc $p = shell "wkhtmltopdf - '$pdf-file'", :in, :out;
    $p.in.print($html);

#    my Promise $pout .= start( {
#        for $p.err.lines {
#          "Err: ", .say;
#        }
#      }
#    );
  }

  #-----------------------------------------------------------------------------
  multi method render ( 'md', Str:D $pod-file ) {

    $!involved ~= ', Pod::To::Markdown';

    my Str $md-file;
    if 'doc'.IO ~~ :d {
      $md-file = 'doc/' ~ $pod-file.IO.basename;
    }

    else {
      $md-file = $pod-file.IO.basename;
    }

    $md-file ~~ s/\. <-[.]>+ $/.md/;

    shell "perl6 --doc=Markdown " ~ $pod-file.IO.absolute ~ " > $md-file";
  }

  #-----------------------------------------------------------------------------
  method !html (
    Str $pod-file,
    Str :$style is copy where $_ ~~ any(
          <pod6 default desert doxy sons-of-obsidian sunburst>
        )

    --> Str
  ) {

    $!involved ~= ', Pod::To::HTML, &copy;Google prettify';

    my Str $html = '';

    # Start translation process
    my Proc $p = shell "perl6 --doc=HTML '$pod-file'", :out;

    # search for style line in the head and add a new one
    my @lines = $p.out.lines;
    for @lines -> $line is copy {

      # insert styles and javascript just after meta
      if $line ~~ m:s/ '<meta' 'charset="UTF-8"' '/>' / {

        # copy meta line
        $html ~= "$line\n";

        my $pod-css = 'file://' ~ %?RESOURCES<pod6.css>;
        if $style eq 'pod6' {
          $html ~= qq|  <link type="text/css" rel="stylesheet" href="$pod-css">\n|;
        }

        else {
          $style = 'prettify' if $style eq 'default';
          my $pretty-css = 'file://' ~ %?RESOURCES{"google-code-prettify/$style.css"};
          my $pretty-js = 'file://' ~ %?RESOURCES<google-code-prettify/prettify.js>;

          $html ~= qq|  <link type="text/css" rel="stylesheet" href="$pretty-css">\n|;
          $html ~= qq|  <script type="text/javascript" src="$pretty-js"></script>\n|;
          $html ~= qq|  <link type="text/css" rel="stylesheet" href="$pod-css">\n|;
        }
      }

      # drop perl6 css
      elsif $line ~~ m/^ \s* '<link' \s* 'rel="stylesheet"' \s*
                    'href="//design.perl6.org/perl.css"' \s*
                    '>' $/ {
      }

      # add onload to body element
      elsif $line ~~ m:s/^ \s* '<body ' / {
        $html ~= qq| <body class="pod" onload="prettyPrint()">\n|;
      }

      # add prettyprint classes to pre blocks
      elsif $line ~~ m/^ \s* '<pre' / {
        $line ~~ s/'<pre class="pod-block-code">'/
                   <pre class="prettyprint lang-perl6 linenums">/;
        $html ~= "$line\n";
      }

      # insert extra info in footer element
      elsif $line ~~ m:s/^ \s* '</body>' / {
        $html ~= "<div class=footer>Generated using $!involved\</div>";
        $html ~= "$line\n";
      }

      else {
        $html ~= "$line\n";
      }
#say $line;
    }

#say $html;
    $html;
  }
}

