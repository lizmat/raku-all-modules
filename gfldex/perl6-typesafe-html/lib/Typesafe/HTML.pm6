use v6;

class HTML is export {
	has $.the-str is rw;
	method new (Str $s = '') { self.bless(the-str=>$s) }
	method Str () is nodal { $.the-str }
	method perl (){ "HTML.new('{$.the-str.subst(Q{\}, Q{\\}, :g).subst(<'>, <\'>, :g).subst("\n",Q{\\n}, :g)}');"; }
	our proto sub utf8-to-htmlentity (|) is export {*};
	our multi sub utf8-to-htmlentity (Str:D \s) is export {
		s.subst('&', '&amp;', :g).subst('<', '&lt;', :g)
	}
	our multi sub utf8-to-htmlentity (Str:D @a) is export {
		@a>>.utf8-to-htmlentity()
	}
	our multi sub utf8-to-htmlentity (HTML:D \h) is export {
		h
	}
}

multi sub infix:<~>(HTML:D \l, Str:D \r) is export {
	HTML.new( l.Str ~ HTML::utf8-to-htmlentity(r) );
}

multi sub infix:<~>(HTML:D \l, HTML:D \r) is export {
	HTML.new( l.the-str ~ r.the-str );
}

multi sub infix:<~>(Str:D \l, HTML:D \r) is export {
	HTML.new( HTML::utf8-to-htmlentity(l) ~ r.Str );
}

