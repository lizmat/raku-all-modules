use v6;

use PDF::Action;
use PDF::COS::Dict;

#| /Action Subtype - URI

class PDF::Action::URI
    is PDF::COS::Dict
    does PDF::Action {

    # see [PDF 32000 - TABLE 206 - Additional entries specific to a URI action]
    ## use ISO_32000::URI_action_additional;
    ## also does ISO_32000::URI_action_additional;

    use PDF::COS::Tie;
    use PDF::COS::ByteString;
    use PDF::COS::Bool;
    use PDF::COS::Name;

    has PDF::COS::ByteString $.URI is entry(:required); # (Required) The uniform resource identifier to resolve, encoded in 7-bit ASCII.
    has PDF::COS::Bool $.IsMap is entry;                # (Optional) A flag specifying whether to track the mouse position when the URI is resolved. Default value: false. This entry applies only to actions triggered by the user’s clicking an annotation; it shall be ignored for actions associated with outline items or with a document’s OpenAction entry.


}
