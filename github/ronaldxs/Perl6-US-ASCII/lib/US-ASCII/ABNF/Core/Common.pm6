# BIT and CRLF are ABNF but also imagined to useful token rules for p6
#

 role US-ASCII::ABNF::Core::Common:ver<0.1.5>:auth<R Schmidt (ronaldxs@software-path.com)> {

token BIT   { <[01]> } # either ASCII digit 0 or 1
token CRLF  { \c[CR]\c[LF] }
token CHAR  { <[\x[01]..\x[7F]]> }

}

grammar US-ASCII::ABNF::Core::Common-g:ver<0.1.0>:auth<R Schmidt (ronaldxs@software-path.com)> does US-ASCII::ABNF::Core::Common {}
