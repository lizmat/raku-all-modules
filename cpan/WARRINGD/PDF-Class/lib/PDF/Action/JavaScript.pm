use v6;

use PDF::Action;
use PDF::COS::Dict;

#| /Action Subtype - GoTo

class PDF::Action::JavaScript
    is PDF::COS::Dict
    does PDF::Action {

    # see [PDF 32000 Table 212 – Additional entries specific to named actions]
    ## use ISO_32000::JavaScript_action_additional;
    ## also does ISO_32000::JavaScript_action_additional;

    use PDF::COS::Tie;
    use PDF::COS::Stream;
    use PDF::COS::TextString;

    my subset TextOrStream where PDF::COS::TextString | PDF::COS::Stream;
    multi sub coerce(Str $value is rw, TextOrStream) {
	$value = PDF::COS.coerce( $value, PDF::COS::TextString );
    }
    has TextOrStream $.JS is entry(:required, :&coerce); # (Required) A text string or text stream containing the JavaScript script to be executed. PDFDocEncoding or Unicode encoding (the latter identified by the Unicode prefix U+ FEFF) shall be used to encode the contents of thestring or stream.

}
