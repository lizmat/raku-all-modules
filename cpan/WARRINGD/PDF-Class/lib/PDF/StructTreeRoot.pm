use v6;

use PDF::COS::Dict;
use PDF::Class::Type;

# /Type /StructTreeRoot - a node in the page tree
class PDF::StructTreeRoot
    is PDF::COS::Dict
    does PDF::Class::Type {

    # see [PDF 32000 14.7.2 Structure Hierarchy]
    use PDF::COS::Tie;
    use PDF::COS::Dict;
    use PDF::COS::Name;
    has PDF::COS::Name $.Type is entry(:required) where 'StructTreeRoot';
    my subset DictOrArray where PDF::COS::Dict|Array;
    has DictOrArray $.K is entry;                 #| The immediate child or children of the structure tree root in the structure hierarchy. The value may be either a dictionary representing a single structure element or an array of such dictionaries.
    use PDF::NameTree;
    has PDF::NameTree $.IDTree is entry;          #| (Required if any structure elements have element identifiers) A name tree that maps element identifiers (see Table 323) to the structure elements they denote.
    use PDF::NumberTree;
    has PDF::NumberTree $.ParentTree is entry;    #| (Required if any structure element contains content items) A number tree used in finding the structure elements to which content items belong. Each integer key in the number tree shall correspond to a single page of the document or to an individual object (such as an annotation or an XObject) that is a content item in its own right. The integer key shall be the value of the StructParent or StructParents entry in that object. The form of the associated value shall depend on the nature of the object:
                                                  #| -- For an object that is a content item in its own right, the value shall be an indirect reference to the object’s parent element (the structure element that contains it as a content item).
                                                  #| -- For a page object or content stream containing marked-content sequences that are content items, the value shall be an array of references to the parent elements of those marked-content sequences.

     has UInt $.ParentTreeNextKey is entry;       #| (Optional) An integer greater than any key in the parent tree, shall be used as a key for the next entry added to the tree.
    has PDF::COS::Name %.RoleMap  is entry;       #| A dictionary that shall map the names of structure types used in the document to their approximate equivalents in the set of standard structure types.
    has %.ClassMap is entry;                      #| A dictionary that shall map name objects designating attribute classes to the corresponding attribute objects
}
