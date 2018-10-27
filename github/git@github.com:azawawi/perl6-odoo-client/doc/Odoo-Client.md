Name
====

Odoo::Client - A simple Odoo ERP client that uses JSON RPC

Synopsis
========

    use v6;
    use Odoo::Client;

    my $odoo = Odoo::Client.new(
        hostname => "localhost",
        port     => 8069
    );

    my $uid = $odoo.login(
        database => "<database>",
        username => '<email>',
        password => "<password>"
    );

    printf("Logged on with user id '%d'\n", $uid);

Description
===========

A simple [Odoo](http://odoo.com) ERP client that uses JSON RPC.

Documentation
=============

Attributes
----------

Methods
-------

### new(Str :$hostname, Int :$port)

Returns a Odoo::Client object that is associated with Odoo instance. You need to call `login` to actually start doing useful operations.

### version returns Hash

Returns a hash of Odoo version information.

### login(Str :$database, Str :$username, Str :$password) {

Logins to the Odoo database with provided authentication credentials.

### invoke(Str :$model, Str :$method, :$method-args)

Invoke a method on a model and returns its results

### model(Str $name)

Returns an `Odoo::Client::Model` model. This is a helper method.

See Also
========

  * [JSON::RPC](https://github.com/bbkr/jsonrpc)

  * [Odoo ERP](http://odoo.com)

  * [JSON-RPC Library](https://www.odoo.com/documentation/10.0/howtos/backend.html#json-rpc-library)

Author
======

Ahmad M. Zawawi, [azawawi](https://github.com/azawawi) on `#perl6`

LICENSE
=======

MIT License
