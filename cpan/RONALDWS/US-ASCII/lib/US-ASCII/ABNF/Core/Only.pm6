# characters from RFC 5234/ABNF Core that are expected only to be
# useful for ABNF and not other P6 parsing

use US-ASCII::ABNF::Core::P6Common;
use US-ASCII::ABNF::Core::Common;

unit role  US-ASCII::ABNF::Core::Only:ver<0.1.2>:auth<R Schmidt (ronaldxs@software-path.com)>;

# These probably don't need to be character classes but I am not clear
# on the rules for combining non-char class with char class in <+ ...>
token LF        { <[\c[LF]]> }
token CR        { <[\c[CR]]> }
token SP        { <[\ ]> }
token HTAB      { <[\t]> }
token DQUOTE    { <["]> }
token OCTET     { <[\x[0]..\x[FF]]> }

# where does CRLF come from?
token LWSP      {   [
        <.US-ASCII::ABNF::Core::P6Common-g::blank>           |
        <.US-ASCII::ABNF::Core::Common-g::CRLF>
        <.US-ASCII::ABNF::Core::P6Common-g::blank>
    ] * }
