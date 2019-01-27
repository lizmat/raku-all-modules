use v6;

use PDF::Annot;

class PDF::Annot::Markup
    is PDF::Annot {

    use PDF::COS::Tie;
    use PDF::COS::Tie::Hash;
    use PDF::COS::Dict;
    use PDF::COS::Name;
    use PDF::COS::DateString;
    use PDF::COS::TextString;
    use PDF::Annot::Popup;
    use PDF::COS::Stream;
    use PDF::ExData::Markup3D;

    # See [PDF 32000 Table 170 - Additional entries specific to markup annotations]
    ## use ISO_32000::Annotation_markup_additional;
    ## also does ISO_32000::Annotation_markup_additional;

    # This is the base class for Markup Annotations, as indicated in [PDF 32000 Table 169, Column 3].
    # I.e.: Text, FreeText, Line, Square, Circle, Polygon, PolyLine, Highlight Underline, Squiggly,
    # StrikeOut, Stamp, Caret, Ink, FileAttachment, Sound

    has PDF::COS::TextString $.T is entry(:alias<text-label>); # (Optional; PDF 1.1) The text label that shall be displayed in the title bar of the annotation’s pop-up window when open and active. This entry shall identify the user who added the annotation.
    has PDF::Annot::Popup $.Popup is entry; # (Optional; PDF 1.3) An indirect reference to a pop-up annotation for entering or editing the text associated with this annotation.

    has Numeric $.CA is entry(:alias<constant-opacity>); # (Optional; PDF 1.4) The constant opacity value that shall be used in painting the annotation. This value shall apply to all visible elements of the annotation in its closed state (including its background and border) but not to the pop-up window that appears when the annotation is opened.
    # The specified value shall not used if the annotation has an appearance stream; in that case, the appearance stream shall specify any transparency. (However, if the compliant viewer regenerates the annotation’s appearance stream, it may incorporate the CA value into the stream’s content.)
    # The implicit blend mode is Normal. Default value: 1.0.
    # If no explicit appearance stream is defined for the annotation, it may be painted by implementation-dependent means that do not necessarily conform to the PDF imaging model; in this case, the effect of this entry is implementation-dependent as well.
    my subset TextOrStream where PDF::COS::TextString | PDF::COS::Stream;
    multi sub coerce(Str $value is rw, TextOrStream) {
	PDF::COS.coerce( $value, PDF::COS::TextString );
    }
    has TextOrStream $.RC is entry(:alias<rich-text>, :&coerce); # (Optional; PDF 1.5) A rich text string that shall be displayed in the pop-up window when the annotation is opened.
    has PDF::COS::DateString $.CreationDate is entry; # (Optional; PDF 1.5) The date and time when the annotation was created.
    my subset TextOrDict where PDF::COS::TextString | PDF::COS::Dict;
    multi sub coerce(Str $value is rw, TextOrDict) {
	$value = PDF::COS.coerce( $value, PDF::COS::TextString );
    }
    has TextOrDict $.IRT is entry(:alias<reply-to-ref>, :&coerce); # (Required if an RT entry is present, otherwise optional; PDF 1.5) A reference to the annotation that this annotation is “in reply to.” Both annotations shall be on the same page of the document. The relationship between the two annotations shall be specified by the RT entry.
    # If this entry is present in an FDF file, its type shall not be a dictionary but a text string containing the contents of the NM entry of the annotation being replied to, to allow for a situation where the annotation being replied to is not in the same FDF file. Subj text string (Optional; PDF 1.5) Text representing a short description of the subject being addressed by the annotation.
    has PDF::COS::TextString $.Subj is entry; # text representing a short description of the subject being addressed by the annotation.
    my subset RelationshipType of PDF::COS::Name where 'R'|'Group';
    has  RelationshipType $.RT is entry(:alias<reply-type>, :default<R>); # (Optional; meaningful only if IRT is present; PDF 1.6) A name specifying the relationship (the “reply type”) between this annotation and onespecified by IRT. Valid values are:
    # R - The annotation shall be considered a reply to the annotationspecified by IRT. Conforming readers shall not display replies to an annotation individually but together in the form of threaded comments.
    # Group - The annotation shall be grouped with the annotation specified by IRT; see the discussion following this Table.
    # Default value: R.
    has PDF::COS::Name $.IT is entry(:alias<intent>); # (Optional; PDF 1.6) A name describing the intent of the markup annotation. Intents allow conforming readers to distinguish between different uses and behaviors of a single markup annotation type. If this entry is not present or its value is the same as the annotation type, the annotation shall have no explicit intent and should behave in a generic manner in a conforming reader.
    # Free text annotations, line annotations, polygon annotations, and (PDF 1.7) polyline annotations (Table 178) have defined intents, whose values are enumerated in the corresponding tables.

    has PDF::ExData::Markup3D $.ExData is entry(:alias<external-data>); # (Optional; PDF 1.7) An external data dictionary specifying data that shall be associated with the annotation.
}

