use v6;

use PDF::COS::Dict;
use PDF::Class::Type;

#| /Type /OutputIntent

class PDF::OutputIntent
    is PDF::COS::Dict
    does PDF::Class::Type['Type', 'S'] {

    use PDF::COS::Tie;
    use PDF::COS::Name;
    my subset Name-OutputIntent of PDF::COS::Name where 'OutputIntent';
    has Name-OutputIntent $.Type is entry;
    has PDF::COS::Name $.S is entry(:required); #| (Required) The output intent subtype; must be GTS_PDFX for a PDF/X output intent.
    # see also PDF::OutputIntent::GTS_PDFX

}
