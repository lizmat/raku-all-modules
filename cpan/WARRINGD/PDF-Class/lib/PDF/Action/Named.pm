use v6;

use PDF::Action;
use PDF::COS::Dict;

#| /Action Subtype - GoTo

class PDF::Action::Named
    is PDF::COS::Dict
    does PDF::Action {

    # see [PDF 32000 Table 212 – Additional entries specific to named actions]
    ## use ISO_32000::Named_action_additional;
    ## also does ISO_32000::Named_action_additional;
    use PDF::COS::Tie;
    use PDF::COS::Name;

    my subset ActionName of PDF::COS::Name where 'NextPage'|'PrevPage'|'FirstPage'|'LastPage';
    has ActionName $.N is entry(:required, :alias<action-name>); # (Required) The name of the action that shall be performed.

}
