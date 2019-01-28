use v6;

use XML::Actions;
use Test;

#-------------------------------------------------------------------------------
my $dir = 't/x';
mkdir $dir unless $dir.IO ~~ :e;

my Str $file = "$dir/a.xml";
$file.IO.spurt(Q:q:to/EOXML/);
  <html>
    <body>
      <h1>Test for text</h1>
      <!-- Test for comment -->
      <![CDATA[ Test for CDATA]]>
      <?PITarget Test for PI?>
    </body>
  </html>
  EOXML

#-------------------------------------------------------------------------------
class A is XML::Actions::Work {

  method PROCESS-TEXT ( Array $parent-path, Str $text ) {
    return if $text ~~ /^ \s* $/;
    is $text, 'Test for text', "Text '$text' found";
    is $parent-path[*-1].name, 'h1', 'parent node is h1';
  }

  method PROCESS-COMMENT ( Array $parent-path, Str $comment ) {
    is $comment, ' Test for comment ', "Text '$comment' found";
    is $parent-path[*-1].name, 'body', 'parent node is body';
  }

  method PROCESS-CDATA ( Array $parent-path, Str $cdata ) {
    is $cdata, ' Test for CDATA', "Text '$cdata' found";
    is $parent-path[*-1].name, 'body', 'parent node is body';
  }

  method PROCESS-PI ( Array $parent-path, Str $pi-target, Str $pi-content ) {
    is $pi-target, 'PITarget', "Target '$pi-target' found";
    is $pi-content, 'Test for PI', "Text '$pi-content' found";
    is $parent-path[*-1].name, 'body', 'parent node is body';
  }
}

#-------------------------------------------------------------------------------
subtest 'Action object', {
  my XML::Actions $a .= new(:$file);
  isa-ok $a, XML::Actions, 'type ok';

  my A $w .= new();
  $a.process(:actions($w));
}

#-------------------------------------------------------------------------------
done-testing;

unlink $file;
rmdir $dir;
