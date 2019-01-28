use v6.d;
unit module OO::Plugin::Declarations;
use OO::Plugin::Class;
use OO::Plugin::Registry;
use OO::Plugin::Metamodel::PlugRoleHOW;
use WhereList;

my $pregistry = Plugin::Registry.instance;

sub reg-plug-as-hash ( $routine, %plug, $position ) {
    die "traits 'plug-' in their hash form require 'class' key" unless %plug<class>:exists;
    $pregistry.register-plug( $routine, |%plug<class method>, :$position );
}

sub reg-plug ( $routine, $plug, $position ) {
    for $plug.List -> $p {
        given $p {
            when Pair {
                $pregistry.register-plug( $routine, .key, .value, :$position )
            }
            when Str {
                $pregistry.register-plug( $routine, $_, :$position );
            }
        }
    }
}

multi trait_mod:<is> ( Method:D $routine where { ! $_.multi }, :$plug-around! where * ~~ Hash ) is export {
    reg-plug-as-hash( $routine, $plug-around, 'around' );
}

multi trait_mod:<is> ( Method:D $routine where { ! $_.multi }, :$plug-before! where * ~~ Hash ) is export {
    reg-plug-as-hash( $routine, $plug-before, 'before' );
}

multi trait_mod:<is> ( Method:D $routine where { ! $_.multi }, :$plug-after! where * ~~ Hash ) is export {
    reg-plug-as-hash( $routine, $plug-after, 'after' );
}

multi trait_mod:<is> ( Method:D $routine where { ! $_.multi }, :$plug-around! is copy where * ~~ Positional | Pair:D | Str:D ) is export {
    reg-plug( $routine, $plug-around, 'around' );
}

multi trait_mod:<is> ( Method:D $routine where { ! $_.multi }, :$plug-before! is copy where * ~~ Positional | Pair:D | Str:D ) is export {
    reg-plug( $routine, $plug-before, 'before' );
}

multi trait_mod:<is> ( Method:D $routine where { ! $_.multi }, :$plug-after! is copy where * ~~ Positional | Pair:D | Str:D ) is export {
    reg-plug( $routine, $plug-after, 'after' );
}

multi trait_mod:<is> ( Mu:U \class where { $_.HOW ~~ OO::Plugin::Metamodel::PlugRoleHOW }, :$for! where * ~~ Positional | Str | Mu:U ) {
    $pregistry.register-plug( class, $for.list.flat );
}

multi trait_mod:<is>( Method:D $method, :$pluggable! ) is export {
    $pregistry.register-pluggable( $method );
}

multi trait_mod:<is>( Mu:U \type, :$pluggable! ) is export {
    $pregistry.register-pluggable( type );
}
