use v6;

use PDF::Annot;

class PDF::Annot::Popup
    is PDF::Annot {

    use PDF::COS::Tie;
    use PDF::COS::Name;

    # See [PDF 32000 Table 183 – Additional entries specific to a pop-up annotation]
    ## use ISO_32000::Popup_annotation_additional;
    ## also does ISO_32000::Popup_annotation_additional;

    has PDF::Annot $.Parent is entry(:indirect); # (Optional; shall be an indirect reference) The parent annotation with which this pop-up annotation shall be associated.
    has Bool $.Open is entry; # Optional) A flag specifying whether the pop-up annotation shall initially be displayed open. Default value: false (closed).

}
