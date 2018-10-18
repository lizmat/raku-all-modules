#no precompilation;
unit class Injector::Storage;
use Injector::Bind;

has %!bind{Str:D; Str:D; Str:D};

sub name(Mu:U $_) { S/ <!after ':'> ':' <[UD_]> $// given .^name }

method add(Injector::Bind:D $bind) {
	%!bind{$bind.name.perl; $bind.type.&name; $bind.bind-type} = $bind;
}

method find(::?CLASS:D: Mu:U $type, Str :$name = "") {
	%!bind{$name.perl; $type.&name}:exists
		?? |%!bind{$name.perl; $type.&name}.first.values
		!! Empty
}

method add-obj($obj, :$type = $obj.WHAT, :$name = "", :$override) {
	my @binds = |$.find($type, :$name);
	die "No bind found" unless @binds;
	for @binds {
		.add-obj: $obj, :$override
	}
	?@binds
}
