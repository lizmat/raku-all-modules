use v6;
use PDF;
class t::PDFTiny is PDF {
    use PDF::DAO;
    use PDF::DAO::Tie;
    use PDF::Content::Page;
    use PDF::Content::PageNode;
    use PDF::Content::PageTree;
    use PDF::Content::ResourceDict;
    use PDF::Content::Resourced;
    use PDF::Content::XObject;
    my role ResourceDict
	does PDF::DAO::Tie::Hash
	does PDF::Content::ResourceDict { }
    my role XObject-Form
        does PDF::DAO::Tie::Hash
        does PDF::Content::XObject['Form']
        does PDF::Content::Resourced
        does PDF::Content::Graphics {
            has ResourceDict $.Resources is entry;
    }
    my role PageNode
	does PDF::DAO::Tie::Hash
	does PDF::Content::PageNode {

 	has ResourceDict $.Resources is entry(:inherit);
    }
    my role Page does PageNode does PDF::Content::Page {
	has Numeric @.MediaBox is entry(:inherit,:len(4));
	has Numeric @.CropBox  is entry(:len(4));
	has Numeric @.TrimBox  is entry(:len(4));
	method to-xobject(|c) {
            PDF::Content::Page.to-xobject(self, :coerce(XObject-Form), |c);
	}
	method tiling-pattern(|c) {
            my constant Pattern = XObject-Form; # structurally identical
            my $stream = PDF::Content::Page.tiling-pattern(|c),
            PDF::DAO.coerce($stream, Pattern);
            $stream
	}
    }
    my role Pages does PageNode does PDF::Content::PageTree {
	has Page @.Kids        is entry(:required, :indirect);
        has UInt $.Count       is entry(:required);
    }
    my role Catalog
	does PDF::DAO::Tie::Hash {
	has Pages $.Pages is entry(:required, :indirect);

	method cb-finish {
	    self.Pages.?cb-finish;
	}
    }

    has Catalog $.Root is entry(:required, :indirect);

    method cb-init {
	self<Root> //= { :Type( :name<Catalog> ), :Pages{ :Type( :name<Pages> ), :Kids[], :Count(0), } };
    }
    
    for <page add-page page-count> {
        $?CLASS.^add_method($_,  method (|a) { self.Root.Pages."$_"(|a) });
    }
}
