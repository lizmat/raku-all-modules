use v6;

use PDF::XObject;
use PDF::Image;

#| /Type XObject /Subtype /Image
#| See [PDF 32000 Section 8.9 - Images ]
class PDF::XObject::Image
    is PDF::XObject
    does PDF::Image {

}
