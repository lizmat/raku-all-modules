use v6;

use PDF::Annot;

#| /Type Annot - Annonation subtypes
#| See [PDF 1.7 Section 8.4 Annotations]
class PDF::Annot::Text
    is PDF::Annot {

    use PDF::COS::Tie;
    use PDF::COS::Name;
    use PDF::COS::TextString;

    # See [PDF 1.7 TABLE 8.23 Additional entries specific to a text annotation]
    has Bool $.Open is entry;                        #| (Optional) A flag specifying whether the annotation should initially be displayed open. Default value: false (closed).
    has PDF::COS::Name $.Name is entry(:alias<icon-name>);              #| (Optional) The name of an icon to be used in displaying the annotation. Viewer applications should provide predefined icon appearances for at least the following standard names:
                                                     #|  - Comment, Key, Note, Help, NewParagraph, Paragraph, Insert
                                                     #| Additional names may be supported as well. Default value: Note.
    has PDF::COS::TextString $.State is entry;       #| (Optional; PDF 1.5) The state to which the original annotation should be set; see “Annotation States,” above.
                                                     #| Default: “Unmarked” if StateModel is “Marked”; “None” if StateModel is “Review
    has PDF::COS::TextString $.StateModel is entry;  #| (Required if State is present, otherwise optional; PDF 1.5) The state model corresponding to State; see “Annotation States,” above

}
