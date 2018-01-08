# PDF::Class

This module provides a set of classes and accessors that map to the internal structure of PDF documents as described int the PDF 1.7 Reference Guide.

This module is a work in progress. It currently many of the more commonly used PDF objects.

The top level of a PDF document is of type `PDF::Class`. It contains the `PDF::Catalog` in its root entry. Other classess in the document are accessable from the Catalog.


```
    use PDF::Class;
    use PDF::Catalog;
    my PDF::Class $pdf .= new;
    my PDF::Catalog $catalog = $pdf.Root;
    with $catalog.MarkInfo //= {} {
        .Marked = True;
        .UserProperties = False;
        .Suspects = False;
    }
```


### Page Layout & Viewer Preferences
```
    use PDF::Class;
    use PDF::Catalog;
    my PDF::Class $pdf .= new;

    my PDF::Catalog $doc = $pdf.Root;
    $doc.PageLayout = 'TwoColumnLeft';
    $doc.PageMode   = 'UseThumbs';

    given $doc.ViewerPreferences //= {} {
        .Duplex = 'DuplexFlipShortEdge';
        .NonFullScreenPageMode = 'UseOutlines';
    }
    # ...etc, see PDF::ViewerPreferences
```

### AcroForm Fields

```
use PDF::Class;
use PDF::AcroForm;
use PDF::Field;

my PDF::Class $doc .= open: "t/pdf/samples/OoPdfFormExample.pdf";
with my PDF::AcroForm $acroform = $doc.Root.AcroForm {
    my PDF::Field @fields = $acroform.fields;
    # display field names and values
    for @fields -> $field {
        say "{$field.T // '??'}: {$field.V // ''}";
    }
}

```

## Raw Data Access

In general, PDF provides accessors for safe access and update of PDF objects.

However you may choose to bypass these accessors and dereference hashes and arrays directly, giving raw untyped access to internal data structures:

This will also bypass type coercements, so you may need to be more explicit. In
the following example we cast the PageMode to a name, so it appears as a name
in the out put stream `/UseToes`, rather than a string `(UseToes)`.

```
    use PDF::Class;
    my PDF::Class $pdf .= new;

    my $doc = $pdf.Root;
    try {
        $doc.PageMode   = 'UseToes';
        CATCH { default { say "err, that didn't work: $_" } }
    }

    # same again, bypassing type checking
    $doc<PageMode>  = :name<UseToes>;
```

## Development Status

The PDF::Class module is under construction and not yet functionally complete.

## Classes Quick Reference

Class | Types | Accessors | Methods | Description
------|-------|-----------|---------|------------
PDF::Class | dict | Encrypt, ID, Info, Root, Size | Pages, ast, crypt, encrypt, open, permitted, save-as, update, version | PDF entry-point. either a trailer dict or an XRef stream
PDF::Catalog | dict | AA, AcroForm, Collection, Dests, Lang, Legal, MarkInfo, Metadata, Names, NeedsRendering, OCProperties, OpenAction, Outlines, OutputIntents, PageLabels, PageLayout, PageMode, Pages, Perms, PieceInfo, Requirements, Resources, SpiderInfo, StructTreeRoot, Threads, Type, URI, Version, ViewerPreferences | core-font, find-resource, images, resource-entry, resource-key, use-font, use-resource | /Type /Catalog - usually the document root in a PDF See [PDF 1.7 Section 3.6.1 Document Catalog]
PDF::AcroForm | dict | CO, DA, DR, Fields, NeedAppearances, Q, SigFlags, XFA | fields, fields-hash | 
PDF::Action::GoTo | dict | D |  | 
PDF::Annot::Circle | dict | AP, AS, BE, BS, Border, C, Contents, DR, IC, M, NM, OC, P, RD, Rect, StructParent, Subtype, Type |  | 
PDF::Annot::FileAttachment | dict | AP, AS, Border, C, Contents, DR, FS, M, NM, Name, OC, P, Rect, StructParent, Subtype, Type |  | 
PDF::Annot::Link | dict | A, AP, AS, Border, C, Contents, DR, Dest, H, M, NM, OC, P, PA, QuadPoints, Rect, StructParent, Subtype, Type |  | 
PDF::Annot::Square | dict | AP, AS, BE, BS, Border, C, Contents, DR, IC, M, NM, OC, P, RD, Rect, StructParent, Subtype, Type |  | 
PDF::Annot::Text | dict | AP, AS, Border, C, Contents, DR, M, NM, Name, OC, Open, P, Rect, State, StateModel, StructParent, Subtype, Type |  | /Type Annot - Annonation subtypes See [PDF 1.7 Section 8.4 Annotations]
PDF::Annot::Widget | dict | A, AA, AP, AS, BS, Border, C, Contents, DR, H, M, MK, NM, OC, P, Rect, StructParent, Subtype, Type |  | 
PDF::Appearance | dict | D, N, R |  | 
PDF::Border | dict | D, S, Type, W |  | 
PDF::CIDSystemInfo | dict | Ordering, Registry, Supplement |  | 
PDF::CMap | stream | CIDSystemInfo, CMapName, Type, UseCMap, WMode |  | /Type /CMap
PDF::ColorSpace::CalRGB | array | Subtype, dict | BlackPoint, Gamma, Matrix, WhitePoint | 
PDF::ColorSpace::DeviceN | array | AlternateSpace, Attributes, Names, Subtype, TintTransform |  | 
PDF::ColorSpace::ICCBased | array | Subtype, dict | Alternate, Metadata, N, Range | 
PDF::ColorSpace::Indexed | array | Base, Hival, Lookup, Subtype |  | 
PDF::ColorSpace::Lab | array | Subtype, dict | BlackPoint, Range, WhitePoint | 
PDF::ColorSpace::Separation | array | AlternateSpace, Name, Subtype, TintTransform |  | 
PDF::ExtGState | dict | AIS, BG, BG2, BM, CA, D, FL, Font, HT, LC, LJ, LW, ML, OP, OPM, RI, SA, SM, SMask, TK, TR, TR2, Type, UCR, UCR2, ca, op | black-generation, transfer-function, transparency, undercover-removal-function | /Type /ExtGState
PDF::Field::Button | dict | DV, Opt, V |  | 
PDF::Field::Choice | dict | DV, I, Opt, TI, V |  | 
PDF::Field::Signature | dict | Lock, SV |  | 
PDF::Field::Text | dict | DV, MaxLen, V |  | 
PDF::Font::CIDFontType0 | dict | BaseFont, CIDSystemInfo, DW, DW2, FontDescriptor, Subtype, Type, W, W2 | CIDToGIDMap, font-obj, make-font, set-font-obj | 
PDF::Font::CIDFontType2 | dict | BaseFont, CIDSystemInfo, DW, DW2, FontDescriptor, Subtype, Type, W, W2 | CIDToGIDMap, font-obj, make-font, set-font-obj | 
PDF::Font::MMType1 | dict | BaseFont, Encoding, FirstChar, FontDescriptor, LastChar, Name, Subtype, ToUnicode, Type, Widths | font-obj, make-font, set-font-obj | 
PDF::Font::TrueType | dict | BaseFont, Encoding, FirstChar, FontDescriptor, LastChar, Name, Subtype, ToUnicode, Type, Widths | font-obj, make-font, set-font-obj | TrueType fonts - /Type /Font /Subtype TrueType see [PDF 1.7 Section 5.5.2 TrueType Fonts]
PDF::FontFile | stream | Subtype |  | 
PDF::Function::Exponential | stream | C0, C1, Domain, FunctionType, N, Range | delegate-function | /FunctionType 2 - Exponential see [PDF 1.7 Section 3.9.2 Type 2 (Exponential Interpolation) Functions]
PDF::Function::PostScript | stream | Domain, FunctionType, Range | delegate-function, parse | /FunctionType 4 - PostScript see [PDF 1.7 Section 3.9.4 Type 4 (PostScript Calculator) Functions]
PDF::Function::Sampled | stream | BitsPerSample, Decode, Domain, Encode, FunctionType, Order, Range, Size | delegate-function | /FunctionType 0 - Sampled see [PDF 1.7 Section 3.9.1 Type 0 (Sampled) Functions]
PDF::Function::Stitching | stream | Bounds, Domain, Encode, FunctionType, Functions, Range | delegate-function | /FunctionType 3 - Stitching see [PDF 1.7 Section 3.9.3 Type 3 (Stitching) Functions]
PDF::Group::Transparency | dict | CS, I, K, S, Type |  | 
PDF::Metadata::XML | stream | Subtype, Type |  | 
PDF::NumberTree | dict | Kids, Limits, Nums |  | 
PDF::OBJR | dict | Obj, Pg, Type |  | /Type /OBJR - a node in the page tree
PDF::OutlineItem | dict | A, C, Count, Dest, First, Last, Next, Parent, Prev, SE, Title |  | 
PDF::Outlines | dict | Count, First, Last, Type |  | /Type /Outlines - the Outlines dictionary
PDF::OutputIntent::GTS_PDFX | dict | DestOutputProfile, Info, OutputCondition, OutputConditionIdentifier, RegistryName, S, Type |  | 
PDF::Page | dict | AA, Annots, ArtBox, B, BleedBox, BoxColorInfo, Contents, CropBox, Dur, Group, ID, LastModified, MediaBox, Metadata, PZ, Parent, PieceInfo, PressSteps, Resources, Rotate, SeparationInfo, StructParents, Tabs, TemplateInstantiated, Thumb, Trans, TrimBox, Type, UserUnit, VP | art-box, bbox, bleed-box, canvas, content-streams, contents, contents-parse, core-font, crop-box, find-resource, finish, gfx, graphics, has-pre-gfx, height, images, media-box, new-gfx, pre-gfx, pre-graphics, render, resource-entry, resource-key, text, tiling-pattern, to-landscape, to-xobject, trim-box, use-font, use-resource, width, xobject-form | /Type /Page - describes a single PDF page
PDF::Pages | dict | Count, CropBox, Kids, MediaBox, Parent, Resources, Type | add-page, add-pages, art-box, bbox, bleed-box, core-font, crop-box, find-resource, height, images, media-box, page-count, resource-entry, resource-key, to-landscape, trim-box, use-font, use-resource, width | /Type /Pages - a node in the page tree
PDF::Pattern::Shading | stream | ExtGState, Matrix, PatternType, Shading, Type | canvas, contents, contents-parse, core-font, delegate-pattern, find-resource, finish, gfx, graphics, has-pre-gfx, height, images, new-gfx, pre-gfx, pre-graphics, render, resource-entry, resource-key, text, tiling-pattern, use-font, use-resource, width, xobject-form | /ShadingType 2 - Axial
PDF::Pattern::Tiling | stream | BBox, Matrix, PaintType, PatternType, Resources, TilingType, Type, XStep, YStep | canvas, contents, contents-parse, core-font, delegate-pattern, find-resource, finish, gfx, graphics, has-pre-gfx, height, images, new-gfx, pre-gfx, pre-graphics, render, resource-entry, resource-key, text, tiling-pattern, use-font, use-resource, width, xobject-form | /ShadingType 1 - Tiling
PDF::Resources | dict | ColorSpace, ExtGState, Font, Pattern, ProcSet, Properties, Shading, XObject |  | 
PDF::ViewerPreferences | dict | CenterWindow, Direction, Duplex, FitWindow, HideMenuBar, HideToolbar, HideWindowUI, NonFullScreenPageMode, NumCopies, PickTrayByPDFSize, PrintArea, PrintPageRange, PrintScaling, ViewArea, ViewClip |  | 
PDF::XObject::Form | stream | BBox, FormType, Group, LastModified, Matrix, Metadata, OC, OPI, PieceInfo, Ref, Resources, StructParent, StructParents, Subtype, Type | canvas, contents, contents-parse, core-font, find-resource, finish, gfx, graphics, has-pre-gfx, height, images, new-gfx, pre-gfx, pre-graphics, render, resource-entry, resource-key, text, tiling-pattern, use-font, use-resource, width, xobject-form | XObject Forms - /Type /Xobject /Subtype Form See [PDF Spec 1.7 4.9 Form XObjects]
PDF::XObject::Image | stream | Alternatives, BitsPerComponent, ColorSpace, Decode, Height, ID, ImageMask, Intent, Interpolate, Mask, Metadata, Name, OC, OPI, SMask, SMaskInData, StructParent, Subtype, Type, Width | data-uri, height, image-obj, image-type, inline-content, inline-to-xobject, load-image, source, to-png, width | XObjects /Type XObject /Subtype /Image See [PDF 1.7 Section 4.8 - Images ]
PDF::XObject::PS | stream | Level1, Subtype, Type |  | Postscript XObjects /Type XObject /Subtype PS See [PDF 1.7 Section 4.7.1 PostScript XObjects]
