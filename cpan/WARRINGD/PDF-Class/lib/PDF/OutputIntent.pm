use v6;

use PDF::DAO::Dict;
use PDF::Class::Type;

#| /Type /OutputIntent

class PDF::OutputIntent
    is PDF::DAO::Dict
    does PDF::Class::Type['Type', 'S'] {

    use PDF::DAO::Tie;
    use PDF::DAO::Name;
    my subset Name-OutputIntent of PDF::DAO::Name where 'OutputIntent';
    has Name-OutputIntent $.Type is entry;
    has PDF::DAO::Name $.S is entry(:required); #| (Required) The output intent subtype; must be GTS_PDFX for a PDF/X output intent.
    # see also PDF::OutputIntent::GTS_PDFX

}
