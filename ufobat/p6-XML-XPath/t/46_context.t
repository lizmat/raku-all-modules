use v6.c;

use Test;
use XML::XPath;

plan 1;

my $x = XML::XPath.new(xml => q:to/ENDXML/);
<text>
  <para>
    I start the text here, I break
    the line and I go on, I <blink>twinkle</blink> and then I go on
    again.
    This is not a new paragraph.
  </para>
  <para>
    This is a
    <important>new</important> paragraph and
    <blink>this word</blink> has a preceding sibling.
  </para>
</text>
ENDXML

is-deeply
$x.find("text/para/node()[position()=last() and preceding-sibling::important]"),
$x.find("text/para/node()[preceding-sibling::important and position()=last()]"),
'both expressions are the same';

done-testing();
