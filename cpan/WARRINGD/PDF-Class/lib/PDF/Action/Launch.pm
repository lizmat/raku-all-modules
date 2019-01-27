use v6;

use PDF::Action;
use PDF::COS::Dict;

#| /Action Subtype - Launch
class PDF::Action::Launch
    is PDF::COS::Dict
    does PDF::Action {

    # see [PDF 32000 Table 203 – Additional entries specific to a launch action]
    ## use ISO_32000::Launch_action_additional;
    ## also does ISO_32000::Launch_action_additional;
    use PDF::COS::Tie;
    use PDF::COS::Name;
    use PDF::Filespec :File, :&to-file;

    has File $.F is entry(:alias<file>, :coerce(&to-file)); # (Required if none of the entries Win, Mac, or Unix is present) The application that shall be launched or the document that shall be opened or printed. If this entry is absent and the conforming reader does not understand any of the alternative entries, it shall do nothing.
    has Hash $.Win is entry; # (Optional) A dictionary containing parameters.
    has $.Mac is entry; # (Optional) Mac OS–specific launch parameters; not yet defined.
    has $.Unix is entry; # (Optional) UNIX-specific launch parameters; not yet defined.
    has Bool $.NewWindow is entry; # (Optional; PDF 1.2) A flag specifying whether to open the destination document in a new window. If this flag is false, the destination document replaces the current document in the same window. If this entry is absent, the conforming reader should behave in accordance with its current preference. This entry shall be ignored if the file designated by the F entry is not a PDF document.

    method cb-check {
        die "at least one of /F /Win /Mac or /Unix should be present"
            without $.F // $.Win // $.Mac // $.Unix;
    }
}
