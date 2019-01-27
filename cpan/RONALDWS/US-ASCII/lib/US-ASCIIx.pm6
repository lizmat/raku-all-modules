use US-ASCII::ABNF::Core::Only;
use US-ASCII::ABNF::Core::More;

use _US-ASCII;

grammar US-ASCIIx:ver<0.6.6>:auth<R Schmidt (ronaldxs@software-path.com)>
    is _US-ASCII
{
    # don't make alnum depend on alpha - RT #130527
    token alpha     { <[A..Za..z]> }
    token alnum     { <[0..9A..Za..z]> }

    my token ALPHA    is export(:UC :POSIX)
        { <.US-ASCIIx::alpha>     }
    my token UPPER    is export(:UC :POSIX)
        { <.US-ASCIIx::upper>     }
    my token LOWER    is export(:UC :POSIX)
        { <.US-ASCIIx::lower>     }
    my token DIGIT    is export(:UC :POSIX)
        { <.US-ASCIIx::digit>     }
    my token XDIGIT   is export(:UC :POSIX)
        { <.US-ASCIIx::xdigit>    }
    my token HEXDIG   is export(:UC)
        { <.US-ASCIIx::hexdig>    }
    my token ALNUM    is export(:UC :POSIX)
        { <.US-ASCIIx::alnum>     }
    my token PUNCT    is export(:UC :POSIX)
        { <.US-ASCIIx::punct>     }
    my token GRAPH    is export(:UC :POSIX)
        { <.US-ASCIIx::graph>     }
    my token BLANK    is export(:UC :POSIX)
        { <.US-ASCIIx::blank>     }
    my token SPACE    is export(:UC  :POSIX)
        { <.US-ASCIIx::space>     }
    my token PRINT    is export(:UC  :POSIX)
        { <.US-ASCIIx::print>     }
    my token CNTRL    is export(:UC  :POSIX)
        { <.US-ASCIIx::cntrl>     }
    my token VCHAR    is export(:UC)
        { <.US-ASCIIx::vchar>     }
    my token WB       is export(:UC)
        { <.US-ASCIIx::wb>        }
    my token WW       is export(:UC)
        { <.US-ASCIIx::ww>        }
    my token IDENT    is export(:UC)
        { <._US-ASCII::IDENT>     }  # can have _, not using ASCIIx::alpha

    my token CRLF     is export(:UC)      { <.US-ASCIIx::CRLF>      }
    my token BIT      is export(:UC)      { <.US-ASCIIx::BIT>       }
    my token CHAR     is export(:UC)      { <.US-ASCIIx::CHAR>      }

    my grammar Core-More does US-ASCII::ABNF::Core::More {};
    my token CTL      is export(:ABNF)    { <.Core-More::CTL>  }
    my token WSP      is export(:ABNF)    { <.Core-More::WSP>  }

    my grammar Core-Only does US-ASCII::ABNF::Core::Only {};
    my token CR       is export(:ABNF)    { <.Core-Only::CR>      }
    my token DQUOTE   is export(:ABNF)    { <.Core-Only::DQUOTE>  }
    my token HTAB     is export(:ABNF)    { <.Core-Only::HTAB>    }
    my token LF       is export(:ABNF)    { <.Core-Only::LF>      }
    my token SP       is export(:ABNF)    { <.Core-Only::SP>      }
    my token OCTET    is export(:ABNF)    { <.Core-Only::OCTET>   }

}
