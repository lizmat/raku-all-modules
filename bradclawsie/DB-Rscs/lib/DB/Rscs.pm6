use v6;
use HTTP::UserAgent;
use JSON::Tiny;

=begin pod

=head1 NAME

DB::Rscs - A client library for Rscs (https://github.com/bradclawsie/rscs)

=head1 DESCRIPTION

Rscs (the Ridiculously Simple Configuration System) is a simple configuration
database with http daemon support. Rscs only stores keys and values and only
allows simple CRUD operations.

This library is a Perl6 client for Rscs.

=head1 SYNOPSIS

use v6;
use DB::Rscs;

my $rscs = DB::Rscs.new(addr=>'http://localhost:8081');
my $val = 'val1';
my $key = 'key1';
$rscs.insert($key,$val);
my %out = $rscs.get($key);
say %out{$VALUE_KEY};
$rscs.update($key,'a new val');
$rscs.delete($key);

=head1 AUTHOR

Brad Clawsie (PAUSE:bradclawsie, email:brad@b7j0c.org)

=head1 LICENSE

This module is licensed under the BSD license, see: https://b7j0c.org/stuff/license.txt

=end pod

unit module DB::Rscs:auth<bradclawsie>:ver<0.0.2>;

constant $DEFAULT_ADDR is export  = <http://localhost:8081>;
constant $STATUS_PATH is export = '/v1/status';
constant $KV_PATH is export = '/v1/kv';
constant $VALUE_KEY is export = 'Value';

class DB::Rscs is export {
    has HTTP::UserAgent $!http-client;
    has Str $.addr;
    
    submethod BUILD(Str:D :$addr = $DEFAULT_ADDR) {
        $!http-client = HTTP::UserAgent.new();
        $!addr = $addr;
        X::AdHoc.new(:payload<'cannot connect'>).throw unless self.alive.so;
    }

    # Test for live-ness.
    method alive(--> Bool:D) {
        my $resp = $!http-client.get($!addr ~ $STATUS_PATH);
        return $resp ~~ HTTP::Response && $resp.is-success;
    }

    # Get the status result.
    method status(--> Hash:D) {
        my $resp = $!http-client.get($!addr ~ $STATUS_PATH);
        unless $resp ~~ HTTP::Response && $resp.is-success {
            X::AdHoc.new(:payload<$resp>).throw;
        }
        return from-json($resp.decoded-content);
    }

    # Get a value for a key.
    method get(Str:D $key) {
        my $resp = $!http-client.get($!addr ~ $KV_PATH ~ '/' ~ $key);
        unless $resp ~~ HTTP::Response && $resp.is-success {
            X::AdHoc.new(:payload<$resp>).throw;
        }
        return from-json($resp.decoded-content);
    }
    
    # Insert a new key/value.
    method insert(Str:D $key, Str:D $value) {
        my $req = HTTP::Request.new(POST=>$!addr ~ $KV_PATH ~ '/' ~ $key);
        $req.add-content(to-json($VALUE_KEY => $value));
        my $resp = $!http-client.request($req);
        unless $resp ~~ HTTP::Response && $resp.is-success {
            X::AdHoc.new(:payload<$resp>).throw;
        }
    }

    # Update a value for a key.
    method update(Str:D $key, Str:D $value) {
        my $req = HTTP::Request.new(PUT=>$!addr ~ $KV_PATH ~ '/' ~ $key);
        $req.add-content(to-json($VALUE_KEY => $value));
        my $resp = $!http-client.request($req);
        unless $resp ~~ HTTP::Response && $resp.is-success {
            X::AdHoc.new(:payload<$resp>).throw;
        }
    }

    # Delete a key and value.
    method delete(Str:D $key) {
        my $req = HTTP::Request.new(DELETE=>$!addr ~ $KV_PATH ~ '/' ~ $key);
        my $resp = $!http-client.request($req);
        unless $resp ~~ HTTP::Response && $resp.is-success {
            X::AdHoc.new(:payload<$resp>).throw;
        }
    }
}
