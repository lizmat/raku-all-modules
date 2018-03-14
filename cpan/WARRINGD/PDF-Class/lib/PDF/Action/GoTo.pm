use v6;

use PDF::Action;

#| /Action Type - GoTo

role PDF::Action::GoTo
    does PDF::Action {

    # see [PDF 1.7 TABLE 8.49 Additional entries specific to a go-to action]
    use PDF::COS::Tie;

    has $.D is entry(:required, :alias<destination>);    #| (Required) The destination to jump to (see Section 8.2.1, “Destinations”).

}
