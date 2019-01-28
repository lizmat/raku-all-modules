NAME
====

`Cro::RPC::JSON` - convenience shortcut for JSON-RPC 2.0

SYNOPSIS
========

    use Cro::HTTP::Server;
    use Cro::HTTP::Router;
    use Cro::RPC::JSON;

    class JRPC-Actor is export {
        method foo ( Int :$a, Str :$b ) is json-rpc {
            return "$b and $a";
        }

        proto method bar (|) is json-rpc { * }

        multi method bar ( Str :$a! ) { "single named Str param" }
        multi method bar ( Int $i, Num $n, Str $s ) { "Int, Num, Str positionals" }
        multi method bar ( *%options ) { [ "slurpy hash:", %options ] }

        method non-json (|) { "I won't be called!" }
    }

    sub routes is export {
        route {
            post -> "api" {
                my $actor = JRPC-Actor.new;
                json-rpc $actor;
            }
            post -> "api2" {
                json-rpc -> Cro::RPC::JSON::Request $jrpc-req {
                    { to-user => "a string", num => pi }
                }
            }
        }
    }

DESCRIPTION
===========

This module provides a convenience shortcut for handling JSON-RPC requests by exporting `json-rpc` function to be used inside a [Cro::HTTP::Router](https://cro.services/docs/reference/cro-http-router) `post` handler. The function takes one argument which could either be a [`Code`](https://docs.perl6.org/type/Code.html) object or an instantiated class.

When code object is used:

    json-rpc -> $jrpc-request { ... }

    sub jrpc-handler ( Cro::RPC::JSON::Request $jrpc-request ) { ... }
    json-rpc -> &jrpc-handler;

it is supplied with parsed JSON-RPC request (`Cro::RPC::JSON::Request`).

When a class instance is used a JSON-RPC call is mapped on a class method with the same name as in RPC request. The class method must have `is json-rpc` trait applied (see [SYNOPSIS](#SYNOPSIS) example). Methods without the trait are not considered part of JSON-RPC API and calling such method would return -32601 error code back to the caller.

The class implementing the API is called *JSON-RPC actor class* or just *actor*.

If the only parameter of a JSON-RPC method has `Cro::RPC::JSON::Request` type then the method will receive the JSON-RPC request object as parameter. Otherwise `params` object of JSON-RPC request is used and matched against actor class method signature. If `params` is an object then it is considered a set of named parameters. If it's an array then all params are passed as positionals. For example:

    params => { a => 1, b => "aa" }

will match to 

    method foo ( Int :$a, Str :$b ) { ... }

Whereas

    params => [ 1, "aa" ]

will match to

    method foo( Int $a, Str $b ) { ... }

If parameters fail to match to the method signature then -32601 error would be returned.

To handle various set of parameters one could use either slurpy parameters or `multi` methods. In second case the `is json-rpc` trait must be applied to method's `proto` declaration.

**NOTE** that `multi` method cannot have the request object as a parameter. This is due to possible ambiguity in a situation when there is a match to one `multi` candidate by parameters and by the request object to another.

SEE ALSO
========

[Cro](https://cro.services)

AUTHOR
======

Vadim Belman <vrurg@cpan.org>

LICENSE
=======

Artistic License 2.0

See the LICENSE file in this distribution.

