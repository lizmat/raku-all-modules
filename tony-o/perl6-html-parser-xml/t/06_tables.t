use HTML::Parser::XML;
use Test;
use lib 'lib';

my $html = q:to/END_HTML/;
<html>
  <body>
    <table>
      <tr>
        <td>first</td>
      </tr>
      <tr>
        <td>second</td>
      </tr>
    </table>
  </body>
</html>
END_HTML

sub traverse($doc) {
    sub helper($node) {
        take $node;

        for $node.?nodes -> $child {
            helper($child);
        }
    }

    gather {
        helper($doc.?root // $doc);
    }
}

my $doc = HTML::Parser::XML.new.parse($html);
for traverse($doc) -> $node {
    if $node ~~ XML::Element {
        if $node.name eq 'table' {
            my %tag-count;
            for traverse($node) -> $subnode {
                my $name = $subnode.?name;
                %tag-count{$name}++ if $name;
            }
            is %tag-count<table>, 1;
            is %tag-count<tr>,    2;
            is %tag-count<td>,    2;
        }
    }
}

done;
