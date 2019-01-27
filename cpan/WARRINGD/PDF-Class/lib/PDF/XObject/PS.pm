use v6;

use PDF::XObject;
use PDF::Content::XObject;

#| Postscript XObjects /Type XObject /Subtype PS
#| See [PDF 32000 Section 8.8.2 PostScript XObjects]
class PDF::XObject::PS
    is PDF::XObject
    does PDF::Content::XObject['PS'] {

    # see [PDF 32000 Table 88 - Additional Entries Specific to a postscript xobject Dictionary]
    ## use ISO_32000::Postscript_XObject;
    ## also does ISO_32000::Postscript_XObject;

    use PDF::COS::Tie;
    use PDF::COS::Stream;

    has PDF::COS::Stream $.Level1 is entry; # (Optional) A stream whose contents are to be used in place of the PostScript XObject’s stream when the target PostScript interpreter is known to support only LanguageLevel 1.

}
