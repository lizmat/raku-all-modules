use US-ASCII::ABNF::Common;

grammar US-ASCII:ver<0.1.3>:auth<R Schmidt (ronaldxs@software-path.com)>
    does US-ASCII::ABNF::Common
{
    token alpha     { <[A..Za..z]> }
    token upper     { <[A..Z]> }
    token lower     { <[a..z]> }
    token digit     { <[0..9]> }
    token xdigit    { <[0..9A..Fa..f]> }
    token hexdig    { <[0..9A..F]> }
    token alnum     { <[0..9A..Za..z]> }
    # see RT #130527 for why we might need _punct and _space
    token _punct    { <[\-!"#%&'()*,./:;?@[\\\]_{}]> }
    token punct     { <+_punct> }
    token graph     { <+_punct +[0..9A..Za..z]> }
    token blank     { <[\t\ ]> }
    # \n is $?NL - rakudo cheating to get around \x[85], OK for now
    token _space    { $?NL || <[\t\c[LINE TABULATION]\c[FF]\r\ ]> }
    token space     { <+_space> }
    token print     { <+_punct +_space +[0..9A..Za..z]> }
    token cntrl     { <[\x[0]..\x[f]]+[\x[7f]]> }
    token vchar     { <[\x[21]..\x[7E]]> }

#   crlf not working yet
#    token crlf      { <CR><LF> }
    # todo ww, wb others?
    # token NL ??

    constant charset = set chr(0) .. chr(127);
}

# if uou are not using inheritance then US-ASCII::alpha as above is
# easier to read than US-ASCII::ALPHA.  With the role below you can
# compose upper case names of the same regexes/tokens without overwriting
# builtin classes.
role US-ASCII-UC:ver<0.1.3>:auth<R Schmidt (ronaldxs@software-path.com)> 
    does US-ASCII::ABNF::Common
{
    token ALPHA     { <.US-ASCII::alpha> }
    token UPPER     { <.US-ASCII::upper> }
    token LOWER     { <.US-ASCII::lower> }
    token DIGIT     { <.US-ASCII::digit> }
    token XDIGIT    { <.US-ASCII::xdigit> }
    token HEXDIG    { <.US-ASCII::hexdig> }
    token ALNUM     { <.US-ASCII::alnum> }
    token PUNCT     { <.US-ASCII::punct> }
    token GRAPH     { <.US-ASCII::graph> }
    token BLANK     { <.US-ASCII::blank> }
    token SPACE     { <.US-ASCII::space> }
    token PRINT     { <.US-ASCII::print> }
    token CNTRL     { <.US-ASCII::cntrl> }
    token VCHAR     { <.US-ASCII::vchar> }
#    token CRLF      { <.US-ASCII::crlf>  }

    # believied only useful for ABNF grammar
    token HTAB      { <[\t]> }
    token DQUOTE    { <["]> }

    # invoke with autopun as US-ASCII-UC.charset
    method charset { US-ASCII::charset }
}
