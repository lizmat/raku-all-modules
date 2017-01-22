use v6;

use DNS::Zone::ResourceRecord;
use DNS::Zone::Grammars::Modern;
use DNS::Zone::Grammars::ModernActions;

=begin pod
=head1 Zone class.
	This class represents a DNS zone. It provides methods to load, modify the zone,
	and write a new file.
=head1 Synopsis
=end pod
class DNS::Zone
{

	my subset PositiveInteger of Int where * >= 0;

	has DNS::Zone::ResourceRecord @.rr is rw;

	method gist()
	{
		my $res = "(Zone=\n";
		for @.rr
		{ $res ~= "\t"~.gist~"\n"; }
		$res ~= ")";

		return $res;
	}

	method Str()
	{
		return .Str for @.rr;
	}

	multi method add( DNS::Zone::ResourceRecord :$rr!, PositiveInteger :$position! )
	{
		if $position < @.rr.elems
		{
			@.rr.splice( $position, 0, $rr );
			# @.rr = splice( @.rr, $position-1, 0, $rr ); # Do not work ?
		}
	}

	multi method add( DNS::Zone::ResourceRecord :$rr! )
	{
		push @.rr, $rr;
	}

	multi method add( DNS::Zone::ResourceRecord :@rrs!, PositiveInteger :$position! )
	{
		if $position < @.rr.elems
		{
			@.rr.splice( $position, 0, @rrs );
		}
	}

	multi method add( DNS::Zone::ResourceRecord :@rrs! )
	{
		push @.rr, $_ for @rrs;
	}

	method del( PositiveInteger :$position! )
	{
		if $position <= @.rr.elems
		{
			@.rr.splice( $position-1, 1 );
		}
	}

	method gen()
	{
		my $res = join "\n", map { .gen() }, @.rr;

		return $res;
	}

	method load( Str :$data! )
	{
		my $actions = DNS::Zone::ModernActions.new;
		my $parsed = DNS::Zone::Grammars::Modern.parse( $data, :$actions );
		if $parsed
		{
			@!rr = $parsed.ast;
		}
		else
		{
			# Throw an error
			die "not parsed!";
		}
	}

	method verify( --> Bool )
	{ ... }
}
