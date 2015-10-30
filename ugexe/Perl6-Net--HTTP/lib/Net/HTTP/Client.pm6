use Net::HTTP::Interfaces;
use Net::HTTP::Utils;
use Net::HTTP::Dialer;

# Highest level of HTTP client. Similar to transport, but more user friendly
# i.e. the user can supply simple options instead of creating a custom Transport to 
# to (for example) ignore exceptions for certain status codes
class Net::HTTP::Client does RoundTripper {
    also does Net::HTTP::Dialer;

    method round-trip(Request $req --> Response) { }
}
