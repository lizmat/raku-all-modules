
use v6;

unit class Odoo::Client::Model;

has $.client;
has Str $.name;

method create( %args ) {
    return $.client.invoke(
        model       => $.name,
        method      => 'create',
        method-args => %args
    );
}

method search( *@args ) {
    return $.client.invoke(
        model  => $.name,
        method => 'search',
        method-args  => @args
    );
}

method read( *@args ) {
    return $.client.invoke(
        model  => $.name,
        method => 'read',
        method-args   => @args
    );
}
