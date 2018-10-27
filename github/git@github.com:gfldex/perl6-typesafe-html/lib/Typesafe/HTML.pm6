use v6;

class HTML is export {
	has $.the-str is rw;
	method new (Str $s = '') { self.bless(the-str=>$s) }
	method Str () is nodal { $.the-str }
	method perl (){ "HTML.new('{$.the-str.subst(Q{\}, Q{\\}, :g).subst(<'>, <\'>, :g).subst("\n",Q{\\n}, :g)}');"; }
	proto method utf8-to-htmlentity (|) is export {*};
	multi method utf8-to-htmlentity (Str:D \s) is nodal {
		s.subst('&', '&amp;', :g).subst('<', '&lt;', :g)
	}
	multi method utf8-to-htmlentity (Str:D @a) is nodal {
		@a>>.utf8-to-htmlentity()
	}
	multi method utf8-to-htmlentity (HTML:D \h) is nodal {
		h
	}
}

multi sub infix:<~>(HTML:D \l, Str:D \r) is export {
	l.new( l.Str ~ l.utf8-to-htmlentity(r) );
}

multi sub infix:<~>(HTML:D \l, HTML:D \r) is export {
	l.new( l.the-str ~ r.the-str );
}

multi sub infix:<~>(Str:D \l, HTML:D \r) is export {
	r.new( r.utf8-to-htmlentity(l) ~ r.Str );
}

