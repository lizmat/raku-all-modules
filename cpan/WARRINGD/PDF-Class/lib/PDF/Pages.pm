use v6;

use PDF::COS::Dict;
use PDF::Class::Type;
use PDF::Content::PageNode;
use PDF::Content::PageTree;

#| /Type /Pages - a node in the page tree

class PDF::Pages
    is PDF::COS::Dict
    does PDF::Class::Type
    does PDF::Content::PageNode
    does PDF::Content::PageTree {

    use PDF::COS;
    use PDF::COS::Tie;
    use PDF::COS::Name;
    my subset Name-Pages of PDF::COS::Name where 'Pages';

    # see [PDF 1.7 TABLE 3.26 Required entries in a page tree node]
    has Name-Pages $.Type is entry(:required);
    has Hash $.Parent is entry(:indirect); #| (Required except in root node; must be an indirect reference) The page tree node that is the immediate parent of this one.
    has PDF::Content::PageNode @.Kids is entry(:required, :indirect);  #| (Required) An array of indirect references to the immediate children of this node. The children may be page objects or other page tree nodes.
    has UInt $.Count is entry(:required);   #| (Required) The number of leaf nodes (page objects) that are descendants of this node within the page tree.
    use PDF::Resources;
    has PDF::Resources $.Resources is entry(:inherit);

    #| inheritable page properties
    has Numeric @.MediaBox is entry(:inherit,:len(4));
    has Numeric @.CropBox is entry(:inherit,:len(4));

    method cb-init {
	self<Type> = PDF::COS.coerce( :name<Pages> );
	unless (self<Kids>:exists) || (self<Count>:exists) {
	    self<Kids> = [];
	    self<Count> = 0;
	}
    }

    method cb-finish {
        my Int $count = 0;
        my Array $kids = self.Kids;
        for $kids.keys {
            my $kid = $kids[$_];
            $kid<Parent> = self.link;
            $kid.cb-finish;
            $count += $kid.can('Count') ?? $kid.Count !! 1;
        }
        self<Count> = $count;
    }

}
