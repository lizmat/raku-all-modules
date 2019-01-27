use v6;

use PDF::COS::Dict;
use PDF::Class::Type;

# /Type /StructTreeRoot - a node in the page tree
class PDF::StructTreeRoot
    is PDF::COS::Dict
    does PDF::Class::Type {

    # see [PDF 32000 Table 32000 Table 322 - Entries in the structure tree root]
    ## use ISO_32000::Structure_tree_root;
    ## also does ISO_32000::Structure_tree_root;
    use PDF::COS::Tie;
    use PDF::COS::Name;
    use PDF::StructElem :coerce-struct-kids, :StructElemChild;
    use PDF::NameTree;
    use PDF::NumberTree;

    has PDF::COS::Name $.Type is entry(:required, :alias<type>) where 'StructTreeRoot';
    has PDF::StructElem @.K is entry( :alias<kids>, :array-or-item );  # The immediate child or children of the structure tree root in the structure hierarchy. The value may be either a dictionary representing a single structure element or an array of such dictionaries.
    has PDF::NameTree[StructElemChild, :coerce(&coerce-struct-kids)] $.IDTree is entry;          # (Required if any structure elements have element identifiers) A name tree that maps element identifiers to the structure elements they denote.
    has PDF::NumberTree[StructElemChild, :coerce(&coerce-struct-kids)] $.ParentTree is entry;    # (Required if any structure element contains content items) A number tree used in finding the structure elements to which content items belong. Each integer key in the number tree shall correspond to a single page of the document or to an individual object (such as an annotation or an XObject) that is a content item in its own right. The integer key shall be the value of the StructParent or StructParents entry in that object. The form of the associated value shall depend on the nature of the object:
                                                  # -- For an object that is a content item in its own right, the value shall be an indirect reference to the object’s parent element (the structure element that contains it as a content item).
                                                  # -- For a page object or content stream containing marked-content sequences that are content items, the value shall be an array of references to the parent elements of those marked-content sequences.

    has UInt $.ParentTreeNextKey is entry;       # (Optional) An integer greater than any key in the parent tree, shall be used as a key for the next entry added to the tree.
    our subset StandardStructureType of PDF::COS::Name where
        # [PDF 32000 Table 333 – Standard structure types for grouping elements]
        'Document'     # (Document) A complete document. This is the root element of any structure tree containing multiple parts or multiple articles.
        | 'Part'       # (Part) A large-scale division of a document. This type of element is appropriate for grouping articles or sections.
        | 'Art'        # (Article) A relatively self-contained body of text constituting a single narrative or exposition. Articles should be disjoint; that is, they should not contain other articles as constituent elements.
        | 'Sect'       # (Section) A container for grouping related content elements.
        | 'Div'        # (Division) A generic block-level element or group of elements.
        | 'BlockQuote' # (Block quotation) A portion of text consisting of one or more paragraphs attributed to someone other than the author of the surrounding text.
        | 'Caption'    # (Caption) A brief portion of text describing a table or figure.
        | 'TOC'        # (Table of contents) A list made up of table of contents item entries (structure type
        #                TOCI) and/or other nested table of contents entries (TOC).
        | 'TOCI'       # (Table of contents item) An individual member of a table of contents. This entry’s
        #                children may be any of TOC, Lbl, Reference, NonStruct or P
        | 'Index'      # (Index) A sequence of entries containing identifying text accompanied by reference elements
        #                that point out occurrences of the specified text in the main body of a document.
        | 'NonStruct'  # (Nonstructural element) A grouping element having no inherent structural significance.
        | 'Private'    # (Private element) A grouping element containing private content belonging to the  application producing it.
        # [PDF 32000 Table 334 – Block-level structure elements]
        |'P'|'H'|'H1'..'H6'      # Paragraphlike elements
        |'L'|'LI'|'Lbl'|'LBody'  # List elements
        |'Table'|'TR'|'TH'|'TD'|'THead'|'TBody'|'TFoot'  # Table elements
        # [ PDF 320000 Table 338 – Standard structure types for inline-level structure elements]
        | 'Span'      # (Span) A generic inline portion of text having no particular inherent characteristics.
        #               It can be used, for example, to delimit a range of text with a given set of styling attributes.
        | 'Quote'     # (Quotation) An inline portion of text attributed to someone other than the author of the surrounding text.
        | 'Note'      # (Note) An item of explanatory text, such as a footnote or an endnote, that is referred
                      # to from within the body of the document. It may have a label (structure type Lbl) as a child.
        | 'Reference' # (Reference) A citation to content elsewhere in the document.
        | 'BibEntry'  # (Bibliography entry) A reference identifying the external source of some cited content. It may
        #               contain a label (structure type Lbl) as a child.
        | 'Code'      # (Code) A fragment of computer program text.
        | 'Link'      # (Link) An association between a portion of the ILSE’s content and a corresponding link annotation
        | 'Annot'     # (Annotation; PDF 1.5) An association between a portion of the ILSE’s content and a corresponding PDF annotation
        # 'Ruby'      # (Ruby; PDF 1.5) A side-note (annotation) written in a smaller text size and placed adjacent to the
        #             # base text to which it refers. A Ruby element may also contain the RB, RT, and RP elements.
        # 'Warichu'   # (Warichu; PDF 1.5) A comment or annotation in a smaller text size and formatted onto two smaller
        #               lines within the height of the containing text line and placed following (inline) the base text to
        #               which it refers. A Warichu element may also contain the WT and WP elements.
        # [PDF 32000 Table 339 – Standard structure types for Ruby and Warichu elements (PDF 1.5)]
        | 'Ruby'      # (Ruby) The wrapper around the entire ruby assembly. It shall contain one RB element followed by either an RT
        #                element or a three-element group consisting of RP, RT, and RP. Ruby elements and their content elements
        #                shall not break across multiple lines.
        | 'RB'        # (Ruby base text) The full-size text to which the ruby annotation is applied. RB may
        #               contain text, other inline elements, or a mixture of both. It may have the RubyAlign attribute.
        | 'RT'        # (Ruby annotation text) The smaller-size text that shall be placed adjacent to the ruby base text. It may contain
        #                text, other inline elements, or a mixture of both. It may have the RubyAlign and RubyPosition attributes.
        | 'RP'        # (Ruby punctuation) Punctuation surrounding the ruby annotation text.
        | 'Warichu'   # (Warichu) The wrapper around the entire warichu assembly. It may contain a three-
        #               element group consisting of WP, WT, and WP.
        | 'WT'        # (Warichu text) The smaller-size text of a warichu comment that is formatted into two lines and placed between surrounding WP elements.
        | 'WP'        # (Warichu punctuation) The punctuation that surrounds the WT text. It contains text
        #               (usually a single LEFT or RIGHT PARENTHESIS or similar bracketing character).
        # [PDF 32000 Table 340 – Standard structure types for illustration elements]
        | 'Figure'    # (Figure) An item of graphical content. Its placement may be specified with the Placement layout attribute.
        | 'Formula'   # (Formula) A mathematical formula.
        | 'Form'      # (Form) A widget annotation representing an interactive form field
        ;

    has StandardStructureType %.RoleMap  is entry;     # A dictionary that shall map the names of structure types used in the document to their approximate equivalents in the set of standard structure types.

    has Hash %.ClassMap is entry;                      # A dictionary that shall map name objects designating attribute classes to the corresponding attribute objects
}
