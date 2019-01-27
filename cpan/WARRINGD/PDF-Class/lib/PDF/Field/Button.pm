use v6;

use PDF::Field;

role PDF::Field::Button
    does PDF::Field {

    # [PDF 32000 TABLE 227 - Additional entry specific to check box and radio button fields]
    ## use ISO_32000::Check_box_and_radio_button_additional;
    ## also does ISO_32000::Check_box_and_radio_button_additional;
    use PDF::COS::Tie;
    use PDF::COS::TextString;

    has PDF::COS::Name $.V is entry(:inherit, :alias<value>);
    has PDF::COS::Name $.DV is entry(:inherit, :alias<default-value>);

    has PDF::COS::TextString @.Opt is entry;    # (Optional; inheritable; PDF 1.4) An array containing one entry for each widget annotation in the Kids array of the radio button or check box field. Each entry is a text string representing the on state of the corresponding widget annotation.

}
