unit module Verge::RPC;

our $VERSION = '0.0.2';

use v6;
use WWW;
use JSON::Fast;
use URI::Escape;
use LWP::Simple;
use Base64::Native;
use Verge::Helpers::Config;

# client for querying the public Verge REST API
# https://vergecurrency.com/langs/en/#developers
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
    my %commands = <help
                    help
                    stop
                    stop
                    getblockcount
                    getblockcount
                    getconnectioncount
                    getconnectioncount
                    getpeerinfo
                    getpeerinfo
                    getdifficulty
                    getdifficulty
                    getgenerate
                    getgenerate
                    setgenerate
                    setgenerate
                    gethashespersec
                    gethashespersec
                    getinfo
                    getinfo
                    getmininginfo
                    getmininginfo
                    getnewaddress
                    getnewaddress
                    getnewpubkey
                    getnewpubkey
                    getaccountaddress
                    getaccountaddress
                    setaccount
                    setaccount
                    getaccount
                    getaccount
                    getaddressesbyaccount
                    getaddressesbyaccount
                    sendtoaddress
                    sendtoaddress
                    getreceivedbyaddress
                    getreceivedbyaddress
                    getreceivedbyaccount
                    getreceivedbyaccount
                    listreceivedbyaddress
                    listreceivedbyaddress
                    listreceivedbyaccount
                    listreceivedbyaccount
                    backupwallet
                    backupwallet
                    keypoolrefill
                    keypoolrefill
                    walletpassphrase
                    walletpassphrase
                    walletpassphrasechange
                    walletpassphrasechange
                    walletlock
                    walletlock
                    encryptwallet
                    encryptwallet
                    validateaddress
                    validateaddress
                    validatepubkey
                    validatepubkey
                    getbalance
                    getbalance
                    move
                    movecmd
                    sendfrom
                    sendfrom
                    sendmany
                    sendmany
                    addmultisigaddress
                    addmultisigaddress
                    getrawmempool
                    getrawmempool
                    getblock
                    getblock
                    getblockbynumber
                    getblockbynumber
                    getrawblockbynumber
                    getrawblockbynumber
                    getblockhash
                    getblockhash
                    gettransaction
                    gettransaction
                    listtransactions
                    listtransactions
                    listaddressgroupings
                    listaddressgroupings
                    signmessage
                    signmessage
                    verifymessage
                    verifymessage
                    getwork
                    getwork
                    getworkex
                    getworkex
                    listaccounts
                    listaccounts
                    settxfee
                    settxfee
                    getblocktemplate
                    getblocktemplate
                    submitblock
                    submitblock
                    listsinceblock
                    listsinceblock
                    dumpprivkey
                    dumpprivkey
                    importprivkey
                    importprivkey
                    listunspent
                    listunspent
                    getrawtransaction
                    getrawtransaction
                    createrawtransaction
                    createrawtransaction
                    decoderawtransaction
                    decoderawtransaction
                    signrawtransaction
                    signrawtransaction
                    sendrawtransaction
                    sendrawtransaction
                    getcheckpoint
                    getcheckpoint
                    reservebalance
                    reservebalance
                    checkwallet
                    checkwallet
                    repairwallet
                    repairwallet
                    resendtx
                    resendtx
                    makekeypair
                    makekeypair
                    sendalert
                    sendalert
                    getnewstealthaddress
                    getnewstealthaddress
                    liststealthaddresses
                    liststealthaddresses
                    importstealthaddress
                    importstealthaddress
                    sendtostealthaddress
                    sendtostealthaddress
                    scanforalltxns
                    scanforalltxns
                    scanforstealthtxns
                    scanforstealthtxns
                    smsgenable
                    smsgenable
                    smsgdisable
                    smsgdisable
                    smsglocalkeys
                    smsglocalkeys
                    smsgoptions
                    smsgoptions
                    smsgscanchain
                    smsgscanchain
                    smsgscanbuckets
                    smsgscanbuckets
                    smsgaddkey
                    smsgaddkey
                    smsggetpubkey
                    smsggetpubkey
                    smsgsend
                    smsgsend
                    smsgsendanon
                    smsgsendanon
                    smsginbox
                    smsginbox
                    smsgoutbox
                    smsgoutbox
                    smsgbuckets
                    smsgbuckets>;
      return %commands{$name};
  }
}

=begin pod
=TITLE Module for querying the Verge REST interface
=AUTHOR Harris Brakmic
This module helps to make queries against the Verge REST interface.
=end pod
