use v6;

use PDF::Action;
use PDF::COS::Dict;

#| /Action Subtype - GoTo
class PDF::Action::GoTo
    is PDF::COS::Dict
    does PDF::Action {

    # see [PDF 32000 Table 199 - Additional entries specific to a go-to action]
    ## use ISO_32000::Goto_action_additional;
    ## also does ISO_32000::Goto_action_additional;
    use PDF::COS::Tie;
    use PDF::COS::Name;
    use PDF::Destination :DestSpec, :coerce-dest;
    has DestSpec $.D is entry(:required, :alias<destination>, :coerce(&coerce-dest));    # (Required) The destination to jump to

}
