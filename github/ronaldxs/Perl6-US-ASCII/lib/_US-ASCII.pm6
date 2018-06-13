# todo same ???

use US-ASCII::ABNF::Core::Common;
use US-ASCII::ABNF::Core::P6Common;

# Internal use only
# hide alpha_x and alnum_x from US-ASCIIx
grammar _US-ASCII
    does US-ASCII::ABNF::Core::Common
    does US-ASCII::ABNF::Core::P6Common
{
    token upper     { <[A..Z]> }
    token lower     { <[a..z]> }
    token xdigit    { <[0..9A..Fa..f]> }
    # don't make alnum depend on alpha - RT #130527
    token alpha     { <[A..Za..z_]> }
    token alnum     { <[0..9A..Za..z_]> }

    # see RT #130527 for why we might need _punct
    token _punct    { <[\-!"#%&'()*,./:;?@[\\\]_{}]> }
    token punct     { <+_punct> }
    token graph     { <+_punct +[0..9A..Za..z]> }
    token space-cc  { <[\t\c[VT]\c[FF]\c[LF]\c[CR]\ ]> }
    token space     { "\c[CR]\c[LF]" | <+space-cc> }
    token print-cc  { <+_punct +space-cc +[0..9A..Za..z]> }
    token print     { "\c[CR]\c[LF]" | <+print-cc> }

    token wb        { <?after <._US-ASCII::alnum>><!_US-ASCII::alnum>  |
                      <!after <._US-ASCII::alnum>><?_US-ASCII::alnum>
                    }
    token ww        { <?after <_US-ASCII::alnum>><?_US-ASCII::alnum>  }
    token ident     { <wb><._US-ASCII::alpha><._US-ASCII::alnum>* }
#    token ident     { .* }

    constant charset = set chr(0) .. chr(127);
}
