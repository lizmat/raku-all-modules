use v6;

use PDF::COS::Dict;
use PDF::Class::Type;
use PDF::Content::Resourced;

#| /Type /Catalog - usually the document root in a PDF
#| See [PDF 1.7 Section 3.6.1 Document Catalog]
class PDF::Catalog
    is PDF::COS::Dict
    does PDF::Class::Type
    does PDF::Content::Resourced {

    # see [PDF 1.7 TABLE 3.25 Entries in the catalog dictionary]
    use PDF::COS::Tie;
    use PDF::COS::Tie::Hash;
    use PDF::COS::Dict;
    use PDF::COS::Name;
    use PDF::COS::Null;
    use PDF::COS::Stream;
    use PDF::COS::TextString;

    my subset Name-Catalog of PDF::COS::Name where 'Catalog';
    has Name-Catalog $.Type is entry(:required);

    has PDF::COS::Name $.Version is entry;               #| (Optional; PDF 1.4) The version of the PDF specification to which the document conforms (for example, 1.4)

    my subset Pages of PDF::Class::Type where { .type eq 'Pages' }; # autoloaded PDF::Pages
    has Pages $.Pages is entry(:required, :indirect);    #| (Required; must be an indirect reference) The page tree node that is the root of the document’s page tree

    use PDF::NumberTree;
    has PDF::NumberTree $.PageLabels is entry;           #| (Optional; PDF 1.3) A number tree defining the page labeling for the document.

    has PDF::COS::Dict $.Names is entry;                 #| (Optional; PDF 1.2) The document’s name dictionary

    has PDF::COS::Dict $.Dests is entry(:indirect);      #| (Optional; PDF 1.1; must be an indirect reference) A dictionary of names and corresponding destinations

    use PDF::ViewerPreferences;
    has PDF::ViewerPreferences $.ViewerPreferences is entry;  #| (Optional; PDF 1.2) A viewer preferences dictionary specifying the way the document is to be displayed on the screen.

    subset PageLayout of PDF::COS::Name where 'SinglePage'|'OneColumn'|'TwoColumnLeft'|'TwoColumnRight'|'TwoPageLeft'|'TwoPageRight';
    has PageLayout $.PageLayout is entry;                     #| (Optional) A name object specifying the page layout to be used when the document is opened

    subset PageMode of PDF::COS::Name where 'UseNone'|'UseOutlines'|'UseThumbs'|'FullScreen'|'UseOC'|'UseAttachments';
    has PageMode $.PageMode is entry;                         #| (Optional) A name object specifying how the document should be displayed when opened

    use PDF::Outlines;
    has PDF::Outlines $.Outlines is entry(:indirect); #| (Optional; must be an indirect reference) The outline dictionary that is the root of the document’s outline hierarchy

    has PDF::COS::Dict @.Threads is entry(:indirect);         #| (Optional; PDF 1.1; must be an indirect reference) An array of thread dictionaries representing the document’s article threads

    use PDF::Action;
    use PDF::Destination;
    my subset ActionOrDestination where PDF::Action|PDF::Destination;
    multi sub coerce(Hash $_, ActionOrDestination) {
        PDF::COS.coerce( $_, PDF::Action.delegate-action($_) );
    }
    multi sub coerce(Array $_, ActionOrDestination) {
        PDF::COS.coerce( $_, PDF::Destination.delegate-destination($_) );
    }
    has ActionOrDestination $.OpenAction is entry(:&coerce);               #| (Optional; PDF 1.1) A value specifying a destination to be displayed or an action to be performed when the document is opened.

    has PDF::COS::Dict $.AA is entry(:alias<additional-actions>);                    #| (Optional; PDF 1.4) An additional-actions dictionary defining the actions to be taken in response to various trigger events affecting the document as a whole

    use PDF::Action::URI;
    has PDF::Action::URI $.URI is entry;                 #| (Optional; PDF 1.1) A URI dictionary containing document-level information for URI

    use PDF::AcroForm;
    has PDF::AcroForm $.AcroForm is entry;               #| (Optional; PDF 1.2) The document’s interactive form (AcroForm) dictionary

    my subset Metadata of PDF::COS::Stream where { .type eq 'Metadata' && .subtype eq 'XML' }; # autoloaded PDF::Metadata::XML
    has Metadata $.Metadata is entry(:indirect);         #| (Optional; PDF 1.4; must be an indirect reference) A metadata stream containing metadata for the document

    has PDF::COS::Dict $.StructTreeRoot is entry;        #| (Optional; PDF 1.3) The document’s structure tree root dictionary

    role MarkInfoDict
	does PDF::COS::Tie::Hash {
	#| [See PDF 1.7 TABLE 10.8 Entries in the mark information dictionary]
	has Bool $.Marked is entry;          #| (Optional) A flag indicating whether the document conforms to Tagged PDF conventions. Default value: false.
					     #| Note: If Suspects is true, the document may not completely conform to Tagged PDF conventions.
	has Bool $.UserProperties is entry;  #| (Optional; PDF 1.6) A flag indicating the presence of structure elements that contain user properties attributes. Default value: false.
	has Bool $.Suspects is entry;        #| Optional; PDF 1.6) A flag indicating the presence of tag suspects (see “Page Content Order” on page 889). Default value: false.
    }

    has MarkInfoDict $.MarkInfo is entry;                #| (Optional; PDF 1.4) A mark information dictionary containing information about the document’s usage of Tagged PDF conventions

    has PDF::COS::TextString $.Lang is entry;            #| (Optional; PDF 1.4) A language identifier specifying the natural language for all text in the document except where overridden by language specifications for structure elements or marked content

    has PDF::COS::Dict $.SpiderInfo is entry;            #| (Optional; PDF 1.3) A Web Capture information dictionary containing state information used by the Acrobat Web Capture (AcroSpider) plug-in extension

    use PDF::OutputIntent;
    has PDF::OutputIntent @.OutputIntents is entry;         #| (Optional; PDF 1.4) An array of output intent dictionaries describing the color characteristics of output devices on which the document might be rendered

    has PDF::COS::Dict $.PieceInfo is entry;             #| (Optional; PDF 1.4) A page-piece dictionary associated with the document

    has PDF::COS::Dict $.OCProperties is entry;          #| (Optional; PDF 1.5; required if a document contains optional content) The document’s optional content properties dictionary

    has PDF::COS::Dict $.Perms is entry;                 #| (Optional; PDF 1.5) A permissions dictionary that specifies user access permissions for the document.

    has PDF::COS::Dict $.Legal is entry;                 #| (Optional; PDF 1.5) A dictionary containing attestations regarding the content of a PDF document, as it relates to the legality of digital signatures

    has PDF::COS::Dict @.Requirements is entry;          #| (Optional; PDF 1.7) An array of requirement dictionaries representing requirements for the document.

    has PDF::COS::Dict $.Collection is entry;            #| (Optional; PDF 1.7) A collection dictionary that a PDF consumer uses to enhance the presentation of file attachments stored in the PDF document.

    has Bool $.NeedsRendering is entry;        #| (Optional; PDF 1.7) A flag used to expedite the display of PDF documents containing XFA forms. It specifies whether the document must be regenerated when the document is first opened.

    use PDF::Resources;
    has PDF::Resources $.Resources is entry;

    method cb-init {
        # vivify pages
	self<Type> //= PDF::COS.coerce( :name<Catalog> );

        self<Pages> //= PDF::COS.coerce(
            :dict{
                :Type( :name<Pages> ),
                :Resources{ :Procset[ :name<PDF>, :name<Text> ] },
                :Count(0),
                :Kids[],
	    });
    }

    method cb-finish {
        self<Pages>.cb-finish;
    }
}

