use ProblemSolver::Domain;
unit class ProblemSolver::State;

has 			%.vars;
has 			%.found		= Set.new;
has ::?CLASS	$.parent;

multi method add-variable(Str $name, $value) {
	%!vars{$name} = $value;
	%!found = %!found (|) $name
}

multi method add-variable(Str $name, @set) {
	%!vars{$name} = ProblemSolver::Domain[@set].new
}

method found-hash {
	my @keys = %!found.keys;
	%( @keys Z=> %!vars{@keys} )
}

method found-vars {
	%!found.keys
}

method not-found-vars {
	(%!vars.keys (-) %!found).keys
}

method found-everything {
	%!found ~~ set %!vars.keys
}

method next-var {
	$.not-found-vars.first
}

method has-empty-vars {
	for %!vars{@( $.not-found-vars )} -> $var {
		return True if $var.elems == 0
	}
	return False
}

method iterate-over(Str $var where {not %!found{$_}}) {
	gather for %!vars{$var}.keys -> $val {
		my %tmp		= self.Hash;
		%tmp{$var}	= $val;
		take self.new: :vars(%tmp), :found(%!found (|) $var), :parent(self)
	}
}

method Hash {
	my @keys = %!vars.keys;
	%( @keys Z=> %!vars{@keys} )
}

method get(Str $var where {%!found{$_}}) {
	%!vars{$var}
}

method recursive-find-and-remove-from(Str $var where {not %!found{$_}}, &should-remove) {
	$!parent.recursive-find-and-remove-from($var, &should-remove) if $!parent;
	$.find-and-remove-from($var, &should-remove)
}

method find-and-remove-from(Str $var where {not %!found{$_}}, &should-remove) {
	%!vars{$var} .= find-and-remove(&should-remove);
}

method recursive-remove-from-vars(@vars, $value) {
	$!parent.recursive-remove-from-vars(@vars, $value) if $!parent;
	for (@vars (-) %!found).keys -> $var {
		$.remove-from($var, $value)
	}
}

method remove-from(Str $var where {not %!found{$_}}, $val) {
	my $new = %!vars{$var}.remove($val);
	if $new.elems == 1 {
		%!vars{$var} = $new.keys.first;
		%!found (|)= $var
	} else {
		%!vars{$var} = $new;
	}
}
