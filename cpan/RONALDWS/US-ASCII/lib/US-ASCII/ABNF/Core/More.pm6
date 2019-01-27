use US-ASCII::ABNF::Core::P6Common;

# ABNF duplicates of p6 character classes
# restricted to ASCII by P6Common

unit role US-ASCII::ABNF::Core::More:ver<0.1.2>:auth<R Schmidt (ronaldxs@software-path.com)>;

token CTL       { <.US-ASCII::ABNF::Core::P6Common-g::cntrl>   }
token WSP       { <.US-ASCII::ABNF::Core::P6Common-g::blank>   }
