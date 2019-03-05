use v6;

unit module Trait::Env::Shared;

sub coerce-name ( Str \name, Bool :$attr ) is export {
    my $env-name = name.substr($attr ?? 2 !! 1).uc;
    $env-name ~~ s:g/'-'/_/;
    $env-name;
}

sub coerce-value( Mu $type, $value ) is export {
    if ( Bool ~~ $type && so $value ~~ m:i/"false"|"true"/ ) {
        so $value ~~ m:i/"true"/;
    } else {
        Any ~~ $type ?? $value !! $type($value);
    }
}
