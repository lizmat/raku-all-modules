=begin pod 

=head1 NAME

C<Cro::RPC::JSON::Message> – classes implementing C<Cro::Message> interface

=head1 DESCRIPTION

The following classes are used by C<Cro::RPC::JSON>:

=item C<Cro::RPC::JSON::Message> -- Interface role
=item C<Cro::RPC::JSON::Request> -- JSON-RPC request class
=item C<Cro::RPC::JSON::Response> -- JSON-RPC response class

=end pod
use Cro::Message;
use Cro::RPC::JSON::Exception;

# The only version we support now.
subset JRPCVersion of Str where * ~~ "2.0";

subset JRPCId where * ~~ Str | Int;

subset JRPCMethod of Str where * ~~ /^ <!before rpc\.>/;

subset JRPCErrCode of Int where * ~~ (-32700 | (-32603..-32600) | (-32099..-32000));

class Cro::RPC::JSON::Request { ... }
class Cro::RPC::JSON::MethodResponse { ... }

=begin pod

=head1 Cro::RPC::JSON::Message

Declares attributes:

=item C<$.jsonrpc> – contains JSON-RPC version
=item C<$.id> – id field if defined in the RPC request

=end pod

role Cro::RPC::JSON::Message does Cro::Message is export {
    has JRPCVersion $.jsonrpc; # Version string
    has JRPCId $.id;
}

class Cro::RPC::JSON::BatchRequest does Cro::RPC::JSON::Message is export {
    has Cro::RPC::JSON::Request @.requests;
}

=begin pod

=head1 Cro::RPC::JSON::Request

Defines following attributes:

=item C<$.method> – request method name
=item C<$.params> – request parameters
=item C<%.data> – parsed raw request body.
=item C<$.invalid> – Undefined if request is valid; otherwise contains error message explaining the cause.

C<$.invalid> would be set by one of C<set-*> methods below.

=end pod

class Cro::RPC::JSON::Request does Cro::RPC::JSON::Message is export {
    has Cro::RPC::JSON::BatchRequest $.batch;
    has JRPCMethod $.method;
    has $.params;
    has %.data;         # Parsed body of the request
    has $.invalid;      # Will contain error message if request object was invalid

    submethod TWEAK {
        if not %!data<jsonrpc>:exists {
            $!invalid = "Missing required 'jsonrpc' key";
        }
        else {
            for %!data.keys -> $param {
                self."set-$param"( %!data{$param} );
                CATCH {
                    when X::Cro::RPC::JSON::InvalidRequest {
                        $!invalid = .msg;
                    }
                    default {
                        .rethrow
                    }
                }
            }
        }
    }

    #| Sets and validates $.jsonrpc
    method set-jsonrpc ( $jsonrpc ) {
        X::Cro::RPC::JSON::InvalidRequest.new( :msg("Invalid jsonrpc version: $jsonrpc") ).throw
            unless $jsonrpc ~~ JRPCVersion;
        $!jsonrpc = $jsonrpc;
    }

    #| Sets and validates $.id
    method set-id ($id) {
        X::Cro::RPC::JSON::InvalidRequest.new( :msg("Invalid id value: $id of type " ~ $id.WHO) ).throw
            unless $id ~~ JRPCId;
        $!id = $id;
    }

    #| Sets and validates $.method
    method set-method ( $method ) {
        X::Cro::RPC::JSON::InvalidRequest.new( :msg("Invalid method name: $method") ).throw
            unless $method ~~ JRPCMethod;
        $!method = $method;
    }

    #| Sets $.params
    method set-params ( $!params ) {}

    #| Returns true if this request is just a notification (i.e. doesn't have id set)
    method is-notification {
        not %!data<id>:exists
    }
}

class Cro::RPC::JSON::BatchResponse does Cro::Message is export {
    has Cro::RPC::JSON::MethodResponse @.responses;
}

class Cro::RPC::JSON::Error {
    has JRPCErrCode $.code is required;
    has Str $.message is required;
    has $.data is rw;

    method Hash ( --> Hash ) {
        (:$!code, :$!message, |($!data.defined ?? :$!data !! ())).Hash;
    }
}

class Cro::RPC::JSON::MethodResponse does Cro::RPC::JSON::Message is export {
    has $.result is rw;
    has Cro::RPC::JSON::Error $.error is rw;
    has Cro::RPC::JSON::Message $.request is rw;

    submethod TWEAK {
        $!jsonrpc //= "2.0";
    }

    method set-error ( *%err ) {
        $.error = Cro::RPC::JSON::Error.new( |%err );
    }

    method Hash ( --> Hash ) {
        (
            :$.jsonrpc,
            |( $.id.defined ?? :$.id !! () ),
            $.result.defined ?? :$.result !! (
                $.error.defined ?? 
                    :error($.error.Hash) !!
                    Cro::RPC::JSON::Error.new(
                        code => JRPCInternalError,
                        message => "method response contains neither result not error fields",
                        data => {
                            classification => "internal",
                            id => $.request.id,
                            method => $.request.method,
                        },
                    )
            ),
        ).Hash
    }
}

class Cro::RPC::JSON::Response does Cro::Message is export {
    has $.json-body is rw;
}

=begin pod

=head1 SEE ALSO

L<Cro|https://cro.services>

=head1 AUTHOR

Vadim Belman <vrurg@cpan.org>

=head1 LICENSE

Artistic License 2.0

See the LICENSE file in this distribution.

=end pod

# Copyright (c) 2018, Vadim Belman <vrurg@cpan.org>

