use v6;
use PDF::Annot;

class PDF::Annot::FileAttachment
    is PDF::Annot {

    use PDF::DAO::Tie;
    use PDF::DAO::Name;
    use PDF::DAO::ByteString;
    use PDF::DAO::Dict;

    my subset FileSpec where PDF::DAO::ByteString | PDF::DAO::Dict; #| [PDF 32000-1:2008] 7.11.2 File Specification Strings
    has FileSpec $.FS is entry(:required); #| (Required) The file associated with this annotation.
    has PDF::DAO::Name $.Name is entry;    #| (Optional) The name of an icon that is used in displaying the annotation. Conforming readers shall provide predefined icon appearances for at least the following standard names: GraphPushPin, PaperclipTag
}


