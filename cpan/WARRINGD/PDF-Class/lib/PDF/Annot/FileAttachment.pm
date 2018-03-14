use v6;
use PDF::Annot;

class PDF::Annot::FileAttachment
    is PDF::Annot {

    use PDF::COS::Tie;
    use PDF::COS::Name;
    use PDF::COS::ByteString;
    use PDF::COS::Dict;

    my subset FileSpec where PDF::COS::ByteString | PDF::COS::Dict; #| [PDF 32000-1:2008] 7.11.2 File Specification Strings
    has FileSpec $.FS is entry(:required, :alias<file-spec>); #| (Required) The file associated with this annotation.
    has PDF::COS::Name $.Name is entry(:alias<icon-name>);    #| (Optional) The name of an icon that is used in displaying the annotation. Conforming readers shall provide predefined icon appearances for at least the following standard names: GraphPushPin, PaperclipTag
}


