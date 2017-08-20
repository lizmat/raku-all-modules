use v6;

module PDF::Content::Marked {
    #| See [PDF 1.7 TABLE 10.22 Standard structure types for paragraphlike elements]
    my enum ParagraphTags is export(:ParagraphTags) (
        :Paragraph<P>, :Header<H>, :Header1<H1>,
        :Header2<H2>, :Header3<H3>, :Header4<H4>,
        :Header5<H5>, :Header6<H6>, :ListItem<LI>);
}
