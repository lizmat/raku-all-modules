# perl6-WebService-HazIP


## SYNOPSIS
 Simple Internet web service used to obtain the
 host's current public addressable IP address.
 Connects to the canihazip.com web site using LWP::Simple
 and returns the data.  Valadates the returned data to
 ensure there is a valid IPv4 address.  

## TODO
 * Add other services other then www.canihazip.com

## Methods
 * returnIP()
 
## Retruns
* Valid IPv4 address if successful.
* "ERROR! - No Internet connection." on a invalid responce.

## Example
    use WebService::HazIP;
    my $ipObj = WebService::HazIP.new;
    say "My public IP address is: " ~ $ipObj.returnIP();
