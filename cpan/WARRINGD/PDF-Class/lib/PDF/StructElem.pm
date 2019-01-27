use v6;

use PDF::COS::Tie::Hash;

#| an entry in the StructTree
#| See PDF::StructTreeRoot

role PDF::StructElem
    does PDF::COS::Tie::Hash {

    use PDF::COS::Tie;
    use PDF::COS::Name;
    use PDF::COS::TextString;
    use PDF::Page;

    # See [PDF 32000 Table 323 - Entries in a structure element dictionary]
    ## use ISO_32000::Structure_tree_element;
    ## also does ISO_32000::Structure_tree_element;

    has PDF::COS::Name $.Type is entry where 'StructElem'; # (Optional) The type of PDF object that this dictionary describes; if present, shall be StructElem for a structure element.

    has PDF::COS::Name $.S is entry(:required, :alias<structure-type>); # (Required) The structure type, a name object identifying the nature of the structure element and its role within the document, such as a chapter, paragraph, or footnote
    has Str $.ID is entry;    # (Optional) The element identifier, a byte string designating this structure element. The string shall be unique among all elements in the document’s structure hierarchy. The IDTree entry in the structure tree root defines the correspondence between element identifiers and the structure elements they denote.
    has PDF::Page $.Pg is entry(:indirect, :alias<page>); #dictionary (Optional; shall be an indirect reference) A page object representing a page on which some or all of the content items designated by the K entry shall be rendered.
    my subset ReferenceLike of Hash where .<Type> ~~ 'MCR'|'OBJR'; # autoloaded PDF::MCR, PDF::OBJR
    my subset StructElemLike of Hash where .<S>:exists;
    my subset StructRootLike of Hash where { .<Type> ~~ 'StructTreeRoot' }; # autoloaded PDF::StructTreeRoot
    my subset StructElemParent where StructRootLike|PDF::StructElem;
    my subset StructElemChild is export(:StructElemChild) where { ($_//UInt) ~~ UInt|PDF::StructElem|ReferenceLike }
    sub coerce-struct-kids($obj, StructElemChild) is export(:coerce-struct-kids) {
        # /K can be a single element or an array of elements
        if $obj ~~ List {
            for $obj.keys {
                coerce-child($_, StructElemChild)
                    with $obj[$_];
            }
        }
        else {
            coerce-child($obj, StructElemChild)
                unless $obj ~~ StructElemChild
        }
        $obj;
    }

    sub coerce-parent(StructElemLike $obj, StructElemParent) {
        PDF::COS.coerce($obj, PDF::StructElem);
    }
    multi sub coerce-child(StructElemLike $obj, StructElemChild) {
        PDF::COS.coerce($obj, PDF::StructElem);
    }
    multi sub coerce-child($_, StructElemChild) is default {
        fail "Unable to coerce {.perl} to a PDF::StructElem.K (child) element";
    }

    has StructElemParent $.P is entry(:required, :alias<struct-parent>, :coerce(&coerce-parent)); # (Required; shall be an indirect reference) The structure element that is the immediate parent of this one in the structure hierarchy.
    has StructElemChild @.K is entry(:array-or-item, :alias<kids>, :coerce(&coerce-child));      # (Optional) The children of this structure element. The value of this entry may be one of the following objects or an array consisting of one or more of the following objects:
    # • A structure element dictionary denoting another structure element
    # • An integer marked-content identifier denoting a marked-content sequence
    # • A marked-content reference dictionary denoting a marked-content sequence
    # • An object reference dictionary denoting a PDF object
    # Each of these objects other than the first shall be considered to be a content item;
    # If the value of K is a dictionary containing no Type entry, it shall be assumed to be a structure element dictionary.
    has @.A is entry(:alias<attributes>, :array-or-item);    # (Optional) A single attribute object or array of attribute objects associated with this structure element. Each attribute object shall be either a dictionary or a stream. If the value of this entry is an array, each attribute object in the array may be followed by an integer representing its revision number.
    method attribute-dicts {
        with self<A> -> List() $a {
            (0 ..^ $a.elems).map({$a[$_]}).grep(Hash);
        }
        else { () }
    }
    has @.C is entry(:array-or-item);                             # (Optional) An attribute class name or array of class names associated with this structure element. If the value of this entry is an array, each class name in the array may be followed by an integer representing its revision number.
# If both the A and C entries are present and a given attribute is
# specified by both, the one specified by the A entry shall take
    # precedence.
    method class-map-keys {
        with self<C> -> List() $c {
            (0 ..^ $.elems).map({$c[$_]}).grep(Str);
        }
        else { () }
    }

    has UInt $.R is entry(:alias<revision>, :default(0));                      # (Optional) The current revision number of this structure element. The value shall be a non-negative integer. Default value: 0.
    has PDF::COS::TextString $.T  is entry(:alias<title>);        # (Optional) The title of the structure element, a text string representing it in human-readable form. The title should characterize the specific structure element, such as 'Chapter 1', rather than merely a generic element type, such as 'Chapter'.
    has PDF::COS::TextString $.Lang is entry;  # (Optional; PDF 1.4) A language identifier specifying the natural language for all text in the structure element except where overridden by language specifications for nested structure elements or marked content. If this entry is absent, the language (if any) specified in the document catalogue applies.
    has PDF::COS::TextString $.Alt is entry(:alias<alternative-description>); # (Optional) An alternate description of the structure element and its children in human-readable form, which is useful when extracting the document’s contents in support of accessibility to users with.
    has PDF::COS::TextString $.E is entry(:alias<expanded-form>); # (Optional; PDF 1.5) The expanded form of an abbreviation.
    has PDF::COS::TextString $.ActualText is entry;               # (Optional; PDF 1.4) Text that is an exact replacement for the structure element and its children. This replacement text (which should apply to as small a piece of content as possible) is useful when extracting the document’s contents in support of accessibility to users with disabilities or for other purposes
}
