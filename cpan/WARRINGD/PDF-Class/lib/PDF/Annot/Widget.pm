use v6;

use PDF::Annot;

class PDF::Annot::Widget
    is PDF::Annot {

    use PDF::COS::Tie;
    use PDF::COS::Name;
    use PDF::Action;
    use PDF::Border;
    use PDF::Field;

    # See [PDF 32000 Table 188 - Additional entries specific to a widget annotation]
    ## use ISO_32000::Widget_annotation_additional;
    ## also does ISO_32000::Widget_annotation_additional;

    my subset HName of PDF::COS::Name where 'N'|'I'|'O'|'P'|'T';
    has HName $.H is entry(:alias<highlight-mode>);            # (Optional; PDF 1.2) The annotation’s highlighting mode, the visual effect to be used when the mouse button is pressed or held down inside its active area:
                                       # N(None)    - No highlighting.
                                       # I(Invert)  - Invert the contents of the annotation rectangle.
                                       # O(Outline) - Invert the annotation’s border.
                                       # P(Push)    - Display the annotation as if it were being pushed below the surface of the page;
                                       # T(Toggle)   - Same as P (which is preferred)
    has Hash $.MK is entry;            # (Optional) An appearance characteristics dictionary to be used in constructing a dynamic appearance stream specifying the annotation’s visual presentation on the page.
                                       # The name MK for this entry is of historical significance only and has no direct meaning.
    has PDF::Action $.A is entry(:alias<action>);             # (Optional; PDF 1.1) An action to be performed when the link annotation is activated.
    has Hash $.AA is entry(:alias<additional-actions>);            # (Optional; PDF 1.2) An additional-actions dictionary defining the annotation’s behavior in response to various trigger events (see Section 8.5.2, “Trigger Events”).
    has PDF::Border $.BS is entry(:alias<border-style>);            # (Optional; PDF 1.2) A border style dictionary specifying the width and dash pattern to be used in drawing the annotation’s border.
                                       # Note: The annotation dictionary’s AP entry, if present, takes precedence over the Land BS entries
    has PDF::Field $.Parent is entry(:indirect);	# (Required if this widget annotation is one of multiple children in a field; absent otherwise) An indirect reference to the widget annotation’s parent field. A widget annotation may have at most one parent; that is, it can be included in the Kids array of at most one field

}
