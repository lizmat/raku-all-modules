unit module Bitcoin::RPC;

our $VERSION = '0.0.2';

use v6;
use WWW;
use JSON::Fast;
use URI::Escape;
use LWP::Simple;
use Base64::Native;
use Bitcoin::Helpers::Config;

# client for querying the public Bitcoin REST API
# https://bitcoin.org/en/developer-reference
class Client is export {
  has Str $!url;
  has Str $!port;
  has Str $!proto;
  has Str $!user;
  has Str $!password;
  has Str $!auth_header;
  has Str $!api;
  has Bool $.debug is rw = False;
  has UInt $!call_counter = 0;
  has Config $!config;

  submethod BUILD(Str :$url, Bool :$secure) {
    $!config = Config.new;
    $!url = $url;
    $!user = $!config.get-value-for('rpcuser');
    $!password = $!config.get-value-for('rpcpassword');
    $!port = $!config.get-value-for('rpcport');
    $!proto = $secure == True ?? 'https' !! 'http';
    $!auth_header = base64-encode($!user ~ ':' ~ $!password, :str);
    $!api = $!proto ~ '://' ~ $!url ~ ':' ~ $!port ~ '/';
  }
  # execute API command
  method execute(Str $api, *@params) returns Str {
    my Str $call = self!get-command($api);
    given $call ne '' {
      return LWP::Simple.new.post($!api, self!get-request-headers(),
                to-json(self!get-request-parameters($call, @params)));
    }
  }
  method !get-request-parameters(Str $method, *@method_params) {
    my %params =
     'version' => '1.1',
     'method' => $method,
     'params' => @method_params,
     'id' => $!call_counter++
    ;
    return %params;
  }
  # componses HTTP call headers
  method !get-request-headers() {
     my %headers =
      'Host' => 'localhost',
      'User-Agent' => 'Perl6Client/0.1',
      'Authorization' => 'Basic ' ~ $!auth_header,
      'Content-Type' => 'application/json'
     ;
     return %headers;
  }
  # returns API command
  method !get-command($name) returns Str {
    my %commands = <addmultisigaddress
                    addmultisigaddress
                    backupwallet
                    backupwallet
                    createrawtransaction
                    createrawtransaction
                    decoderawtransaction
                    decoderawtransaction
                    dumpprivkey
                    dumpprivkey
                    encryptwallet
                    encryptwallet
                    getaccount
                    getaccount
                    getaccountaddress
                    getaccountaddress
                    getaddressesbyaccount
                    getaddressesbyaccount
                    getbalance
                    getbalance
                    getblock
                    getblock
                    getblockbynumber
                    getblockbynumber
                    getblockcount
                    getblockcount
                    getblockhash
                    getblockhash
                    getconnectioncount
                    getconnectioncount
                    getdifficulty
                    getdifficulty
                    getgenerate
                    getgenerate
                    gethashespersec
                    gethashespersec
                    getinfo
                    getinfo
                    getmemorypool
                    getmemorypool
                    getmininginfo
                    getmininginfo
                    getnewaddress
                    getnewaddress
                    getrawtransaction
                    getrawtransaction
                    getreceivedbyaccount
                    getreceivedbyaccount
                    getreceivedbyaddress
                    getreceivedbyaddress
                    gettransaction
                    gettransaction
                    gettxout
                    gettxout
                    getwork
                    getwork
                    help
                    help
                    importprivkey
                    importprivkey
                    importaddress
                    importaddress
                    keypoolrefill
                    keypoolrefill
                    listaccounts
                    listaccounts
                    listreceivedbyaccount
                    listreceivedbyaccount
                    listreceivedbyaddress
                    listreceivedbyaddress
                    listsinceblock
                    listsinceblock
                    listtransactions
                    listtransactions
                    listunspent
                    listunspent
                    move
                    move
                    sendfrom
                    sendfrom
                    sendmany
                    sendmany
                    sendrawtransaction
                    sendrawtransaction
                    sendtoaddress
                    sendtoaddress
                    setaccount
                    setaccount
                    setgenerate
                    setgenerate
                    settxfee
                    settxfee
                    signmessage
                    signmessage
                    signrawtransaction
                    signrawtransaction
                    stop
                    stop
                    validateaddress
                    validateaddress
                    verifymessage
                    verifymessage
                    walletlock
                    walletlock
                    walletpassphrase
                    walletpassphrase
                    walletpassphrasechange
                    walletpassphrasechange>;
      return %commands{$name};
  }
}

=begin pod
=TITLE Module for querying the Bitcoin REST interface
=AUTHOR Harris Brakmic
This module helps to make queries against the Bitcoin REST interface.
=end pod
