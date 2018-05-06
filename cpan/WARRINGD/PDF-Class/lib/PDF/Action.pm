use v6;
use PDF::COS::Tie::Hash;

#| /Type /Action

role PDF::Action
    does PDF::COS::Tie::Hash {

    # set [PDF 1.7 TABLE 8.17 Entries in a action style dictionary]
    use PDF::COS::Tie;
    use PDF::COS::Name;

    has PDF::COS::Name $.Type is entry where 'Action';

    my subset ActionSubtype of PDF::COS::Name where
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

    has ActionSubtype $.S is entry(:required);

    multi method delegate-action(Hash $dict where { .<S> ~~ ActionSubtype }) {
	PDF::COS.loader.find-delegate( 'Action', $dict<S> );
    }

    multi method delegate-action(Hash $dict) is default {
	warn "unknown action subtype: $dict<S>"
	    if $dict<S>:exists;
	PDF::Action;
    }

    my subset NextActionArray of Array where { [&&] .map( *.isa(PDF::Action) ) }
    my subset NextAction where PDF::Action | NextActionArray;

    multi sub coerce(Hash $actions, NextAction) {
      PDF::COS.coerce( $_, PDF::Action )
    }
    multi sub coerce(Array $actions, NextAction) {
      PDF::COS.coerce( $actions[$_], PDF::Action )
	  for $actions.keys;
    }

    has NextAction $.Next is entry(:&coerce);

    # todo remaining fields, TABLE 8.49 thru 8.51 etc

}
