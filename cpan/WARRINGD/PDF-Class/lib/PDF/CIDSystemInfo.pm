use v6;

use PDF::COS::Tie::Hash;

role PDF::CIDSystemInfo
    does PDF::COS::Tie::Hash {

    # see [PDF 32000 Table 116 - Entries in a CIDSystemInfo dictionary]
    ## use ISO_32000::CIDSystemInfo;
    ## also does ISO_32000::CIDSystemInfo;
    use PDF::COS::Tie;

    has Str $.Registry is entry(:required);    # A string identifying the issuer of the character collection—for example, Adobe.
    has Str $.Ordering is entry(:required);    # (Required) A string that uniquely names the character collection within the specified registry—for example, Japan1
    has UInt $.Supplement is entry(:required); # (Required) The supplement number of the character collection

}
