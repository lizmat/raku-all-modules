use v6;

use PDF::COS::Tie::Hash;
use PDF::Class::Type;

#| /Type /OutputIntent

role PDF::OutputIntent
    does PDF::COS::Tie::Hash
    does PDF::Class::Type::Subtyped {

    # See [PDF 32000 Table 365 – Entries in an output intent dictionary]
    ## use ISO_32000::Output_intent;
    ## also does ISO_32000::Output_intent;
    use PDF::COS::Tie;
    use PDF::COS::Name;
    use PDF::COS::TextString;
    use PDF::COS::Stream;
    use PDF::ICCProfile;

    has PDF::COS::Name $.Type is entry(:alias<type>) where 'OutputIntent';
    has PDF::COS::Name $.S is entry(:required, :alias<subtype>); # Required) The output intent subtype; shall be either one of GTS_PDFX, GTS_PDFA1, ISO_PDFE1 or a key defined by an ISO 32000 extension.

    has Str $.OutputCondition is entry;                       # (Optional) An ASCII string concisely identifying the intended output device or production condition in human-readable form
    has Str $.OutputConditionIdentifier is entry(:required);  # (Required) An ASCII string identifying the intended output device or production condition in human- or machine-readable form.
    has Str $.RegistryName is entry;                          # (Optional) An ASCII string (conventionally a uniform resource identifier, or URI) identifying the registry in which the condition designated by OutputConditionIdentifier is defined
    has PDF::COS::TextString $.Info is entry;                 # (Required if OutputConditionIdentifier does not specify a standard production condition; optional otherwise) A human-readable text string containing additional information or comments about the intended target device or production condition
    has PDF::ICCProfile $.DestOutputProfile is entry;         # (Required if OutputConditionIdentifier does not specify a standard production condition; optional otherwise) An ICC profile stream defining the transformation from the PDF document’s source colors to output device colorants.

}
