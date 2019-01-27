use v6;

use PDF::COS::Dict;
use PDF::Class::Type;
use PDF::Class::ThreeD;

class PDF::ExData::Markup3D
    is PDF::COS::Dict
    does PDF::Class::Type
    does PDF::Class::ThreeD {

    # See [PDF 32000 table 313 - Entries in an external data dictionary used to markup 3D annotations]
    ## use ISO_32000::Three-D_external_data;
    ## also does ISO_32000::Three-D_external_data;

    use PDF::COS::Tie;
    use PDF::COS::Name;

    has PDF::COS::Name  $.Type is entry(:alias<type>) where 'ExData'; # The type of PDF object that this dictionary describes; if present, is ExData for an external data dictionary.
    has PDF::COS::Name  $.Subtype is entry(:required, :alias<subtype>) where 'Markup3D'; # Required) The type of external data that this dictionary describes; shall be Markup3D for a 3D comment. The only defined value is Markup3D.

    has Str $.MD5 is entry; # (Optional) A 16-byte string that contains the checksum of the bytes of the 3D stream data that this 3D comment is associated with. The checksum is calculated by applying the standard MD5 message-digest algorithm to the bytes of the stream data. This value is used to determine if artwork data has changed since this 3D comment was created.
}
