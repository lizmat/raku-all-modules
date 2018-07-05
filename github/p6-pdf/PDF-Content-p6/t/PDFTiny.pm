use v6;
use PDF;
class t::PDFTiny is PDF {
    use PDF::COS;
    use PDF::COS::Tie;
    use PDF::COS::Loader;
    use PDF::COS::Util :from-ast;
    use PDF::COS::Dict;
    use PDF::COS::Stream;
    use PDF::Content::Page;
    use PDF::Content::PageNode;
    use PDF::Content::PageTree;
    use PDF::Content::ResourceDict;
    use PDF::Content::Resourced;
    use PDF::Content::XObject;
    my role ResourceDict
	does PDF::COS::Tie::Hash
	does PDF::Content::ResourceDict { }
    my class XObject-Form
        is PDF::COS::Stream
        does PDF::Content::XObject['Form']
        does PDF::Content::Resourced
        does PDF::Content::Graphics {
            has ResourceDict $.Resources is entry;
    }
    my class XObject-Image
        is PDF::COS::Stream
        does PDF::Content::XObject['Image'] {
    }
    my class PageNode
	is PDF::COS::Dict
	does PDF::Content::PageNode {

       has ResourceDict $.Resources is entry(:inherit);
       has $.Parent is entry;
    }
    my class Page is PageNode does PDF::Content::Page {
	has Numeric @.MediaBox is entry(:inherit,:len(4));
	has Numeric @.CropBox  is entry(:len(4));
	has Numeric @.TrimBox  is entry(:len(4));
    }
    my class Pages is PageNode does PDF::Content::PageTree {
	has PageNode @.Kids    is entry(:required, :indirect);
        has UInt $.Count       is entry(:required);
    }
    my role Catalog
	does PDF::COS::Tie::Hash {
	has Pages $.Pages is entry(:required, :indirect);

	method cb-finish {
	    self.Pages.?cb-finish;
	}
    }

    has Catalog $.Root is entry(:required, :indirect);

    my class Loader is PDF::COS::Loader {
        multi method load-delegate(Hash :$dict! where {from-ast($_) ~~ 'Form' given  .<Subtype>}) {
            XObject-Form
        }
        multi method load-delegate(Hash :$dict! where {from-ast($_) ~~ 'Image' given  .<Subtype>}) {
            XObject-Image
        }
        multi method load-delegate(Hash :$dict! where {from-ast($_) ~~ 'Pattern'|'Page'|'Pages' given  .<Type>}) {
            %{:Pattern(XObject-Form), :Page(Page), :Pages(Pages)}{from-ast($dict<Type>)}
        }
    }
    PDF::COS.loader = Loader;

    method cb-init {
	self<Root> //= { :Type( :name<Catalog> ), :Pages{ :Type( :name<Pages> ), :Kids[], :Count(0), } };
    }

    for <page add-page page-count> {
        $?CLASS.^add_method($_,  method (|a) { self.Root.Pages."$_"(|a) });
    }
}
