unit module Bitcoin::RPC;

our $VERSION = '1.0';

use v6;
use WWW;
use JSON::Tiny;

# client for querying the public Bitcoin REST API
# https://github.com/bitcoin/bitcoin/blob/master/doc/REST-interface.md
class Client is export {
  has Str $.url is rw where {$_ ne ''};
  has Str $.port is rw = '8332';
  has Str $!proto = 'http';
  has Str $!root = 'rest';
  has %!api = (tx => 'tx', block => 'block',
                   headers => 'headers', wallet => 'wallet',
                   chaininfo => 'chaininfo', mempool => 'mempool',
                   getutxos => 'getutxos');
  has Bool $.debug is rw = False;
  my Str $Format = 'json';

  # alternative constructor
  multi method new(Str $url, Str $port = '8332',
                   Str $proto = 'http', Str $root = 'rest',
                   %api = (tx => 'tx', block => 'block',
                           headers => 'headers', wallet => 'wallet',
                           chaininfo => 'chaininfo', mempool => 'mempool',
                           getutxos => 'getutxos')) {
      self.bless(:url($url), :port($port), :proto($proto),
                 :root($root), :api(%api));
  }
  # get transaction information
  method getTx(Str $tx-hash,
               Str $format where {$format ne ''} = $Format) returns Str {
    my $target = $!proto ~ '://' ~
                 $.url ~ ':' ~
                 $.port ~ '/' ~
                 $!root ~ '/' ~
                 $%!api<tx> ~ '/' ~
                 $tx-hash ~ '.' ~ $format;
    return self!queryData($target, $format)

  }
  # get block information
  method getBlock(Str $block-hash where {$block-hash ne ''},
                  Str $format where {$format ne ''} = $Format) returns Str {
    my $target = $!proto ~ '://' ~
                 $.url ~ ':' ~
                 $.port ~ '/' ~
                 $!root ~ '/' ~
                 $%!api<block> ~ '/' ~
                 $block-hash ~ '.' ~ $format;
    return self!queryData($target, $format)
  }
  # get block headers
  method getHeaders(UInt $count, Str $block-hash where {$block-hash ne ''},
                    Str $format where {$format ne ''} = $Format) returns Str {
    my $target = $!proto ~ '://' ~
                 $.url ~ ':' ~
                 $.port ~ '/' ~
                 $!root ~ '/' ~
                 $%!api<headers> ~ '/' ~
                 $count ~ '/' ~
                 $block-hash ~ '.json';
    return self!queryData($target, $format)
  }
  # get blockchain info
  method getChainInfo(Str $format where {$format ne ''} = $Format) returns Str {
    my $target = $!proto ~ '://' ~
                 $.url ~ ':' ~
                 $.port ~ '/' ~
                 $!root ~ '/' ~
                 $%!api<chaininfo> ~ '.json';
    return self!queryData($target, $format)
  }
  # get memory pool info (supports only JSON format)
  method getMemPool(Str $format where {$format ne ''} = $Format) returns Str {
    my $target = $!proto ~ '://' ~
                 $.url ~ ':' ~
                 $.port ~ '/' ~
                 $!root ~ '/' ~
                 $%!api<mempool> ~ '/info.json';
    return self!queryData($target, $format)
  }

  # get UTXO set
  method getUtxos(%utxos where {%utxos.elems > 0},
                  Str $format where {$format ne ''} = $Format) returns Str {
    my $target = $!proto ~ '://' ~
                 $.url ~ ':' ~
                 $.port ~ '/' ~
                 $!root ~ '/' ~
                 $%!api<getutxos> ~ '/' ~
                 'checkmempool' ~
                 self!createUtxoQueryPath(%utxos) ~ '.json';
    return self!queryData($target, $format)
  }
  # helper method to concatenate "UTXO"-"UTXO_INDEX"
  method !createUtxoQueryPath(%utxos) returns Str {
    gather for %utxos -> $pair {
        take '/' ~ $pair.key ~ '-' ~ $pair.value;
    }.join();
  }
  # helper method to query Bitcoin API, decode binary data,
  # and pack exceptions, if any
  method !queryData(Str $target,
                     Str $format where {$format ne ''} = $Format) returns Str {
    my $response = '';
    if $format eq 'json' {
      $response = jget($target);
    } else {
      $response = get($target);
    }
    if $response.WHAT === Failure {
       my $ex = $response.exception;
       my $exinfo = $ex.message;
       return to-json('{ "error": "Query Failed", "exception": ' ~ $exinfo ~ ' }');
    }
    if $format eq 'json' {
       return to-json($response);
    }
    elsif $format eq 'bin' {
       $response = $response.decode('utf8-c8');
    }
    return $response;
 }

}

=begin pod
=TITLE Module for querying the Bitcoin REST interface
=AUTHOR Harris Brakmic
This module helps to make queries against the Bitcoin REST interface.
=end pod
