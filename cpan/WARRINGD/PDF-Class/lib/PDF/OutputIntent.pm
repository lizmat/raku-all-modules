use v6;

use PDF::COS::Tie::Hash;
use PDF::Class::Type;

#| /Type /OutputIntent

role PDF::OutputIntent
    does PDF::COS::Tie::Hash
    does PDF::Class::Type['Type', 'S'] {

    use PDF::COS::Tie;
    use PDF::COS::Name;
    has PDF::COS::Name $.Type is entry where 'OutputIntent';
    has PDF::COS::Name $.S is entry(:required); #| (Required) The output intent subtype; must be GTS_PDFX for a PDF/X output intent.
    # see also PDF::OutputIntent::GTS_PDFX

}
