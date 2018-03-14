use v6;

use PDF::OutputIntent;

class PDF::OutputIntent::GTS_PDFX
    is PDF::OutputIntent {

    use PDF::COS::Tie;
    use PDF::COS::Stream;

    # see [PDF 1.7 TABLE 10.51 Entries in a PDF/X output intent dictionary]
    has Str $.OutputCondition is entry;                       #| (Optional) An ASCII string concisely identifying the intended output device or production condition in human-readable form
    has Str $.OutputConditionIdentifier is entry(:required);  #| (Required) An ASCII string identifying the intended output device or production condition in human- or machine-readable form.
    has Str $.RegistryName is entry;                          #| (Optional) An ASCII string (conventionally a uniform resource identifier, or URI) identifying the registry in which the condition designated by OutputConditionIdentifier is defined
    has Str $.Info is entry;                                  #| (Required if OutputConditionIdentifier does not specify a standard production condition; optional otherwise) A human-readable text string containing additional information or comments about the intended target device or production condition
    has PDF::COS::Stream $.DestOutputProfile is entry;     #| (Required if OutputConditionIdentifier does not specify a standard production condition; optional otherwise) An ICC profile stream defining the transformation from the PDF document’s source colors to output device colorants.


}
