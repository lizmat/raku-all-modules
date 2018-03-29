use v6;

use PDF::Action;

#| /Action Subtype - URI

role PDF::Action::URI
    does PDF::Action {

    # see [PDF 32000-1:2008 TABLE 206 - Additional entries specific to a URI action]
    use PDF::COS::Tie;
    use PDF::COS::ByteString;
    use PDF::COS::Bool;
    has PDF::COS::ByteString $.URI is entry(:required); #| (Required) The uniform resource identifier to resolve, encoded in 7-bit ASCII.
    has PDF::COS::Bool $.IsMap is entry;                #| (Optional) A flag specifying whether to track the mouse position when the URI is resolved (see the discussion following this Table). Default value: false. This entry applies only to actions triggered by the user’s clicking an annotation; it shall be ignored for actions associated with outline items or with a document’s OpenAction entry.

    has PDF::COS::ByteString $.Base is entry;           #| (Optional) The base URI that shall be used in resolving relative URI references. URI actions within the document may specify URIs in partial form, to be interpreted relative to this base address. If no base URI is specified, such partial URIs shall be interpreted relative to the location of the document itself. The use of this entry is parallel to that of the body element <BASE >, as described in the HTML 4.01 Specification
}
