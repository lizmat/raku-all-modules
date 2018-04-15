use v6;

use PDF::Class::Type; # just to help rakudo
use PDF::COS::Tie;
use PDF::COS::Tie::Hash;

#| Appearance role - see PDF::Annot - /AP entry

role PDF::Appearance
    does PDF::COS::Tie::Hash {

# See [PDF 1.7 TABLE 8.19 Entries in an appearance dictionary]

    use PDF::COS;
    use PDF::COS::Tie;
    use PDF::COS::Stream;

    my role AppearanceStatus
	does PDF::COS::Tie::Hash {
	has PDF::COS::Stream $.Off is entry;
	has PDF::COS::Stream $.On is entry;
	has PDF::COS::Stream $.Yes is entry;
    }
    #| /Type entry is optional, but should be /Pattern when present
    my subset AppearanceEntry where PDF::COS::Stream | AppearanceStatus;
    multi sub coerce(Hash $dict is rw, AppearanceEntry) {
	PDF::COS.coerce($dict,  AppearanceStatus)
    }

    has AppearanceEntry $.N is entry(:&coerce, :alias<normal>, :required); #| (Required) The annotation’s normal appearance.
    has AppearanceEntry $.R is entry(:&coerce, :alias<rollover>);          #| (Optional) The annotation’s rollover appearance. Default value: the value of the N entry.
    has AppearanceEntry $.D is entry(:&coerce, :alias<down>);              #| (Optional) The annotation’s down appearance. Default value: the value of the N entry.

}
