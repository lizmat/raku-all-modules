#| role Test::Fuzz::Generator: Role to be "does"ed on the signature param
unit role Test::Fuzz::Generator;
has $.fuzz-generator = True;

method type			{...}
method named		{...}
method constraints	{...}
my role Unique {};

#| Method that generate samples of that param
method generate(Int() $size = 100) {
	my Mu @ret;
	my Mu @undefined;
	my $hcoded;
	$hcoded = self.constraint_list.first({.defined and $_ !~~ Callable});
	my Mu:D $constraints	= self.constraints;
	my \test-type			= self.type;
	my $loaded-types		= set |::.values.grep({not .DEFINITE});
	my $builtin-types		= set |%?RESOURCES<classes>.IO.lines.map({::($_)});
	my $types				= $loaded-types ∪ $builtin-types;
	my @types				= $types.keys.grep(sub (Mu \item) {
		my Mu:U \i = item;
		return so i ~~ test-type;
		CATCH {return False}
	});
	@undefined = @types.grep(sub (Mu \item) {
		my Mu:U \i = item;
		return so i ~~ $constraints;
		CATCH {return False}
	}) unless self.modifier eq ":D";

	my %generator
		<== map({.^name => lazy .generate-samples})
		<== grep({try {lazy .?generate-samples}})
		<== @types
	;

	my %indexes	:= BagHash.new;
	my %gens	:= @types.map(*.^name) ∩ %generator.keys;
	while @ret.elems < $size {
		@ret.push: $hcoded but Unique if $hcoded.defined;
		for %gens.keys -> $sub {
			my $item = %generator{$sub}[%indexes{$sub}++];
			@ret.push: $item if $item ~~ test-type & $constraints;
		}
		@ret .= unique: :with({$^a === $^b and not $^a ~~ Unique})
	}
	@ret.unshift: |@undefined if @undefined;
	@ret
}

