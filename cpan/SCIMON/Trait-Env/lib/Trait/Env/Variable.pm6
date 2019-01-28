use v6.c;

unit module Trait::Env::Variable;

use Trait::Env::Exceptions;
use Trait::Env::Shared;

multi sub trait_mod:<is> ( Variable $var, :%env ) is export {
    apply-trait( $var, %env );
}

multi sub trait_mod:<is> ( Variable $var, List :$env ) is export {
    apply-trait( $var, $env.hash );
}


multi sub trait_mod:<is> ( Variable $var, :$env ) is export {
    apply-trait( $var, {} );
}   

sub apply-trait( Variable $var, %settings ) {
    my $env-name = coerce-name( $var.name, :!attr );
    $var.var = do given $var.var.WHAT {
        when Positional { positional-build( $env-name, $var, %settings ) };
        when Associative { associative-build( $env-name, $var, %settings ) };
        default { scalar-build( $env-name, $var, %settings ) };
    }
    return $var;
}

sub associative-build ( Str $env-name, Variable $var, %settings ) {
    my $type = Associative ~~ $var.var.WHAT ?? Any !! ( Any ~~ $var.var.VAR.of ?? Any !! $var.var.VAR.of );   
    my %data;
    if ( %settings<sep>:exists && %settings<kvsep> ) {
	%data = do with %settings{"sep", "kvsep"} -> ( $sep, $kvsep ) {
	    %*ENV{$env-name}:exists ?? %*ENV{$env-name}.split($sep).map( -> $str { my ($k, $v ) = $str.split($kvsep); $k => $v; } ) !! {};
	}
    } else {
	%data = ( ( %settings<post_match>) || ( %settings<pre_match>:exists ) ) ?? %*ENV !! ();
	if %settings<post_match>:exists {
	    %data = %data.grep( -> $p { $p.key.ends-with( %settings<post_match> ) } );
	}
	if %settings<pre_match>:exists {
	    %data = %data.grep( -> $p { $p.key.starts-with( %settings<pre_match> ) } );
	}
    }
    if %data.keys {
	%data.map( -> $p { $p.key => coerce-value( $type, $p.value ) } );
    } elsif %settings<default> {
        %settings<default>;
    } elsif %settings<required> {
        die X::Trait::Env::Required::Not::Set.new( :payload("required attribute {$env-name} not found in ENV") );
    }
}

sub positional-build ( Str $env-name, Variable $var, %settings ) {
    my $name-match = /^ "$env-name" .+ $/;
    my $type = Positional ~~ $var.var.WHAT ?? Any !! ( Any ~~ $var.var.VAR.of ?? Any !! $var.var.VAR.of );
    my @values = do with %settings<sep> -> $sep {
	%*ENV{$env-name}:exists ?? %*ENV{$env-name}.split($sep) !! [];
    } else {
        %*ENV.keys.grep( $name-match ).sort.map( -> $k { %*ENV{$k} } );
    }
    if ( ( ! @values ) && ( %*ENV{$env-name}:exists ) ) {
        @values = %*ENV{$env-name}.split( "{$*DISTRO.path-sep}" );
    }
    if @values.elems {
        @values.map( -> $v { coerce-value( $type, $v ) } );
    } elsif %settings<default> {
        %settings<default>;
    } elsif %settings<required> {
        die X::Trait::Env::Required::Not::Set.new( :payload("required attribute {$env-name} not found in ENV") );
    } else {
        $type;
    }
}

sub scalar-build ( Str $env-name, Variable $var, %settings ) {
    my $type = Any ~~ $var.var.WHAT ?? Any !! $var.var.WHAT;
    with %*ENV{$env-name} -> $value {
        coerce-value( $type, $value );
    } elsif %settings<default> {
        %settings<default>;
    } elsif %settings<required> {
        die X::Trait::Env::Required::Not::Set.new( :payload("required attribute {$env-name} not found in ENV") );
    } else {
        $type;
    }
}
