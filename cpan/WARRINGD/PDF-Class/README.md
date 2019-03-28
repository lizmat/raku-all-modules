# PDF::Class

PDF::Class provides a set of roles and classes that map to the internal structure of PDF documents; the aim being to make it easier to read, write valid PDF files.

It assists with the construction of PDF documents, providing type-checking and the sometimes finicky serialization rules regarding objects.

This is the base class for [PDF::API6](https://github.com/p6-pdf/PDF-API6).

## Description

The top level of a PDF document is of type `PDF::Class`, which corresponds to the trailer dictionary. It may contain several entries including `PDF::Info` metadata in the 'Info' entry and `PDF::Catalog` in the `Root` entry.

```
    use PDF::Class;
    use PDF::Catalog;
    use PDF::Page;
    use PDF::Info;

    my PDF::Class $pdf .= open: "t/helloworld.pdf";

    # vivify Info entry; set title
    given $pdf.Info //= {} -> PDF::Info $_ {
        .Title = 'Hello World!';
    }

    # modify Viewer Preferences
    my PDF::Catalog $catalog = $pdf.Root;
    given $catalog.ViewerPreferences //= {} {
        .HideToolbar = True;
    }

    # add a page ...
    my PDF::Page $new-page = $pdf.add-page;
    $new-page.gfx.say: "New last page!";

    # save the updated pdf
    $pdf.save-as: "tmp/pdf-updated.pdf";
```

- This module contains definitions for many other standard PDF objects, such as Pages, Fonts and Images, as listed below.
- There is generally a one-to-one correspondence between raw dictionary entries and accessors, e.g. `$pdf<Root><AA>` versus `$pdf.Root.AA`.
- There are often accessor aliases, to aide clarity. E.g. `$pdf.Root.AA` can also be written as `$pdf.catalog.additional-actions`.
- The classes often contain additional accessor and helper methods. For example `$pdf.page(10)` - references page 10, without the need to navigate the catalog and page tree.

This module is a work in progress. It currently defines roles and classes for many of the more commonly occurring PDF objects as described in the [PDF 32000-1:2008 1.7](http://www.adobe.com/content/dam/Adobe/en/devnet/acrobat/pdfs/PDF32000_2008.pdf) specification.

## More examples:

### Set Marked Info options
```
    use PDF::Class;
    use PDF::Catalog;
    my PDF::Class $pdf .= new;
    my PDF::Catalog $catalog = $pdf.catalog; # same as $pdf.Root;
    with $catalog.MarkInfo //= {} {
        .Marked = True;
        .UserProperties = False;
        .Suspects = False;
    }
```


### Set Page Layout & Viewer Preferences
```
    use PDF::Class;
    use PDF::Catalog;
    my PDF::Class $pdf .= new;

    my PDF::Catalog $doc = $pdf.catalog;
    $doc.PageLayout = 'TwoColumnLeft';
    $doc.PageMode   = 'UseThumbs';

    given $doc.ViewerPreferences //= {} {
        .Duplex = 'DuplexFlipShortEdge';
        .NonFullScreenPageMode = 'UseOutlines';
    }
    # ...etc, see PDF::ViewerPreferences
```

### List AcroForm Fields

```
use PDF::Class;
use PDF::AcroForm;
use PDF::Field;

my PDF::Class $doc .= open: "t/pdf/samples/OoPdfFormExample.pdf";
with my PDF::AcroForm $acroform = $doc.catalog.AcroForm {
    my PDF::Field @fields = $acroform.fields;
    # display field names and values
    for @fields -> $field {
        say "{$field.key}: {$field.value}";
    }
}

```

## Gradual Typing

In theory, we should always be able to use PDF::Class accessors for structured access and updating of PDF objects.

In reality, a fair percentage of PDF files contain at least some conformance issues (as reported by `pdf-checker.p6`) and PDF::Class itself
is under development.

For these reasons it possible to bypass PDF::Class accessors; instead accessing hashes and arrays directly, giving raw access to the PDF data.

This will also bypass type coercements, so you may need to be more explicit. In
the following example we cast the PageMode to a name, so it appears as a name
in the out put stream `:name<UseToes>`, rather than a string `'UseToes'`.

```
    use PDF::Class;
    use PDF::Catalog;
    my PDF::Class $pdf .= new;

    my PDF::Catalog $doc = $pdf.catalog;
    try {
        $doc.PageMode   = 'UseToes';
        CATCH { default { say "err, that didn't work: $_" } }
    }

    # same again, bypassing type checking
    $doc<PageMode>  = :name<UseToes>;
```

## Scripts in this Distribution

#### `pdf-append.p6 --save-as=output.pdf in1.pdf in2.pdf ...`

appends PDF files.

#### `pdf-burst.p6 --save-as=basename-%03d.pdf --password=pass in.pdf`

bursts a multi-page PDF into single page PDF files

#### `pdf-checker.p6 --trace --render --strict --exclude=Entry1,Entry2 --repair input-pdf`

This is a low-level tool for PDF authors and users. It traverses a PDF, checking it's internal structure against
PDF:Class definitions as derived from the [PDF 32000-1:2008 1.7](http://www.adobe.com/content/dam/Adobe/en/devnet/acrobat/pdfs/PDF32000_2008.pdf) specification.

 - `--trace` print a dump of PDF Objects as the file is traversed
 - `--render` also render and check the contents of graphical objects, such as Pages and XObject forms
 - `--strict` perform additional checks:
  - `--repair` repair PDF before Checking

#### Example 1: Dump a simple PDF

    % pdf-checker.p6 --trace t/helloworld.pdf
    xref:   << /ID ... /Info 1 0 R /Root 2 0 R >>   % PDF::Class
      /ID:  [ "×C¨\x[86]üÜø\{iÃeH!\x[9E]©A" "×C¨\x[86]üÜø\{iÃeH!\x[9E]©A" ] % PDF::COS::Array[Str]
      /Info:        << /Author "t/helloworld.t" /CreationDate (D:20151225000000Z00'00') /Creator "PDF::Class" /Producer "Perl 6 PDF::Class 0.2.5" >>        % PDF::COS::Dict+{PDF::Info}
      /Root:        << /Type /Catalog /Pages 3 0 R >>       % PDF::Catalog
        /Pages:     << /Type /Pages /Count 1 /Kids ... /Resources ... >>    % PDF::Pages
          /Kids:    [ 4 0 R ]       % PDF::COS::Array[PDF::Content::PageNode]
            [0]:    << /Type /Page /Contents 5 0 R /MediaBox ... /Parent 3 0 R >>   % PDF::Page
              /Contents:    << /Length 1944 >>      % PDF::COS::Stream
              /MediaBox:    [ 0 0 595 842 ] % PDF::COS::Array[Numeric]
          /Resources:       << /ExtGState ... /Font ... /ProcSet ... /XObject ... >>        % PDF::COS::Dict+{PDF::Resources}
            /ExtGState:     << /GS1 6 0 R >>        % PDF::COS::Dict[Hash]
              /GS1: << /Type /ExtGState /ca 0.5 >>  % PDF::COS::Dict+{PDF::ExtGState}
            /Font:  << /F1 7 0 R /F2 8 0 R /F3 9 0 R >>     % PDF::COS::Dict[PDF::Resources::Font]
              /F1:  << /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold /Encoding /WinAnsiEncoding >>  % PDF::Font::Type1
              /F2:  << /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>       % PDF::Font::Type1
              /F3:  << /Type /Font /Subtype /Type1 /BaseFont /ZapfDingbats >>       % PDF::Font::Type1
            /ProcSet:       [ /PDF /Text ]  % PDF::COS::Array[PDF::COS::Name]
            /XObject:       << /Im1 10 0 R /Im2 11 0 R >>   % PDF::COS::Dict[PDF::Resources::XObject]
              /Im1: << /Type /XObject /Subtype /Image /BitsPerComponent 8 /ColorSpace /DeviceRGB /Filter /DCTDecode /Height 254 /Width 200 /Length 8247 >>  % PDF::XObject::Image
              /Im2: << /Type /XObject /Subtype /Image /BitsPerComponent 8 /ColorSpace ... /Height 42 /Width 37 /Length 1554 >>      % PDF::XObject::Image
                /ColorSpace:        [ /Indexed /DeviceRGB 255 12 0 R ]      % PDF::ColorSpace::Indexed
                  [3]:      << /Length 768 >>       % PDF::COS::Stream
    Checking of t/helloworld.pdf completed with 0 warnings and 0 errors

This example dumps a PDF and shows how PDF::Class has interpreted it.

- indirect object `1 0 R` is a dictionary that has had the `PDF::Info` role applied
- indirect object `2 0 R` has been loaded as a `PDF::Catalog` object.
- font `/F3` is a ZapfDingbats type1 font

The PDF contains has one page (PDF::Page) that references various other objects, such as fonts and
xobject images.

#### Example 2: Check a sample PDF

    % wget http://www.stillhq.com/pdfdb/000025/data.pdf
    % pdf-checker.p6 --strict --render data.pdf
    Warning: Error processing indirect object 27 0 R at byte offset 976986:
    Ignoring 1 bytes before 'endstream' marker
    Rendering warning(s) in 28 0 R (PDF::Page):
    -- unexpected operation 'w' (SetLineWidth) used in Path context, following 'm' (MoveTo)
    -- unexpected operation 'w' (SetLineWidth) used in Path context, following 'm' (MoveTo)
    Rendering warning(s) in 30 0 R  (PDF::XObject::Form):
    -- unexpected operation 'w' (SetLineWidth) used in Path context, following 'm' (MoveTo)
    Unknown entries 1 0 R (PDF::Catalog) struct: /ViewPreferences
    Checking of /home/david/Documents/test-pdf/000025.pdf completed with 5 warnings and 0 errors

In this example:

- Object `28 0 R` had an extra byte in its stream data.
- Some Page and XObject graphics operations were not in the
   expected order, (as outlined in PDF 32000 Figure 9 – Graphics Objects).
- The Catalog dictionary had an unexpected `/ViewPreferences`
   entry (It should be `/ViewerPreferences`, see PDF::Catalog).

##### Notes

- A message such as `No handler class PDF::Filespec`, usually indicates the the object has not yet been implemented in PDF::Class.

#### `pdf-content-dump.p6 --perl in.pdf`

Displays the content streams for PDF pages, commented,
and in a human-readable format:

    % pdf-content-dump.p6 t/example.pdf 
    % **** Page 1 ****
    BT % BeginText
      1 0 0 1 100 150 Tm % SetTextMatrix
      /F1 16 Tf % SetFont
      17.6 TL % SetTextLeading
      [ (Hello, world!) ] TJ % ShowSpaceText
      T* % TextNextLine
    ET % EndText

The `--perl` option dumps using a Perl-like notation:

    pdf-content-dump.p6 --perl t/example.pdf 
    # **** Page 1 ****
    .BeginText();
      .SetTextMatrix(1, 0, 0, 1, 100, 150);
      .SetFont("F1", 16);
      .SetTextLeading(17.6);
      .ShowSpaceText($["Hello, world!"]);
      .TextNextLine();
    .EndText();

#### `pdf-info.p6 in.pdf`

Prints various PDF properties. For example:

    % pdf-info.p6 ~/Documents/test-pdfs/stillhq.com/000056.pdf 
    File:         /home/david/Documents/test-pdfs/stillhq.com/000056.pdf
    File Size:    63175 bytes
    Pages:        2
    Outlines:     no
    Author:       Prince Restaurant
    CreationDate: Wed Oct 03 23:41:01 2001
    Creator:      FrameMaker+SGML 6.0
    Keywords:     Pizza, Pasta, Antipasto, Lasagna, Food
    ModDate:      Thu Oct 04 00:03:04 2001
    Producer:     Acrobat PDFWriter 4.05  for Power Macintosh
    Subject:      Take Out & Catering Menu
    Title:        Prince Pizzeria & Bar
    Tagged:       no
    Page Size:    variable
    PDF version:  1.3
    Revisions:    1
    Encryption:   no

#### `pdf-revert.p6 --password=pass --save-as=out.pdf in.pdf`

undoes the last revision of an incrementally saved PDF file.

#### `pdf-toc.p6 --password=pass --/title --/labels in.pdf`

prints a table of contents, showing titles and page-numbers, using PDF outlines.

    % wget http://www.stillhq.com/pdfdb/000432/data.pdf
    % pdf-toc.p6 data.pdf
    Linux Kernel Modules Installation HOWTO
      Table of Contents . . . i
      1. Purpose of this Document . . . 1
      2. Pre-requisites . . . 2
      3. Compiler Speed-up . . . 3
      4. Recompiling the Kernel for Modules . . . 4
        5.1. Configuring Debian or RedHat for Modules . . . 5
        5.2. Configuring Slackware for Modules . . . 5
        5.3. Configuring Other Distributions for Modules . . . 6

Note that outlines are an optional PDF feature. `pdf-info.p6` can be
used to check if a PDF has them:

    % pdf-info.p6 my-doc.pdf | grep Outlines:

## Development Status

The PDF::Class module is under construction and not yet functionally complete.

## See also

- [PDF::Lite](https://github.com/p6-pdf/PDF-ISO_32000-p6) - A Lite-weight alternative
- [PDF::API6](https://github.com/p6-pdf/PDF-API6) - general purpose PDF manipulation, based on this
module (PDF::Class)
- [PDF::ISO_32000](https://github.com/p6-pdf/PDF-ISO_32000-p6) - A set of interface roles that have
been mined from the PDF 32000 specification, e.g. ISO_32000::Catalog.

## Classes Quick Reference

Class | Types | Accessors | Methods | Description | See Also
------|-------|-----------|---------|-------------|----------
PDF::Class | dict | Encrypt, ID, Info, Prev, Root(catalog), Size | Blob, Pages, ast, crypt, encrypt, open, permitted, save-as, update, version | PDF entry-point. either a trailer dict or an XRef stream | ISO_32000::File_trailer
PDF::Catalog | dict | AA(additional-actions), AcroForm, Collection, Dests, Extensions, Lang, Legal, MarkInfo, Metadata, Names, NeedsRendering, OCProperties, OpenAction, Outlines, OutputIntents, PageLabels, PageLayout, PageMode, Pages, Perms, PieceInfo, Requirements, Resources, SpiderInfo, StructTreeRoot, Threads, Type, URI, Version, ViewerPreferences | core-font, find-resource, images, resource-entry, resource-key, use-font, use-resource | /Type /Catalog - usually the document root in a PDF See [PDF 32000 Section 7.7.2 Document Catalog] | ISO_32000::Catalog
PDF::AcroForm | dict | CO(calculation-order), DA(default-appearance), DR(default-resources), Fields, NeedAppearances, Q(quadding), SigFlags, XFA | fields, fields-hash |  | ISO_32000::Interactive_form
PDF::Action::GoTo | dict | D(destination), Next, S, Type |  | /Action Subtype - GoTo | ISO_32000::Goto_action_additional ISO_32000::Action_common
PDF::Action::GoToR | dict | D(destination), F(file), NewWindow, Next, S, Type |  | /Action Subtype - GoToR | ISO_32000::Remote_goto_action_additional ISO_32000::Action_common
PDF::Action::JavaScript | dict | JS, Next, S, Type |  | /Action Subtype - GoTo | ISO_32000::JavaScript_action_additional ISO_32000::Action_common
PDF::Action::Launch | dict | F(file), Mac, NewWindow, Next, S, Type, Unix, Win |  | /Action Subtype - Launch | ISO_32000::Launch_action_additional ISO_32000::Action_common
PDF::Action::Named | dict | N(action-name), Next, S, Type |  | /Action Subtype - GoTo | ISO_32000::Named_action_additional ISO_32000::Action_common
PDF::Action::Thread | dict | B(bead), D(thread), F(file-spec), Next, S, Type |  | /Action Subtype - Thread | ISO_32000::Thread_action_additional ISO_32000::Action_common
PDF::Action::URI | dict | IsMap, Next, S, Type, URI |  | /Action Subtype - URI | ISO_32000::URI_action_additional ISO_32000::Action_common
PDF::Annot::Caret | dict | AP(appearance), AS(appearance-state), Border, C(color), CA(constant-opacity), Contents, CreationDate, DR(default-resources), ExData(external-data), F(flags), FT(field-type), IRT(reply-to-ref), IT(intent), M(mod-time), NM(annotation-name), OC(optional-content), P(page), Popup, RC(rich-text), RD(rectangle-differences), RT(reply-type), Rect, StructParent, Subj, Subtype, Sy(symbol), T(text-label), Type |  |  | ISO_32000::Caret_annotation_additional ISO_32000::Annotation_markup_additional ISO_32000::Annotation_common
PDF::Annot::Circle | dict | AP(appearance), AS(appearance-state), BE(border-effect), BS(border-style), Border, C(color), CA(constant-opacity), Contents, CreationDate, DR(default-resources), ExData(external-data), F(flags), FT(field-type), IC(interior-color), IRT(reply-to-ref), IT(intent), M(mod-time), NM(annotation-name), OC(optional-content), P(page), Popup, RC(rich-text), RD(rectangle-differences), RT(reply-type), Rect, StructParent, Subj, Subtype, T(text-label), Type |  |  | ISO_32000::Square_or_circle_annotation_additional ISO_32000::Annotation_markup_additional ISO_32000::Annotation_common
PDF::Annot::FileAttachment | dict | AP(appearance), AS(appearance-state), Border, C(color), CA(constant-opacity), Contents, CreationDate, DR(default-resources), ExData(external-data), F(flags), FS(file-spec), FT(field-type), IRT(reply-to-ref), IT(intent), M(mod-time), NM(annotation-name), Name(icon-name), OC(optional-content), P(page), Popup, RC(rich-text), RT(reply-type), Rect, StructParent, Subj, Subtype, T(text-label), Type |  |  | ISO_32000::File_attachment_annotation_additional ISO_32000::Annotation_markup_additional ISO_32000::Annotation_common
PDF::Annot::Link | dict | A(action), AP(appearance), AS(appearance-state), BS, Border, C(color), CA(constant-opacity), Contents, CreationDate, DR(default-resources), Dest, ExData(external-data), F(flags), FT(field-type), H(highlight-mode), IRT(reply-to-ref), IT(intent), M(mod-time), NM(annotation-name), OC(optional-content), P(page), PA(uri-action), Popup, QuadPoints, RC(rich-text), RT(reply-type), Rect, StructParent, Subj, Subtype, T(text-label), Type |  |  | ISO_32000::Link_annotation_additional ISO_32000::Annotation_markup_additional ISO_32000::Annotation_common
PDF::Annot::Markup | dict | AP(appearance), AS(appearance-state), Border, C(color), CA(constant-opacity), Contents, CreationDate, DR(default-resources), ExData(external-data), F(flags), FT(field-type), IRT(reply-to-ref), IT(intent), M(mod-time), NM(annotation-name), OC(optional-content), P(page), Popup, RC(rich-text), RT(reply-type), Rect, StructParent, Subj, Subtype, T(text-label), Type |  |  | ISO_32000::Annotation_markup_additional ISO_32000::Annotation_common
PDF::Annot::Popup | dict | AP(appearance), AS(appearance-state), Border, C(color), Contents, DR(default-resources), F(flags), FT(field-type), M(mod-time), NM(annotation-name), OC(optional-content), Open, P(page), Parent, Rect, StructParent, Subtype, Type |  |  | ISO_32000::Popup_annotation_additional ISO_32000::Annotation_common
PDF::Annot::Square | dict | AP(appearance), AS(appearance-state), BE(border-effect), BS(border-style), Border, C(color), CA(constant-opacity), Contents, CreationDate, DR(default-resources), ExData(external-data), F(flags), FT(field-type), IC(interior-color), IRT(reply-to-ref), IT(intent), M(mod-time), NM(annotation-name), OC(optional-content), P(page), Popup, RC(rich-text), RD(rectangle-differences), RT(reply-type), Rect, StructParent, Subj, Subtype, T(text-label), Type |  |  | ISO_32000::Square_or_circle_annotation_additional ISO_32000::Annotation_markup_additional ISO_32000::Annotation_common
PDF::Annot::Text | dict | AP(appearance), AS(appearance-state), Border, C(color), CA(constant-opacity), Contents, CreationDate, DR(default-resources), ExData(external-data), F(flags), FT(field-type), IRT(reply-to-ref), IT(intent), M(mod-time), NM(annotation-name), Name(icon-name), OC(optional-content), Open, P(page), Popup, RC(rich-text), RT(reply-type), Rect, State, StateModel, StructParent, Subj, Subtype, T(text-label), Type |  | /Type Annot - Annonation subtypes See [PDF 32000 Section 12.5 Annotations] | ISO_32000::Text_annotation_additional ISO_32000::Annotation_markup_additional ISO_32000::Annotation_common
PDF::Annot::ThreeD | dict | 3DA(activation), 3DB(view-box), 3DD(artwork), 3DI(interactive), 3DV(default-view), AP(appearance), AS(appearance-state), Border, C(color), Contents, DR(default-resources), F(flags), FT(field-type), M(mod-time), NM(annotation-name), OC(optional-content), P(page), Rect, StructParent, Subtype, Type |  |  | ISO_32000::Three-D_annotation ISO_32000::Annotation_common
PDF::Annot::Widget | dict | A(action), AA(additional-actions), AP(appearance), AS(appearance-state), BS(border-style), Border, C(color), Contents, DR(default-resources), F(flags), FT(field-type), H(highlight-mode), M(mod-time), MK, NM(annotation-name), OC(optional-content), P(page), Parent, Rect, StructParent, Subtype, Type |  |  | ISO_32000::Widget_annotation_additional ISO_32000::Annotation_common
PDF::Appearance | dict | D(down), N(normal), R(rollover) |  |  | ISO_32000::Appearance
PDF::Border | dict | D(dash-pattern), S(style), Type, W(width) |  |  | ISO_32000::Border_style
PDF::CIDSystemInfo | dict | Ordering, Registry, Supplement |  |  | ISO_32000::CIDSystemInfo
PDF::CMap | stream | CIDSystemInfo, CMapName, Type, UseCMap, WMode |  | /Type /CMap | ISO_32000::CMap_stream
PDF::ColorSpace::CalGray | array | Subtype, dict | props |  | 
PDF::ColorSpace::CalRGB | array | Subtype, dict | props |  | 
PDF::ColorSpace::DeviceN | array | AlternateSpace, Attributes, Names, Subtype, TintTransform |  |  | 
PDF::ColorSpace::ICCBased | array | Subtype, dict | props |  | 
PDF::ColorSpace::Indexed | array | Base, Hival, Lookup, Subtype |  |  | 
PDF::ColorSpace::Lab | array | Subtype, dict | props |  | 
PDF::ColorSpace::Pattern | array | Colorspace, Subtype |  |  | 
PDF::ColorSpace::Separation | array | AlternateSpace, Name, Subtype, TintTransform |  |  | 
PDF::Destination | array | fit, page | delegate-destination, is-page-ref |  | 
PDF::Encoding | dict | BaseEncoding, Differences, Type |  |  | ISO_32000::Encoding
PDF::ExData::Markup3D | dict | 3DA(activation), 3DV(default-view), MD5, Subtype, Type |  |  | ISO_32000::Three-D_external_data
PDF::ExtGState | dict | AIS(alpha-source-flag), BG(black-generation-old), BG2(black-generation), BM(blend-mode), CA(stroke-alpha), D(dash-pattern), FL(flatness-tolerance), Font, HT(halftone), LC(line-cap), LJ(line-join), LW(line-width), ML(miter-limit), OP(overprint-paint), OPM(overprint-mode), RI(rendering-intent), SA(stroke-adjustment), SM(smoothness-tolerance), SMask(soft-mask), TK(text-knockout), TR(transfer-function-old), TR2(transfer-function), Type, UCR(under-color-removal-old), UCR2(under-color-removal), ca(fill-alpha), op(overprint-stroke) | transparency |  | ISO_32000::Graphics_state
PDF::Field::Button | dict | DV(default-value), Opt, V(value) |  |  | ISO_32000::Check_box_and_radio_button_additional
PDF::Field::Choice | dict | DV(default-value), I(indices), Opt, TI(top-index), V(value) |  |  | ISO_32000::Choice_field_additional
PDF::Field::Signature | dict | Lock, SV(seed-value), V(value) | DV |  | ISO_32000::Signature_field
PDF::Field::Text | dict | DV(default-value), MaxLen, V(value) |  |  | ISO_32000::Text_field_additional
PDF::Filespec | dict | CI, DOS, Desc, EF(embedded-files), F(file-name), FS(file-system), ID, Mac, RF(related-files), Type(type), UF, Unix, V(volatile) |  |  |
PDF::Font::CIDFont | dict | BaseFont, CIDSystemInfo, CIDToGIDMap, DW(default-width), DW2(default-width-and-height), FontDescriptor, Subtype, Type, W(widths), W2(heights) | font-obj, make-font, set-font-obj |  | ISO_32000::CIDFont
PDF::Font::CIDFontType0 | dict | BaseFont, CIDSystemInfo, CIDToGIDMap, DW(default-width), DW2(default-width-and-height), FontDescriptor, Subtype, Type, W(widths), W2(heights) | font-obj, make-font, set-font-obj |  | ISO_32000::CIDFont
PDF::Font::CIDFontType2 | dict | BaseFont, CIDSystemInfo, CIDToGIDMap, DW(default-width), DW2(default-width-and-height), FontDescriptor, Subtype, Type, W(widths), W2(heights) | font-obj, make-font, set-font-obj |  | ISO_32000::CIDFont
PDF::Font::MMType1 | dict | BaseFont, Encoding, FirstChar, FontDescriptor, LastChar, Name, Subtype, ToUnicode, Type, Widths | font-obj, make-font, set-font-obj |  | ISO_32000::Type_1_Font
PDF::Font::TrueType | dict | BaseFont, Encoding, FirstChar, FontDescriptor, LastChar, Name, Subtype, ToUnicode, Type, Widths | font-obj, make-font, set-font-obj | TrueType fonts - /Type /Font /Subtype TrueType see [PDF 32000 Section 9.6.3 TrueType Fonts] | ISO_32000::Type_1_Font
PDF::FontDescriptor::CID | dict | CIDSet, FD, Lang, Style |  |  | 
PDF::FontFile | stream | Length1, Length2, Length3, Metadata, Subtype |  |  | ISO_32000::Embedded_font_stream_additional
PDF::FontStream | dict | Length1, Length2, Length3, Metadata |  |  | 
PDF::Function::Exponential | stream | C0, C1, Domain, FunctionType, N, Range | calc, calculator | /FunctionType 2 - Exponential | ISO_32000::Type_2_Function ISO_32000::Function_common
PDF::Function::PostScript | stream | Domain, FunctionType, Range | calc, calculator, parse | /FunctionType 4 - PostScript see [PDF 32000 Section 7.10.5 Type 4 (PostScript Transform) Functions] | ISO_32000::Function_common
PDF::Function::Sampled | stream | BitsPerSample, Decode, Domain, Encode, FunctionType, Order, Range, Size | calc, calculator | /FunctionType 0 - Sampled see [PDF 32000 Section 7.10.2 Type 0 (Sampled) Functions] | ISO_32000::Type_0_Function ISO_32000::Function_common
PDF::Function::Stitching | stream | Bounds, Domain, Encode, FunctionType, Functions, Range | calc, calculator | /FunctionType 3 - Stitching see [PDF 32000 Section 7.4.10 Type 3 (Stitching) Functions] | ISO_32000::Type_3_Function ISO_32000::Function_common
PDF::Group::Transparency | dict | CS(color-space), I(isolated), K(knockout), S, Type |  |  | ISO_32000::Transparency_group_additional ISO_32000::Group_Attributes_common
PDF::ICCProfile | dict | Alternate, Metadata, N(num-colors), Range |  |  | 
PDF::Image | stream | Alternates, BitsPerComponent, ColorSpace, Decode, Height, ID, ImageMask, Intent, Interpolate, Mask, Metadata, Name, OC(optional-content), OPI, SMask, SMaskInData, StructParent, Subtype, Type, Width | to-png |  | ISO_32000::Image
PDF::Info | dict | Title, Author, CreationDate, Creator, Keywords, ModDate, Producer, Subject, Trapped  |  |  | 
PDF::MCR | dict | MCID, Pg(page), Stm, StmOwn, Type |  |  | ISO_32000::Marked_content_reference
PDF::Mask::Alpha | dict | BC(backdrop-color), G(transparency-group), S(subtype), TR(transfer-function), Type |  |  | ISO_32000::Soft-mask
PDF::Mask::Luminosity | dict | BC(backdrop-color), G(transparency-group), S(subtype), TR(transfer-function), Type |  |  | ISO_32000::Soft-mask
PDF::Metadata::XML | stream | Metadata, Subtype, Type |  |  | ISO_32000::Metadata_stream_additional
PDF::NameTree | dict | Kids, Limits, Names |  |  | ISO_32000::Name_tree_node
PDF::NumberTree | dict | Kids, Limits, Nums |  |  | ISO_32000::Number_tree_node
PDF::OBJR | dict | Obj, Pg(page), Type |  | /Type /OBJR - Object Reference dictionary | ISO_32000::Object_reference
PDF::OCG | dict | Intent, Name, Type, Usage |  |  | ISO_32000::Optional_Content_Group
PDF::OCMD | dict | OCGs, P(visibility-policy), Type, VE(visibility-expression) |  |  | ISO_32000::Optional_Content_Group_Membership
PDF::Outline | dict | A(action), C(color), Count, Dest, F(flags), First, Last, Next, Parent, Prev, SE(structure-element), Title |  |  | ISO_32000::Outline_item
PDF::Outlines | dict | Count, First, Last, Type |  |  | ISO_32000::Outline
PDF::OutputIntent::GTS_PDFX | dict | DestOutputProfile, Info, OutputCondition, OutputConditionIdentifier, RegistryName, S, Type |  |  | ISO_32000::Output_intent
PDF::Page | dict | AA(additional-actions), Annots, ArtBox, B(beads), BleedBox, BoxColorInfo, Contents, CropBox, Dur(display-duration), Group, ID, LastModified, MediaBox, Metadata, PZ(preferred-zoom), Parent, PieceInfo, PresSteps, Resources, Rotate, SeparationInfo, StructParents(struct-parent), Tabs, TemplateInstantiated, Thumb(thumbnail-image), Trans(transition-effect), TrimBox, Type, UserUnit, VP(view-ports) | art-box, bbox, bleed-box, canvas, contents, contents-parse, core-font, crop-box, fields, fields-hash, find-resource, finish, gfx, graphics, has-pre-gfx, height, images, media-box, new-gfx, pre-gfx, pre-graphics, render, resource-entry, resource-key, save-as-image, text, tiling-pattern, to-landscape, to-xobject, trim-box, use-font, use-resource, width, xobject-form | /Type /Page - describes a single PDF page | ISO_32000::Page
PDF::Pages | dict | Count, CropBox, Kids, MediaBox, Parent, Resources, Rotate, Type | add-page, add-pages, art-box, bbox, bleed-box, core-font, crop-box, find-resource, height, images, media-box, page-count, page-index, resource-entry, resource-key, to-landscape, trim-box, use-font, use-resource, width | /Type /Pages - a node in the page tree | ISO_32000::Pages
PDF::Pattern::Shading | dict | ExtGState, Matrix, PatternType, Shading, Type |  | /ShadingType 2 - Axial | ISO_32000::Type_2_Pattern
PDF::Pattern::Tiling | stream | BBox, Matrix, PaintType, PatternType, Resources, TilingType, Type, XStep, YStep | canvas, contents, contents-parse, core-font, find-resource, finish, gfx, graphics, has-pre-gfx, height, images, new-gfx, pre-gfx, pre-graphics, render, resource-entry, resource-key, save-as-image, text, tiling-pattern, use-font, use-resource, width, xobject-form | /PatternType 1 - Tiling | ISO_32000::Type_1_Pattern
PDF::Resources | dict | ColorSpace, ExtGState, Font, Pattern, ProcSet, Properties, Shading, XObject |  |  | ISO_32000::Resource
PDF::Signature | dict | ByteRange, Cert, Changes, ContactInfo, Contents, Location, M(date-signed), Name, Prop_AuthTime, Prop_AuthType, Prop_Build, R, Reason, Reference, SubFilter, Type, V |  |  |
PDF::Shading::Axial | dict | AntiAlias, BBox, Background, ColorSpace, Coords, Domain, Extend, Function, ShadingType |  | /ShadingType 2 - Axial | ISO_32000::Type_2_Shading ISO_32000::Shading_common
PDF::Shading::Coons | stream | AntiAlias, BBox, Background, BitsPerComponent, BitsPerCoordinate, BitsPerFlag, ColorSpace, Decode, Function, ShadingType |  | /ShadingType 6 - Coons | ISO_32000::Type_6_Shading ISO_32000::Shading_common
PDF::Shading::FreeForm | stream | AntiAlias, BBox, Background, BitsPerComponent, BitsPerCoordinate, BitsPerFlag, ColorSpace, Decode, Function, ShadingType |  | /ShadingType 4 - FreeForm | ISO_32000::Type_4_Shading ISO_32000::Shading_common
PDF::Shading::Function | dict | AntiAlias, BBox, Background, ColorSpace, Domain, Function, Matrix, ShadingType |  | /ShadingType 1 - Functional | ISO_32000::Type_1_Shading ISO_32000::Shading_common
PDF::Shading::Lattice | stream | AntiAlias, BBox, Background, BitsPerComponent, BitsPerCoordinate, ColorSpace, Decode, Function, ShadingType, VerticesPerRow |  | /ShadingType 5 - Lattice | ISO_32000::Type_5_Shading ISO_32000::Shading_common
PDF::Shading::Radial | dict | AntiAlias, BBox, Background, ColorSpace, Coords, Domain, Extend, Function, ShadingType |  | /ShadingType 3 - Radial | ISO_32000::Type_3_Shading ISO_32000::Shading_common
PDF::Shading::Tensor | stream | AntiAlias, BBox, Background, BitsPerComponent, BitsPerCoordinate, BitsPerFlag, ColorSpace, Decode, Function, ShadingType |  | /ShadingType 7 - Tensor | ISO_32000::Type_6_Shading ISO_32000::Shading_common
PDF::Signature | dict | ByteRange, Cert, Changes, ContactInfo, Contents, Location, M(date-signed), Name, Prop_AuthTime, Prop_AuthType, Prop_Build, Reason, Reference, SubFilter, Type, V |  |  | ISO_32000::Signature
PDF::StructElem | dict | A(attributes), ActualText, Alt(alternative-description), C, E(expanded-form), ID, K(kids), Lang, P(parent), Pg(page), R(revision), S(structure-type), T(title), Type |  | | ISO_32000::Structure_tree_element
PDF::StructTreeRoot | dict | ClassMap, IDTree, K(kids), ParentTree, ParentTreeNextKey, RoleMap, Type |  |  | ISO_32000::Structure_tree_root
PDF::ViewerPreferences | dict | CenterWindow, Direction, DisplayDocTitle, Duplex, FitWindow, HideMenubar, HideToolbar, HideWindowUI, NonFullScreenPageMode, NumCopies, PickTrayByPDFSize, PrintArea, PrintPageRange, PrintScaling, ViewArea, ViewClip |  |  | ISO_32000::Viewer_preferences
PDF::XObject::Form | stream | BBox, FormType, Group, LastModified, Matrix, Metadata, Name, OC(optional-content-group), OPI, PieceInfo, Ref, Resources, StructParent, StructParents, Subtype, Type | canvas, contents, contents-parse, core-font, find-resource, finish, gfx, graphics, has-pre-gfx, height, images, new-gfx, pre-gfx, pre-graphics, render, resource-entry, resource-key, save-as-image, text, tiling-pattern, use-font, use-resource, width, xobject-form | XObject Forms - /Type /XObject /Subtype Form See [PDF Spec 1.7 4.9 Form XObjects] | ISO_32000::Type_1_Form
PDF::XObject::Image | stream | Alternates, BitsPerComponent, ColorSpace, Decode, Height, ID, ImageMask, Intent, Interpolate, Mask, Metadata, Name, OC(optional-content), OPI, SMask, SMaskInData, StructParent, Subtype, Type, Width | height, image-obj, inline-content, inline-to-xobject, to-png, width | XObjects /Type XObject /Subtype /Image See [PDF 32000 Section 8.9 - Images ] | ISO_32000::Image
PDF::XObject::PS | stream | Level1, Subtype, Type |  | Postscript XObjects /Type XObject /Subtype PS See [PDF 32000 Section 8.8.2 PostScript XObjects] | ISO_32000::Postscript_XObject

*(generated by `etc/make-quick-ref.pl`)*
