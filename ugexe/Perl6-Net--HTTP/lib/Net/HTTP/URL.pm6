use Net::HTTP::Interfaces;

class Net::HTTP::URL does URL {
    has $.Str;
    method Stringy { $!Str }
    method new($url) { self.bless(:Str($url)) }

    # no, this is not a full grammar - this is a simplistic default implementation
    my grammar Parser {
        token TOP { 
        ^^ <scheme> ':' ['//' [<user-info> '@']? <host> [':' <port>]?]? [<path> || '/'] ['?' <query>]? ['#' <fragment>]? $$
        }
        token scheme    { <.token>+ }
        token user-info { <.token>* ':' <.token>* }
        token host      { [ '[' <+alnum +[:]>+ ']' ] || <+token -[+]>+ }
        token port      { \d ** 1..5     }
        token path      { <+[\S] -[?#]>* }
        token query     { <+[\S] -[#]>*  }
        token fragment  { <+[\S]>*       }
        token token     { <.alnum> || < +  - . > }
    }
    proto method parse(|) {*}
    multi method parse(Net::HTTP::URL:D: |c) { Net::HTTP::URL.parse($!Str, |c) }
    multi method parse(Net::HTTP::URL:U: |c) { Parser.parse(|c) }

    # common interface?
    method scheme   { self.parse<scheme>   andthen return ~$_ }
    method host     { self.parse<host>     andthen return ~$_ }
    method port     { self.parse<port>     andthen return ~$_ }
    method path     { self.parse<path>     andthen return ~$_ }
    method query    { self.parse<query>    andthen return ~$_ }
    method fragment { self.parse<fragment> andthen return ~$_ }
}
