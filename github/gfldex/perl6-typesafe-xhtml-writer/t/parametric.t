use v6;
use Test;

use Typesafe::HTML;

class ExtendedHTML is HTML {	
	multi method utf8-to-htmlentity (Str:D \s) is export {
		s.subst('&', '&amp;', :g).subst('<', '&lt;', :g).subst('>', '&gt;', :g);
	}
}

use Typesafe::XHTML::Writer ExtendedHTML, :span, :writer-shall-indent;
writer-shall-indent True;

plan 1;

my $ok-result = q:to/END/;
<span id="foo">
  &lt;span&gt;Hello Camelia!&lt;/span&gt;
</span>
END

is span(id=>'foo', "<span>Hello Camelia!</span>").Str ~ "\n", $ok-result, 'overload utf8-to-htmlentity';
