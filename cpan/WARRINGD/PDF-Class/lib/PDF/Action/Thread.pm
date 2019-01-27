use v6;

use PDF::Action;
use PDF::COS::Dict;

#| /Action Subtype - Thread

class PDF::Action::Thread
    is PDF::COS::Dict
    does PDF::Action {
    ## use ISO_32000::Thread_action_additional;
    ## also does ISO_32000::Thread_action_additional;
    use PDF::COS;
    use PDF::COS::Tie;
    use PDF::Bead-Thread; # Declares PDF::Bead & PDF::Thread
    use PDF::Filespec :File, :&to-file;
    use PDF::COS::TextString;

    has File $.F is entry(:alias<file>, :coerce(&to-file));	# [file specification] (Optional) The file containing the thread. If this entry is absent, the thread is in the current file.
    my subset ThreadOrIndexOrTitle where PDF::Thread|PDF::COS::TextString|UInt;
    multi sub coerce(Hash $_, ThreadOrIndexOrTitle) { PDF::COS.coerce($_, PDF::Thread) }
    multi sub coerce(Str  $_, ThreadOrIndexOrTitle) { PDF::COS.coerce($_, PDF::COS::TextString) }
    multi sub coerce($_, ThreadOrIndexOrTitle) is default { fail "unable to coerce {.perl} to a Thread" }
    has $.D is entry(:alias<thread>, :&coerce, :required);	# [dictionary, integer, or text string] (Required) The destination thread, specified in one of the following forms:
	# An indirect reference to a thread dictionary (see Link 12.4.3, “Articles” ). In this case, the thread is in the current file.
	# The index of the thread within the Threads array of its document’s Catalog (see Link 7.7.2, “Document Catalog” ). The first thread in the array has index 0.
	# The title of the thread as specified in its thread information dictionary (see Link Ta b l e 160 ). If two or more threads have the same title, the one appearing first in the document Catalog’s Threads array shall be used.
    my subset BeadOrIndex where PDF::Bead|UInt;
    multi sub coerce(Hash $_, BeadOrIndex) { PDF::COS.coerce($_, PDF::Bead) }
    multi sub coerce($_, BeadOrIndex) is default { fail "unable to coerce {.perl} to a Bead" }
    has BeadOrIndex $.B is entry(:alias<bead>, :&coerce);	# [dictionary or integer] (Optional) The bead in the destination thread, specified in one of the following forms:
	# An indirect reference to a bead dictionary (see Link 12.4.3, “Articles” ). In this case, the thread is in the current file.
	# The index of the bead within its thread. The first bead in a thread has index 0.
}
