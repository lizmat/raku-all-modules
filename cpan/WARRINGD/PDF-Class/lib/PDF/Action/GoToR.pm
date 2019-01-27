use v6;

use PDF::COS::Dict;
use PDF::Action;

#| /Action Subtype - GoToR
class PDF::Action::GoToR
    is PDF::COS::Dict
    does PDF::Action {

    # see [PDF 32000 - Table 200 – Additional entries specific to a remote go-to action]
    ## use ISO_32000::Remote_goto_action_additional;
    ## also does ISO_32000::Remote_goto_action_additional;

    use PDF::COS::Tie;
    use PDF::Destination :DestSpecRemote, :coerce-dest;
    use PDF::Filespec :File, :&to-file;

    has File $.F is entry(:alias<file>, :required, :coerce(&to-file)); # (Required) The file in which the destination shall be located.
    has DestSpecRemote $.D is entry(:required, :alias<destination>, :coerce(&coerce-dest)); # (Required) The destination to jump to. If the value is an array defining an explicit destination, its first element shall be a page number within the remote document rather than an indirect reference to a page object in the current document. The first page shall be numbered 0.
    has Bool $.NewWindow is entry; # (Optional; PDF 1.2) A flag specifying whether to open the destination document in a new window. If this flag is false, the destination document replaces the current document in the same window. If this entry is absent, the conforming reader should behave in accordance with its preference.
}
