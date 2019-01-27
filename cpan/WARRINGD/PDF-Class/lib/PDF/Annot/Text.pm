use v6;

use PDF::Annot::Markup;

#| /Type Annot - Annonation subtypes
#| See [PDF 32000 Section 12.5 Annotations]
class PDF::Annot::Text
    is PDF::Annot::Markup {

    use PDF::COS::Tie;
    use PDF::COS::Name;
    use PDF::COS::TextString;

    # See [PDF 32000 Table 172 - Additional entries specific to a text annotation]
    ## use ISO_32000::Text_annotation_additional;
    ## also does ISO_32000::Text_annotation_additional;

    has Bool $.Open is entry;                        # (Optional) A flag specifying whether the annotation should initially be displayed open. Default value: false (closed).
    has PDF::COS::Name $.Name is entry(:alias<icon-name>, :default<Note>);              # (Optional) The name of an icon to be used in displaying the annotation. Viewer applications should provide predefined icon appearances for at least the following standard names:
                                                     #  - Comment, Key, Note, Help, NewParagraph, Paragraph, Insert
                                                     # Additional names may be supported as well. Default value: Note.
    has PDF::COS::TextString $.State is entry(:default<Unmarked>) where 'Marked'|'Unmarked'|'Accepted'|'Rejected'|'Cancelled'|'Completed'|'None';       # (Optional; PDF 1.5) The state to which the original annotation should be set; see “Annotation States,” above.
                                                     # Default: “Unmarked” if StateModel is “Marked”; “None” if StateModel is “Review
    has PDF::COS::TextString $.StateModel is entry where 'Marked'|'Review';  # (Required if State is present, otherwise optional; PDF 1.5) The state model corresponding to State; see “Annotation States,” above

    method cb-check {
        die "/StateModel should be present when /State is present"
            if (self<State>:exists) && !(self<StateModel>:exists);
    }

}
