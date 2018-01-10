use v6;

use PDF::Class::Type; # just to help rakudo
use PDF::DAO::Tie;
use PDF::DAO::Tie::Hash;

#| Appearance role - see PDF::Annot - /AP entry

role PDF::Appearance
    does PDF::DAO::Tie::Hash {

# See [PDF 1.7 TABLE 8.19 Entries in an appearance dictionary]

    use PDF::DAO;
    use PDF::DAO::Tie;
    use PDF::DAO::Stream;

    my role AppearanceStatus
	does PDF::DAO::Tie::Hash {
	has PDF::DAO::Stream $.Off is entry;
	has PDF::DAO::Stream $.On is entry;
	has PDF::DAO::Stream $.Yes is entry;
    }
    #| /Type entry is optional, but should be /Pattern when present
    my subset AppearanceEntry of PDF::DAO where PDF::DAO::Stream | AppearanceStatus;
    multi sub coerce(Hash $dict is rw, AppearanceEntry) {
	PDF::DAO.coerce($dict,  AppearanceStatus)
    }

    has AppearanceEntry $.N is entry(:&coerce, :alias<normal>, :required); #| (Required) The annotation’s normal appearance.
    has AppearanceEntry $.R is entry(:&coerce, :alias<rollover>);          #| (Optional) The annotation’s rollover appearance. Default value: the value of the N entry.
    has AppearanceEntry $.D is entry(:&coerce, :alias<down>);              #| (Optional) The annotation’s down appearance. Default value: the value of the N entry.

}
