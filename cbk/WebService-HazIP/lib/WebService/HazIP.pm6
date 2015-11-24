#########################################
## Michael D. Hensley
## October 21, 2015
##
## Simple Internet web service used to obtain the
## host's current public addressable IP address.
## Connects to the canihazip.com web site using LWP::Simple
## and returns the data.  Valadates the returned data to
## ensure there is a valid IPv4 address.
##

class WebService::HazIP {
  use LWP::Simple;
  has $IPurl = "http://www.canihazip.com/s";

  method returnIP {
    my $data = LWP::Simple.get($IPurl);
    ## Validate the returned data.  May have to add support for IPv6 soon.
    if $data ~~ / ^^([\d ** 1..3] ** 4 % '.')$$ / { return $data; }
    else  { return "ERROR! - No Internet connection."; }
  }
}
