use v6;

use PDF::Annot;

class PDF::Annot::Widget
    is PDF::Annot {

    use PDF::COS::Tie;
    use PDF::COS::Name;

    # See [PDF 1.7 TABLE 8.39 Additional entries specific to a widget annotation]
    subset HName of PDF::COS::Name where 'N'|'I'|'O'|'P'|'T';
    has HName $.H is entry(:alias<highlight-mode>);            #| (Optional; PDF 1.2) The annotation’s highlighting mode, the visual effect to be used when the mouse button is pressed or held down inside its active area:
                                       #| N(None)    - No highlighting.
                                       #| I(Invert)  - Invert the contents of the annotation rectangle.
                                       #| O(Outline) - Invert the annotation’s border.
                                       #| P(Push)    - Display the annotation as if it were being pushed below the surface of the page;
                                       #| T(Toggle)   - Same as P (which is preferred)
    has Hash $.MK is entry;            #| (Optional) An appearance characteristics dictionary to be used in constructing a dynamic appearance stream specifying the annotation’s visual presentation on the page.
    ##use PDF::Action; # causing failures in t/pdf-acroform.t (rakudo 2017-12)
    has Hash $.A is entry(:alias<action>);             #| (Optional; PDF 1.1) An action to be performed when the link annotation is activated (see Section 8.5, “Actions”).
    has Hash $.AA is entry(:alias<additional-actions>);            #| (Optional; PDF 1.2) An additional-actions dictionary defining the annotation’s behavior in response to various trigger events (see Section 8.5.2, “Trigger Events”).
    use PDF::Border;
    has PDF::Border $.BS is entry(:alias<border-style>);            #| (Optional; PDF 1.2) A border style dictionary specifying the width and dash pattern to be used in drawing the annotation’s border.
                                       #| Note: The annotation dictionary’s AP entry, if present, takes precedence over the Land BS entries

}
