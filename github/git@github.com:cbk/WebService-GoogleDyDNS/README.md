# WebService::DyDNS [![Build Status](https://travis-ci.org/cbk/WebService-GoogleDyDNS.svg?branch=master)](https://travis-ci.org/cbk/WebService-GoogleDyDNS) 

## SYNOPSIS

Simple web service used to update an IP address on domains.google.com if the current one has changed.
Obtains current IP address using the WebService::HazIP module, then compares the results with the IP
address that was set the last time the service was ran.  It there was a change, the updateIP() method
is then called to update the IP address using the HTTP::UserAgent module.

## TODO
 * Maybe POST request would be better

## Methods
 * checkPreviousIP()
 * updateIP()

## Returns
* One of the response codes from domains.google.com
* "No change. No action taken."

## Example usage:

```
use v6;
use WebService::GoogleDyDNS;

multi sub MAIN( :$domain, :$login, :$password ) {

  my $updater = WebService::GoogleDyDNS.new(domainName => $domain, login => $login , password => $password );
  $updater.checkPreviousIP();
  if $updater.outdated { say $updater.updateIP(); } else { say "No change. No action taken."; }

}
```
