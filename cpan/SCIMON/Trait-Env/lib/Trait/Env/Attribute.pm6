use v6.c;
no precompilation;

unit module Trait::Env::Attribute;

use Trait::Env::Exceptions;
use Trait::Env::Shared;

multi sub trait_mod:<is> ( Attribute $attr, :%env ) is export {
    apply-trait( $attr, %env );
}

multi sub trait_mod:<is> ( Attribute $attr, List :$env ) is export {
    apply-trait( $attr, $env.hash );
}


multi sub trait_mod:<is> ( Attribute $attr, :$env ) is export {
    apply-trait( $attr, {} );
}   

sub apply-trait ( Attribute $attr, %settings ) {
    my $env-name = coerce-name( $attr.name, :attr );
    my &build = do given $attr.type {
        when Positional { positional-build( $env-name, $attr, %settings ) };
        when Associative { associative-build( $env-name, $attr, %settings ) };
        default { scalar-build( $env-name, $attr, %settings ) };
    }
    $attr.set_build( &build );
}

sub associative-build ( Str $env-name, Attribute $attr, %settings ) {
    my $type = Associative ~~ $attr.type ?? Any !! $attr.type.^role_arguments[0];
    return -> | {
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
        my $type = Associative ~~ $attr.type ?? Any !! $attr.type.^role_arguments[0];
	if %data.keys {
	    %data.map( -> $p { $p.key => coerce-value( $type, $p.value ) } );
	} elsif %settings<default> {
            %settings<default>;
        } elsif %settings<required> {
            die X::Trait::Env::Required::Not::Set.new( :payload("required attribute {$env-name} not found in ENV") );
        }
    }
}

sub positional-build ( Str $env-name, Attribute $attr, %settings ) {
    my $name-match = /^ "$env-name" .+ $/;
    my $type = Positional ~~ $attr.type ?? Any !! $attr.type.^role_arguments[0];
    return -> | {
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
    };
}

sub scalar-build ( Str $env-name, Attribute $attr, %settings ) {
    my $type = Any ~~ $attr.type ?? Any !! $attr.type;
    return -> $, $default {
        with %*ENV{$env-name} -> $value {
            coerce-value( $attr.type, $value );
        } elsif $default|%settings<default> {
            $default // %settings<default>;
        } elsif %settings<required> {
            die X::Trait::Env::Required::Not::Set.new( :payload("required attribute {$env-name} not found in ENV") );
        } else {
            Any ~~ $attr.type ?? Any !! $attr.type;
        }
    };
}


