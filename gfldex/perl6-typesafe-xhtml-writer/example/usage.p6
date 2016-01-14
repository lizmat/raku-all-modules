use v6;
use Typesafe::XHTML::Writer :ALL;

put html( xml-lang=>'de',
    body(
        div( id=>"uniq",
          p( class=>"abc", 'your text here'),
          p( 'more text' ),
          '<p>this will be quoted with &lt; and &amp;</p>'
        )
    ));

put span('<b>this will also be quoted with HTML-entities</b>');

use v6;
use Typesafe::XHTML::Writer :p, :title;
use Typesafe::XHTML::Skeleton;

put xhtml-skeleton(p('Hello Camelia!', class=>'foo'), 'Camelia can quote all the <<<< and &&&&.', header=>(title('Hello Camelia'), style('p.foo { color: #fff; }' )));

