use v6;
use Test;
use Rototo::html;

sub H (*@chunks) { join '', @chunks}

is H(td :selected, "hello")
, "<td selected>hello</td>"
, "boolean attr";

ok H(td :selected, :id<hello>, "hello") ~~
    ( '<td selected id="hello">hello</td>'
    , '<td id="hello" selected>hello</td>')
, "boolean attr + id";

ok H(td :class<old>, :id<hello>, "hello") ~~
    ( '<td class="old" id="hello">hello</td>'
    , '<td id="hello" class="old">hello</td>')
, "2 kv attrs";

ok H(td %(< class old id hello >), "hello") ~~
    ( '<td class="old" id="hello">hello</td>'
    , '<td id="hello" class="old">hello</td>')
, "2 kv attrs, the quoted words way";



is H( div :id<hello>
    , p("hello")
    , p("world"))
, '<div id="hello"><p>hello</p><p>world</p></div>'
, "nested tags";

is H( div :id<hello>
    , p("hello ",a(:href</index.html>, "world"),", how are you")) 
, '<div id="hello"><p>hello <a href="/index.html">world</a>, how are you</p></div>'
, "mixed tags with CDATA";

is H(br), "<br/>","empty tag";
is H(br :selected, :id<foo> ), '<br id="foo" selected/>',"empty tag with attrs";

done-testing;
