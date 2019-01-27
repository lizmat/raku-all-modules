use _US-ASCII;
use US-ASCII::ABNF::Core::Common;

# internal use only
# lexical role hides ALPHAx and ALNUMx from US-ASCII-ABNF
my role _US-ASCII-UC
    does US-ASCII::ABNF::Core::Common
{
    token ALPHA     { <._US-ASCII::alpha> }
    token UPPER     { <._US-ASCII::upper> }
    token LOWER     { <._US-ASCII::lower> }
    token DIGIT     { <._US-ASCII::digit> }
    token XDIGIT    { <._US-ASCII::xdigit> }
    token HEXDIG    { <._US-ASCII::hexdig> }
    token ALNUM     { <._US-ASCII::alnum> }
    token PUNCT     { <._US-ASCII::punct> }
    token GRAPH     { <._US-ASCII::graph> }
    token BLANK     { <._US-ASCII::blank> }
    token SPACE     { <._US-ASCII::space> }
    token PRINT     { <._US-ASCII::print> }
    token CNTRL     { <._US-ASCII::cntrl> }
    token VCHAR     { <._US-ASCII::vchar> }

    token WB        { <._US-ASCII::wb> }
    token WW        { <._US-ASCII::ww> }

    token IDENT     { <._US-ASCII::ident> }
    # invoke with autopun as US-ASCII-UC.charset
    method charset { _US-ASCII::charset }
}
