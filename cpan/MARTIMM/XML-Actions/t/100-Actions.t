use v6;

use XML::Actions;
use Test;

#-------------------------------------------------------------------------------
my $dir = 't/x';
mkdir $dir unless $dir.IO ~~ :e;

my Str $file = "$dir/a.xml";
$file.IO.spurt(Q:q:to/EOXML/);
  <scxml xmlns="http://www.w3.org/2005/07/scxml"
         version="1.0"
         initial="hello">

    <final id="hello">
      <onentry>
        <log expr="'hello world'" />
      </onentry>
    </final>
  </scxml>
  EOXML

#-------------------------------------------------------------------------------
class A is XML::Actions::Work {

  has Bool $.log-done = False;

  method final ( Array $parent-path, :$id ) {
    is $id, 'hello', "final called: id = $id";
    is $parent-path[*-1].name, 'final', 'this node is final';
    is $parent-path[*-2].name, 'scxml', 'parent node is scxml';
  }

  method onentry ( Array $parent-path ) {
    is $parent-path[*-1].name, 'onentry', 'this node is onentry';
    is $parent-path[*-2].name, 'final', 'parent node is final';
    is $parent-path[*-3].name, 'scxml', 'parent parents node is scxml';
    is-deeply @$parent-path.map(*.name), <scxml final onentry>,
              "<scxml final onentry> found in parent array";
  }

  method onentry-END ( Array $parent-path ) {
    is $parent-path[*-1].name, 'onentry',
       'this node is onentry after processing children';
  }

  method log ( Array $parent-path, :$expr ) {
    is $expr, "'hello world'", "log called: expr = $expr";
    is-deeply @$parent-path.map(*.name), <scxml final onentry log>,
              "<scxml final onentry log> found in parent array";

    $!log-done = True;
  }
}

#-------------------------------------------------------------------------------
subtest 'Action primitives', {
  my XML::Actions $a;

  throws-like
    { $a .= new(:file<non-existent-file>); },
    X::XML::Actions, message => "File 'non-existent-file' not found";

  throws-like
    { $a .= new(); $a.process(:actions(A.new())); },
    X::XML::Actions, message => "No xml document to work on";
}

#-------------------------------------------------------------------------------
subtest 'Action object', {
  my XML::Actions $a .= new(:$file);
  isa-ok $a, XML::Actions, 'type ok';

  my A $w .= new();
  $a.process(:actions($w));
  ok $w.log-done, 'logging done';

#`{{ Cannot compare comlete string because attribs may change order
  note $a.result;
  is $a.result, '<?xml version="1.0"?><scxml xmlns="http://www.w3.org/2005/07/scxml" initial="hello" version="1.0"> <final id="hello"> <onentry> <log expr="&#39;hello world&#39;"/>  </onentry>  </final>  </scxml>', 'returned result ok';
}}
}

#-------------------------------------------------------------------------------
done-testing;

unlink $file;
rmdir $dir;
