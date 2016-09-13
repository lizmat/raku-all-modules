use v6;

unit module List::Combinations;

my %subs;

multi sub combos(@array, Int $of --> Array) is export is DEPRECATED("the Rakudo builtin combinations, it's now much faster (and also lazy if you want). This module will be removed from the ecosystem in the near future.") {
	return [] if $of < 0;
	my int $size = @array.elems;
	return [(),] if $size < 1 || $of < 1;

	if not %subs{$of}:exists {
		my Str $loops = qq/sub combo$of\(\@sarray --> Array) \{\n\tmy int \$ssize = \@sarray.elems;\n\tmy \@results;\n/;
		for ^$of -> $level {
			$loops ~= qq/{"\t" x $level+1}loop (my int \$i$level = {$level == 0 ?? 0 !! '$i' ~ $level-1 ~ '+1'}; \$i$level < \$ssize-{$of-$level-1}; \$i$level++) \{\n/;
		}
		$loops ~= qq/{"\t" x $of+1}\@results.push(({join('], ', map('@sarray[$i' ~ *, ^$of))}]));\n/;
		for ^$of -> $level {
			$loops ~= qq/{"\t" x $of-$level}\}\n/;
		}
		$loops ~= qq/\n\t\@results\n\}/;

		use MONKEY-SEE-NO-EVAL;
		%subs{$of} = EVAL $loops;
	}

	%subs{$of}(@array);
}

multi sub combos(Int $n, Int $k --> Array) is export is DEPRECATED("the Rakudo builtin combinations, it's now much faster (and also lazy if you want). This module will be removed from the ecosystem in the near future.") {
	combos(^$n, $k);
}

multi sub perms (@array --> Array) is export is DEPRECATED("the Rakudo builtin permutations, it's now much faster (and also lazy if you want). This module will be removed from the ecosystem in the near future.") {
	my int $size = @array.elems;
	return [(),] if $size < 1;

	my @a = @array;
	my @results;
	@results.push: @a.List;

	my int @idx = (0) xx $size;
	loop (my int $i = 1; $i < $size; ) {
		if @idx[$i] < $i {
			my int $swap = ($i % 2) * @idx[$i];
			(@a[$i] +^= @a[$swap]) +^= @a[$swap] +^= @a[$i];
			@results.push: @a.List;
			@idx[$i]++;
			$i = 1;
		} else {
			@idx[$i] = 0;
			$i++;
		}
	}

	@results;
}

multi sub perms(Int $n --> Array) is export is DEPRECATED("the Rakudo builtin permutations, it's now much faster (and also lazy if you want). This module will be removed from the ecosystem in the near future.") {
	perms(^$n);
}
