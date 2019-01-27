use v6;
use PDF::COS::Tie::Hash;
use PDF::Class::Type;

#| /Type /Action

role PDF::Action
    does PDF::COS::Tie::Hash
    does PDF::Class::Type::Subtyped {

    # set [PDF 32000 Table 193 - Entries common to all action dictionaries]
    ## use ISO_32000::Action_common;
    ## also does ISO_32000::Action_common;

    use PDF::COS::Tie;
    use PDF::COS::Name;

    has PDF::COS::Name $.Type is entry(:alias<type>) where 'Action';

    my subset ActionType of PDF::COS::Name where
	'GoTo'         #| Go to a destination in the current document.
	|'GoToR'       #| (“Go-to remote”) Go to a destination in another document.
	|'GoToE'       #| (“Go-to embedded”; PDF 1.6) Go to a destination in an embedded file.
	|'Launch'      #| Launch an application, usually to open a file.
	|'Thread'      #| Begin reading an article thread.
	|'URI'         #| Resolve a uniform resource identifier.
	|'Sound'       #| (PDF 1.2) Play a sound.
	|'Movie'       #| (PDF 1.2) Play a movie.
	|'Hide'        #| (PDF 1.2) Set an annotation’s Hidden flag.
	|'Named'       #| (PDF 1.2) Execute an action predefined by the viewer application.
	|'SubmitForm'  #| (PDF 1.2) Send data to a uniform resource locator.
	|'ResetForm'   #| (PDF 1.2) Set fields to their default values.
	|'ImportData'  #| (PDF 1.2) Import field values from a file.
	|'JavaScript'  #| (PDF 1.3) Execute a JavaScript script.
	|'SetOCGState' #| (PDF 1.5) Set the states of optional content groups.
	|'Rendition'   #| (PDF 1.5) Controls the playing of multimedia content.
	|'Trans'       #| (PDF 1.5) Updates the display of a document, using a transition dictionary.
	|'GoTo3DView'  #| (PDF 1.6) Set the current view of a 3D annotation
	;

    has ActionType $.S is entry(:required, :alias<subtype>);

    has PDF::Action @.Next is entry(:array-or-item);
}
