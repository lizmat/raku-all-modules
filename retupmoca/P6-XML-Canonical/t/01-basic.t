use v6;
use Test;

plan 13;

use XML::Canonical;

is canonical("<a/>"), "<a></a>", 'Empty node';
is canonical("<a  ><b \n  ><c/></b></a>"), '<a><b><c></c></b></a>', 'nested empty';
is canonical("<a \n  second='b'\nfirst='a'/>"), '<a first="a" second="b"></a>', 'attributes, whitespace, ordering';

is canonical("<a>\r\n Foo Bar\nBaz<b>xyzzy\n woo</b> zz\r\nxx</a>"),
             "<a>\n Foo Bar\nBaz<b>xyzzy\n woo</b> zz\nxx</a>",
             'convert newlines, preserve whitespace in text nodes';

is canonical("<a foo='bar' baz='boo' xmlns='nsa' xmlns:a='nsb' />"),
             "<a xmlns=\"nsa\" xmlns:a=\"nsb\" baz=\"boo\" foo=\"bar\"></a>",
             'namespace declarations before normal attributes';

# order attributes with namespaces
is canonical("<a b:baz=\"b\" foo=\"f\" a:bar=\"b\" xmlns=\"zz\" xmlns:a=\"yy\" xmlns:b=\"xx\"></a>"),
             "<a xmlns=\"zz\" xmlns:a=\"yy\" xmlns:b=\"xx\" foo=\"f\" b:baz=\"b\" a:bar=\"b\"></a>",
             'attributes with namespaces';

# encode special characters
is canonical("<a foo=\"&quot;\">&quot;&amp;&quot;</a>"),
             "<a foo=\"&quot;\">\"&amp;\"</a>",
             'special character escapes';

# turn CDATA into escape text node
is canonical("<a><![CDATA[<woo>]]></a>"),
             "<a>&lt;woo&gt;</a>",
             'strip/convert CDATA';

# remove superflous namespace declarations
# TODO: (needs better test)
is canonical("<a xmlns=''></a>"),
             "<a></a>",
             'remove superflous namespaces';

# subset stuff?
is canonical("<a xmlns=\"foo\"><b></b></a>", :subset('/a/b')),
             "<b xmlns=\"foo\"></b>",
             'pull subset; fold parent xmlns in';

is canonical("<z:a xmlns:z=\"x\" xmlns=\"foo\"><b></b></z:a>", :exclusive, :subset('/z:a/b')),
             "<b></b>",
             'pull subset; exclusive (do not pull parent xmlns)';

is canonical("<a xmlns=\"foo\"><b></b></a>", :exclusive, :subset('/a/b'), :namespaces('#default',)),
             "<b xmlns=\"foo\"></b>",
             'pull subset; fold parent xmlns in (exclusive)';

todo 'NYI', 1;
is canonical("<na:a xmlns:na='foo' xmlns:nb='bar'><nb:b>test</nb:b></na:a>", :exclusive),
             "<na:a xmlns:na=\"foo\"><nb:b xmlns:nb=\"bar\">test</nb:b></na:a>",
             'Drop namespaces down a level when exclusive';
