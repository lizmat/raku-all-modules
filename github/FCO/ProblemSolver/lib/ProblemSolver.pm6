use ProblemSolver::State;
unit class ProblemSolver;

has Bool					$.stop-on-first-solution				= False;
has Bool					$!found-solution						= False;
has Array of Callable		%!constraints{Signature};
has							$!variables		handles <add-variable>	= ProblemSolver::State.new;
#has	ProblemSolver::State	$!variables		handles <add-variable>	.= new;
has							&.print-found	is rw;
has Array of Callable		%!heuristics;

method add-constraint(&const) {
	%!constraints{&const.signature}.push: &const
}

method add-heuristic($var, &heu) {
	%!heuristics{$var}.push: &heu
}

method solve {
	for $!variables.found-vars -> $key {
		self!remove-values($!variables, :variable($key), :value($!variables.get($key))) if %!heuristics{$key}:exists;
	}
	self!solve-all($!variables)
}

method !solve-all($todo) {
	do if $todo.found-everything {
		my %tmp = $todo.found-hash;
		do if self!run-constraints(%tmp, :debug) {
			$!found-solution = True;
			%tmp
		}
	} else {
		my @resp;
		my $key = $todo.next-var;
		for $todo.iterate-over($key) -> $new {
			next unless self!run-constraints($new.found-hash) or $new.has-empty-vars;
			self!remove-values($new, :variable($key), :value($new.get($key))) if %!heuristics{$key}:exists;
			&!print-found($new.found-hash) if &!print-found;
			@resp.push: self!solve-all($new);
			last if $!stop-on-first-solution and $!found-solution
		}
		|@resp
	}
}

method !remove-values($todo, Str :$variable, :$value) {
	if %!heuristics{$variable}:exists {
		for @( %!heuristics{$variable} ) -> &func {
			func($todo, $value)
		}
	}
}

method !run-constraints(%values, :$debug) {
	my @cons = self!get-constraints-for-vars(%values);
	for @cons -> &func {
		return False if not func(|%values)
	}
	True
}

method !get-constraints-for-vars(%vars) {
	my @keys = %!constraints.keys.grep: -> \sig { %vars ~~ sig }
	|%!constraints{@keys}.map: |*
}

method constraint-vars(&red, @vars) {
	my $pars = &red.signature.params.elems;
	my @comb = @vars.combinations($pars);
	for @comb -> @pars {
		my $sig = @pars.map({":\${$_}!"}).join(", ");
		my $cal = @pars.map({"\${$_}"}).join(", ");
		use MONKEY-SEE-NO-EVAL;
		my &func = EVAL "-> $sig, | \{ red($cal)\}";
		no MONKEY-SEE-NO-EVAL;
		$.add-constraint(&func)
	}
	for @vars -> $var {
		my @v = @vars.grep(* !eq $var);
		$.add-heuristic($var, -> $todo, $value {
			for @v (&) $todo.not-found-vars -> $var {
				$todo.find-and-remove-from: $var.key, -> $v { not red($v, $value) }
			}
		})
	}
}

method unique-vars(@vars) {
	my @comb = @vars.combinations(2);
	for @comb -> @pars {
		my $sig = @pars.map({":\${$_}!"}).join(", ");
		my $cal = @pars.map({"\${$_}"}).join(", ");
		use MONKEY-SEE-NO-EVAL;
		my &func = EVAL "-> $sig, | \{ [!~~] $cal \}";
		no MONKEY-SEE-NO-EVAL;
		$.add-constraint(&func)
	}
	for @vars -> $var {
		my @v = @vars.grep(* !eq $var);
		$.add-heuristic($var, -> $todo, $value {
			for @v (&) $todo.not-found-vars -> $var {
				$todo.remove-from: $var.key, $value
			}
		})
	}
}

method no-order-vars(+@vars) {
	for @vars -> $var {
		my @v = @vars.grep(* !eq $var);
		$.add-heuristic($var, -> $todo, $value {
			$todo.recursive-remove-from-vars: @v, $value
		})
	}
}

