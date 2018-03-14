use v6;

use PDF::XObject;
use PDF::Content::XObject;

#| Postscript XObjects /Type XObject /Subtype PS
#| See [PDF 1.7 Section 4.7.1 PostScript XObjects]
class PDF::XObject::PS
    is PDF::XObject
    does PDF::Content::XObject['PS'] {

    use PDF::COS::Tie;
    use PDF::COS::Stream;
    # see [PDF 1.7 TABLE 4.38 Additional entries specific to a PostScript XObject dictionary]
    has PDF::COS::Stream $.Level1 is entry; #| (Optional) A stream whose contents are to be used in place of the PostScript XObject’s stream when the target PostScript interpreter is known to support only LanguageLevel 1.

}
