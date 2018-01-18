use v6;

use PDF::DAO::Tie;
use PDF::DAO::Tie::Hash;

#| ViewPreferences role - see PDF::Catalog - /ViewPreferences entry

role PDF::ViewerPreferences
    does PDF::DAO::Tie::Hash {

    use PDF::DAO::Name;

    # see [PDF 1.7 TABLE 8.1 Entries in a viewer preferences dictionary]
    has Bool $.HideToolbar is entry;            #| (Optional) A flag specifying whether to hide the viewer application’s tool bars when the document is active. Default value: false.

    has Bool $.HideMenuBar is entry;            #| (Optional) A flag specifying whether to hide the viewer application’s menu bar when the document is active. Default value: false.

    has Bool $.HideWindowUI is entry;           #| (Optional) A flag specifying whether to hide user interface elements in the document’s window (such as scroll bars and navigation controls), leaving only the document’s contents displayed. Default value: false.

    has Bool $.FitWindow is entry;              #| (Optional) A flag specifying whether to resize the document’s window to fit the size of the first displayed page. Default value: false

    has Bool $.CenterWindow is entry;           #| (Optional; PDF 1.4) A flag specifying whether the window’s title bar should display the document title taken from the Title entry of the document information dictionary (see Section 10.2.1, “Document Information Dictionary”). If false, the title bar should instead display the name of the PDF file containing the document. Default value: false.

    use PDF::DAO::Name;
    my subset PageModes of PDF::DAO::Name where 'UseNone' | 'UseOutlines' | 'UseThumbs' | 'UseOC' | 'UseAttachments';
    has PageModes $.NonFullScreenPageMode is entry; #| (Optional) The document’s page mode, specifying how to display the document on exiting full-screen mode:
                                                #|  - UseNone        : Neither document outline nor thumbnail images visible
                                                #|  - UseOutlines    : Document outline visible
                                                #|  - UseThumbs      : Thumbnail images visible
                                                #|  - UseOC          : (PDF 1.5) Optional content group panel visible
                                                #|  - UseAttachments : (PDF 1.6) Attachments panel visable
                                                #| This entry is meaningful only if the value of the PageMode entry in the catalog dictionary is FullScreen; it is ignored otherwise. Default value: UseNone.

    my subset ReadingOrder of PDF::DAO::Name where 'L2R' | 'R2L';
    has ReadingOrder $.Direction is entry;      #| The predominant reading order for text:
                                                #|  - L2R: Left to right
                                                #|  - R2L: Right to left (including vertical writing systems, such as Chinese, Japanese, and Korean)
                                                #| This entry has no direct effect on the document’s contents or page numbering but can be used to determine the relative positioning of pages when displayed side by side or printed n-up. Default value: L2R.


    has PDF::DAO::Name $.ViewArea is entry;  #| (Optional; PDF 1.4) The name of the page boundary representing the area of a page to be displayed when viewing the document on the screen. The value is the key designating the relevant page boundary in the page object (see “Page Objects” on page 144 and Section 10.10.1, “Page Boundaries”). If the specified page boundary is not defined in the page object, its default value is used, as specified in Table 3.27 on page 145. Default value: CropBox.
                                                #|Note: This entry is intended primarily for use by prepress applications that interpret or manipulate the page boundaries as described in Section 10.10.1, “Page Boundaries.” Most PDF consumer applications disregard it.

    has PDF::DAO::Name $.ViewClip is entry;  #| (Optional; PDF 1.4) The name of the page boundary to which the contents of a page are to be clipped when viewing the document on the screen. The value is the key designating the relevant page boundary in the page object (see “Page Objects” on page 144 and Section 10.10.1, “Page Boundaries”). If the specified page boundary is not defined in the page object, its default value is used, as specified in Table 3.27 on page 145. Default value: CropBox.
                                                #| Note: This entry is intended primarily for use by prepress applications that interpret or manipulate the page boundaries as described in Section 10.10.1, “Page Boundaries.” Most PDF consumer applications disregard it.

    has PDF::DAO::Name $.PrintArea is entry; #| (Optional; PDF 1.4) The name of the page boundary representing the area of a page to be rendered when printing the document. The value is the key designating the relevant page boundary in the page object (see “Page Objects” on page 144 and Section 10.10.1, “Page Boundaries”). If the specified page boundary is not defined in the page object, its default value is used, as specified in Table 3.27 on page 145. Default value: CropBox.
                                                #| Note: This entry is intended primarily for use by prepress applications that interpret or manipulate the page boundaries as described in Section 10.10.1, “Page Boundaries.” Most PDF consumer applications disregard it.

    has PDF::DAO::Name $.PrintScaling is entry; #| (Optional; PDF 1.6) The page scaling option to be selected when a print dialog is displayed for this document. Valid values are None, which indicates that the print dialog should reflect no page scaling, and AppDefault, which indicates that applications should use the current print scaling. If this entry has an unrecognized value, applications should use the current print scaling. Default value: AppDefault.
                                                #| Note: If the print dialog is suppressed and its parameters are provided directly by the application, the value of this entry should still be used.

    my subset PageHandling of PDF::DAO::Name where 'Simplex' | 'DuplexFlipShortEdge' | 'DuplexFlipLongEdge';
    has PageHandling $.Duplex is entry;        #| (Optional; PDF 1.7) The paper handling option to use when printing the file from the print dialog.

    has Bool $.PickTrayByPDFSize is entry;     #| (Optional; PDF 1.7) A flag specifying whether the PDF page size is used to select the input paper tray. This setting influences only the preset values used to populate the print dialog presented by a PDF viewer application. If PickTrayByPDFSize is true, the check box in the print dialog associated with input paper tray is checked.
                                               #| Note: This setting has no effect on Mac OS systems, which do not provide the ability to pick the input tray by size.

    has UInt @.PrintPageRange is entry;       #| (Optional; PDF 1.7) The page numbers used to initialize the print dialog box when the file is printed. The first page of the PDF file is denoted by 1. Each pair consists of the first and last pages in the sub-range. An odd number of integers causes this entry to be ignored. Negative numbers cause the entire array to be ignored.


    has UInt $.NumCopies is entry;             #| (Optional; PDF 1.7) The number of copies to be printed when the print dialog is opened for this file. Supported values are the integers 2 through 5. Values outside this range are ignored.
}
