# PDF-ISO_32000-p6

The [PDF 32000-1:2008 1.7 Specification](http://www.adobe.com/content/dam/Adobe/en/devnet/acrobat/pdfs/PDF32000_2008.pdf) contains around 380 tables, of which about 280 can be considered data or object definitions.

The shear number of tables presents difficulties with cross referencing data against the specification and/or using the specification as a data dictionary for implementing classes and/or reading and validating PDF files.

Perusing the specification with a standard PDF reader isn't much fun. Visually, there's a table of contents, but that's it. Not even an index. There's a lot to wade through, which can make the analysis real-world PDF files a slog.

Fortunately at least the PDF specification file is itself a tagged PDF, so we have some ability to automatically extract content, which is exactly what this module has done. Extraction has been limited to tables. These are considered the most important and easily extracted from PDF files.

This repo contains resources that have been extracted from the specification, along with the scripts and make-files used to drive the extraction.

Resources include:

- a copy of the source [PDF-32000 specification](src/PDF32000_2008.pdf)
- A list of [tables and entries](#tables-and-entries)
- A reverse list mapping [entries to tables](#entry-to-table-mappings)
- [JSON Tables](resources) extracted from the above
- [generated Perl 6 interface roles](gen/lib/ISO_32000) for building and validating PDF objects
 XHTML tables that have been mined from the PDF-32000 1.7 specification.

The Perl 6 roles are named ISO_32000::Xxxx and contain method stubs and documentation for each entry in the role


## Tables

Data is available for all of the tables in the PDF-32000 1.7 specification:
```
use PDF::ISO_32000;
# Load data about the Document Information dictionary
my %info = PDF::ISO_32000.table: "Info_entries";
say %info<caption>;             # Table 317 – Entries in the document information dictionary
say %info<head>.join(" | ");    # Key | Type | Value
say %info<rows>[0].join(" | "); # Title | text string | (Optional; PDF 1.1) The document’s title.
```

The `table-index` method returns a list that maps table numbers to table names:

```
say PDF::ISO_32000.table-index[317] # Info_entries
```

The `appendix` method returns a hash index into the Appendix:

```
my $stream-ops = PDF::ISO_32000.appendix<A.1>;
say $stream-ops, # PDF_content_stream_operators
say PDF::ISO_32000.table($stream-ops)<caption>; #  Table A.1 – PDF content stream operators
```

## Roles

Roles are available for tables named `*_entries`, or `*_attributes`.

```
% p6doc ISO_320000:Info
% p6doc ISO_320000:Catalog
```

The roles also contain [method stubs](https://docs.perl6.org/language/objects#Stubs) for the entries that need to be implemented for the role. For example:

```
% cat << EOF > lib/Catalog.pm6
use ISO_32000::Catalog;
class Catalog does ISO_32000::Catalog {
}
EOF
% perl6 -I lib -M Catalog
===SORRY!=== Error while compiling /tmp/lib/Catalog.pm6 (Catalog)
Method 'SpiderInfo' must be implemented by Catalog because it is required by roles: ISO_32000::Catalog.
at lib/Catalog.pm6 (Catalog):1
```

## Scripts in this Distribution

##### `pdf-struct-dump.p6 --password=Xxxx --page=i --max-depth=j --search-tag=Ttt --select=k --obj-num=l --gen-num=m --render --atts --debug src/PDF32000_2008.pdf`

Dumps tagged PDF content as XML.

At the moment just does enough to semi-reliably extract content from the PDF ISO-32000 specification documents. Could evolve into a general purpose tool for mining elements from tagged PDF's. 


## ISO 3200 Tables

The following interface roles have been mined from the ISO-32000 specification

### Tables and Entries


ISO_32000 Reference|Role|Entries
----|-----|-----
Table 193 – Entries common to all action dictionaries|[Action_common](gen/lib/ISO_32000/Action_common.pm6)|/Type /S /Next
Table 21 – Additional encryption dictionary entries for the standard security handler|[Additional_encryption](gen/lib/ISO_32000/Additional_encryption.pm6)|/R /O /U /P /EncryptMetadata
Table 91 – Entries in an Alternate Image Dictionary|[Alternate_Image](gen/lib/ISO_32000/Alternate_Image.pm6)|/Image /DefaultForPrinting /OC
Table 194 – Entries in an annotation’s additional-actions dictionary|[Annotation_additional_actions](gen/lib/ISO_32000/Annotation_additional_actions.pm6)|/E /X /D /U /Fo /Bl /PO /PC /PV /PI
Table 164 – Entries common to all annotation dictionaries|[Annotation_common](gen/lib/ISO_32000/Annotation_common.pm6)|/Type /Subtype /Rect /Contents /P /NM /M /F /AP /AS /Border /C /StructParent /OC
Table 170 – Additional entries specific to markup annotations|[Annotation_markup_additional](gen/lib/ISO_32000/Annotation_markup_additional.pm6)|/T /Popup /CA /RC /CreationDate /IRT /Subj /RT /IT /ExData
Table 168 – Entries in an appearance dictionary|[Appearance](gen/lib/ISO_32000/Appearance.pm6)|/N /R /D
Table 189 – Entries in an appearance characteristics dictionary|[Appearance_characteristics](gen/lib/ISO_32000/Appearance_characteristics.pm6)|/R /BC /BG /CA /RC /AC /I /RI /IX /IF /TP
Table 330 – Property list entries for artifacts|[Artifact](gen/lib/ISO_32000/Artifact.pm6)|/Type /BBox /Attached /Subtype
Table 327 – Entry common to all attribute object dictionaries|[Attribute_object](gen/lib/ISO_32000/Attribute_object.pm6)|/O
Table 328 – Additional entries in an attribute object dictionary for user properties|[Attribute_object_for_user_properties](gen/lib/ISO_32000/Attribute_object_for_user_properties.pm6)|/O /P
Table 161 – Entries in a bead dictionary|[Bead](gen/lib/ISO_32000/Bead.pm6)|/Type /T /N /V /P /R
Table 167 – Entries in a border effect dictionary|[Border_effect](gen/lib/ISO_32000/Border_effect.pm6)|/S /I
Table 166 – Entries in a border style dictionary|[Border_style](gen/lib/ISO_32000/Border_style.pm6)|/Type /W /S /D
Table 360 – Entries in a box colour information dictionary|[Box_colour_information](gen/lib/ISO_32000/Box_colour_information.pm6)|/CropBox /BleedBox /TrimBox /ArtBox
Table 361 – Entries in a box style dictionary|[Box_style](gen/lib/ISO_32000/Box_style.pm6)|/C /W /S /D
Table 11 – Optional parameters for the CCITTFaxDecode filter|[CCITTFax_filter](gen/lib/ISO_32000/CCITTFax_filter.pm6)|/K /EndOfLine /EncodedByteAlign /Columns /Rows /EndOfBlock /BlackIs1 /DamagedRowsBeforeError
Table 117 – Entries in a CIDFont dictionary|[CIDFont](gen/lib/ISO_32000/CIDFont.pm6)|/Type /Subtype /BaseFont /CIDSystemInfo /FontDescriptor /DW /W /DW2 /W2 /CIDToGIDMap
Table 124 – Additional font descriptor entries for CIDFonts|[CIDFont_descriptor_additional](gen/lib/ISO_32000/CIDFont_descriptor_additional.pm6)|/Style /Lang /FD /CIDSet
Table 116 – Entries in a CIDSystemInfo dictionary|[CIDSystemInfo](gen/lib/ISO_32000/CIDSystemInfo.pm6)|/Registry /Ordering /Supplement
Table 120 – Additional entries in a CMap stream dictionary|[CMap_stream](gen/lib/ISO_32000/CMap_stream.pm6)|/Type /CMapName /CIDSystemInfo /WMode /UseCMap
Table 225 – CSS2 style attributes used in rich text strings|[CSS2_style](gen/lib/ISO_32000/CSS2_style.pm6)|/text-align /vertical-align /font-size /font-style /font-weight /font-family /font /color /text-decoration /font-stretch
Table 63 – Entries in a CalGray Colour Space Dictionary|[CalGray_colour_space](gen/lib/ISO_32000/CalGray_colour_space.pm6)|/WhitePoint /BlackPoint /Gamma
Table 64 – Entries in a CalRGB Colour Space Dictionary|[CalRGB_colour_space](gen/lib/ISO_32000/CalRGB_colour_space.pm6)|/WhitePoint /BlackPoint /Gamma /Matrix
Table 180 – Additional entries specific to a caret annotation|[Caret_annotation_additional](gen/lib/ISO_32000/Caret_annotation_additional.pm6)|/Subtype /RD /Sy
Table 28 – Entries in the catalog dictionary|[Catalog](gen/lib/ISO_32000/Catalog.pm6)|/Type /Version /Extensions /Pages /PageLabels /Names /Dests /ViewerPreferences /PageLayout /PageMode /Outlines /Threads /OpenAction /AA /URI /AcroForm /Metadata /StructTreeRoot /MarkInfo /Lang /SpiderInfo /OutputIntents /PieceInfo /OCProperties /Perms /Legal /Requirements /Collection /NeedsRendering
Table 31 – Entries in the name dictionary|[Catalog_Name_tree](gen/lib/ISO_32000/Catalog_Name_tree.pm6)|/Dests /AP /JavaScript /Pages /Templates /IDS /URLS /EmbeddedFiles /AlternatePresentations /Renditions
Table 197 – Entries in the document catalog’s additional-actions dictionary|[Catalog_additional_actions](gen/lib/ISO_32000/Catalog_additional_actions.pm6)|/WC /WS /DS /WP /DP
Table 235 – Entries in a certificate seed value dictionary|[Certificate_seed_value](gen/lib/ISO_32000/Certificate_seed_value.pm6)|/Type /Ff /Subject /SubjectDN /KeyUsage /Issuer /OID /URL /URLType
Table 227 – Additional entry specific to check box and radio button fields|[Check_box_and_radio_button_additional](gen/lib/ISO_32000/Check_box_and_radio_button_additional.pm6)|/Opt
Table 231 – Additional entries specific to a choice field|[Choice_field_additional](gen/lib/ISO_32000/Choice_field_additional.pm6)|/Opt /TI /I
Table 155 – Entries in a collection dictionary|[Collection](gen/lib/ISO_32000/Collection.pm6)|/Type /Schema /D /View /Sort
Table 157 – Entries in a collection field dictionary|[Collection_field](gen/lib/ISO_32000/Collection_field.pm6)|/Type /Subtype /N /O /V /E
Table 48 – Entries in a collection item dictionary|[Collection_item](gen/lib/ISO_32000/Collection_item.pm6)|/Type
Table 156 – Entries in a collection schema dictionary|[Collection_schema](gen/lib/ISO_32000/Collection_schema.pm6)|/Type
Table 158 – Entries in a collection sort dictionary|[Collection_sort](gen/lib/ISO_32000/Collection_sort.pm6)|/Type /S /A
Table 49 – Entries in a collection subitem dictionary|[Collection_subitem](gen/lib/ISO_32000/Collection_subitem.pm6)|/Type /D /P
Table 17 – Additional entries specific to a cross-reference stream dictionary|[Cross_reference_stream](gen/lib/ISO_32000/Cross_reference_stream.pm6)|/Type /Size /Index /Prev /W
Table 14 – Optional parameters for Crypt filters|[Crypt_filter](gen/lib/ISO_32000/Crypt_filter.pm6)|/Type /Name
Table 25 – Entries common to all crypt filter dictionaries|[Crypt_filter_common](gen/lib/ISO_32000/Crypt_filter_common.pm6)|/Type /CFM /AuthEvent /Length
Table 27 – Additional crypt filter dictionary entries for public-key security handlers|[Crypt_filter_public-key_additional](gen/lib/ISO_32000/Crypt_filter_public-key_additional.pm6)|/Recipients /EncryptMetadata
Table 13 – Optional parameter for the DCTDecode filter|[DCT_filter](gen/lib/ISO_32000/DCT_filter.pm6)|/ColorTransform
Table 319 – Entries in an data dictionary|[Data](gen/lib/ISO_32000/Data.pm6)|/LastModified /Private
Table 50 – Entries in a developer extensions dictionary|[Developer_extensions](gen/lib/ISO_32000/Developer_extensions.pm6)|/Type /BaseVersion /ExtensionLevel
Table 71 – Entries in a DeviceN Colour Space Attributes Dictionary|[DeviceN_colour_space](gen/lib/ISO_32000/DeviceN_colour_space.pm6)|/Subtype /Colorants /Process /MixingHints
Table 73 – Entries in a DeviceN Mixing Hints Dictionary|[DeviceN_mixing_hints](gen/lib/ISO_32000/DeviceN_mixing_hints.pm6)|/Solidities /PrintingOrder /DotGain
Table 72 – Entries in a DeviceN Process Dictionary|[DeviceN_process](gen/lib/ISO_32000/DeviceN_process.pm6)|/ColorSpace /Components
Table 254 – Entries in the DocMDP transform parameters dictionary|[DocMDP_transform](gen/lib/ISO_32000/DocMDP_transform.pm6)|/Type /P /V
Table 46 – Entries in an embedded file parameter dictionary|[Embedded_file_parameter](gen/lib/ISO_32000/Embedded_file_parameter.pm6)|/Size /CreationDate /ModDate /Mac /CheckSum
Table 45 – Additional entries in an embedded file stream dictionary|[Embedded_file_stream](gen/lib/ISO_32000/Embedded_file_stream.pm6)|/Type /Subtype /Params
Table 127 – Additional entries in an embedded font stream dictionary|[Embedded_font_stream_additional](gen/lib/ISO_32000/Embedded_font_stream_additional.pm6)|/Length1 /Length2 /Length3 /Subtype /Metadata
Table 201 – Additional entries specific to an embedded go-to action|[Embedded_goto_action_additional](gen/lib/ISO_32000/Embedded_goto_action_additional.pm6)|/S /F /D /NewWindow /T
Table 114 – Entries in an encoding dictionary|[Encoding](gen/lib/ISO_32000/Encoding.pm6)|/Type /BaseEncoding /Differences
Table 20 – Entries common to all encryption dictionaries|[Encryption_common](gen/lib/ISO_32000/Encryption_common.pm6)|/Filter /SubFilter /V /Length /CF /StmF /StrF /EFF
Table 251 – Additional entry for annotation dictionaries in an FDF file|[FDF_annotation_additional](gen/lib/ISO_32000/FDF_annotation_additional.pm6)|/Page
Table 242 – Entries in the FDF catalog dictionary|[FDF_catalog](gen/lib/ISO_32000/FDF_catalog.pm6)|/Version /FDF
Table 243 – Entries in the FDF dictionary|[FDF_dictionary](gen/lib/ISO_32000/FDF_dictionary.pm6)|/F /ID /Fields /Status /Pages /Encoding /Annots /Differences /Target /EmbeddedFDFs /JavaScript
Table 246 – Entries in an FDF field dictionary|[FDF_field](gen/lib/ISO_32000/FDF_field.pm6)|/Kids /T /V /Ff /SetFf /ClrFf /F /SetF /ClrF /AP /APRef /IF /Opt /A /AA /RV
Table 250 – Entries in an FDF named page reference dictionary|[FDF_named_page_reference](gen/lib/ISO_32000/FDF_named_page_reference.pm6)|/Name /F
Table 248 – Entries in an FDF page dictionary|[FDF_page](gen/lib/ISO_32000/FDF_page.pm6)|/Templates /Info
Table 249 – Entries in an FDF template dictionary|[FDF_template](gen/lib/ISO_32000/FDF_template.pm6)|/TRef /Fields /Rename
Table 241 – Entry in the FDF trailer dictionary|[FDF_trailer](gen/lib/ISO_32000/FDF_trailer.pm6)|/Root
Table 256 – Entries in the FieldMDP transform parameters dictionary|[FieldMDP_transform](gen/lib/ISO_32000/FieldMDP_transform.pm6)|/Type /Action /Fields /V
Table 220 – Entries common to all field dictionaries|[Field_common](gen/lib/ISO_32000/Field_common.pm6)|/FT /Parent /Kids /T /TU /TM /Ff /V /DV /AA
Table 184 – Additional entries specific to a file attachment annotation|[File_attachment_annotation_additional](gen/lib/ISO_32000/File_attachment_annotation_additional.pm6)|/Subtype /FS /Name
Table 44 – Entries in a file specification dictionary|[File_specification](gen/lib/ISO_32000/File_specification.pm6)|/Type /FS /F /UF /DOS /Mac /Unix /ID /V /EF /RF /Desc /CI
Table 15 – Entries in the file trailer dictionary|[File_trailer](gen/lib/ISO_32000/File_trailer.pm6)|/Size /Prev /Root /Encrypt /Info /ID
Table 191 – Entries in a fixed print dictionary|[Fixed_print](gen/lib/ISO_32000/Fixed_print.pm6)|/Type /Matrix /H /V
Table 284 – Entries in a floating window parameters dictionary|[Floating_window_parameter](gen/lib/ISO_32000/Floating_window_parameter.pm6)|/Type /D /RT /P /O /T /UC /R /TT
Table 122 – Entries common to all font descriptors|[Font_descriptor_common](gen/lib/ISO_32000/Font_descriptor_common.pm6)|/Type /FontName /FontFamily /FontStretch /FontWeight /Flags /FontBBox /ItalicAngle /Ascent /Descent /Leading /CapHeight /XHeight /StemV /StemH /AvgWidth /MaxWidth /MissingWidth /FontFile /FontFile2 /FontFile3 /CharSet
Table 332 – Font selector attributes|[Font_selector](gen/lib/ISO_32000/Font_selector.pm6)|/FontFamily /GenericFontFamily /FontSize /FontStretch /FontStyle /FontVariant /FontWeight
Table 196 – Entries in a form field’s additional-actions dictionary|[Form_additional_actions](gen/lib/ISO_32000/Form_additional_actions.pm6)|/K /F /V /C
Table 174 – Additional entries specific to a free text annotation|[Free_text_annotation_additional](gen/lib/ISO_32000/Free_text_annotation_additional.pm6)|/Subtype /DA /Q /RC /DS /CL /IT /BE /RD /BS /LE
Table 38 – Entries common to all function dictionaries|[Function_common](gen/lib/ISO_32000/Function_common.pm6)|/FunctionType /Domain /Range
Table 216 – Additional entries specific to a go-to-3D-view action|[Goto_3D_view_action_additional](gen/lib/ISO_32000/Goto_3D_view_action_additional.pm6)|/S /TA /V
Table 199 – Additional entries specific to a go-to action|[Goto_action_additional](gen/lib/ISO_32000/Goto_action_additional.pm6)|/S /D
Table 58 – Entries in a Graphics State Parameter Dictionary|[Graphics_state](gen/lib/ISO_32000/Graphics_state.pm6)|/Type /LW /LC /LJ /ML /D /RI /OP /op /OPM /Font /BG /BG2 /UCR /UCR2 /TR /TR2 /HT /FL /SM /SA /BM /SMask /CA /ca /AIS /TK
Table 96 – Entries Common to all Group Attributes Dictionaries|[Group_Attributes_common](gen/lib/ISO_32000/Group_Attributes_common.pm6)|/Type /S
Table 210 – Additional entries specific to a hide action|[Hide_action_additional](gen/lib/ISO_32000/Hide_action_additional.pm6)|/S /T /H
Table 19 – Additional entries in a hybrid-reference file’s trailer dictionary|[Hybrid-reference](gen/lib/ISO_32000/Hybrid-reference.pm6)|/XRefStm
Table 66 – Additional Entries Specific to an ICC Profile Stream Dictionary|[ICC_profile](gen/lib/ISO_32000/ICC_profile.pm6)|/N /Alternate /Range /Metadata
Table 247 – Entries in an icon fit dictionary|[Icon_fit](gen/lib/ISO_32000/Icon_fit.pm6)|/SW /S /A /FB
Table 89 – Additional Entries Specific to an Image Dictionary|[Image](gen/lib/ISO_32000/Image.pm6)|/Type /Subtype /Width /Height /ColorSpace /BitsPerComponent /Intent /ImageMask /Mask /Decode /Interpolate /Alternates /SMask /SMaskInData /Name /StructParent /ID /OPI /Metadata /OC
Table 240 – Additional entries specific to an import-data action|[Import-data_action_additional](gen/lib/ISO_32000/Import-data_action_additional.pm6)|/S /F
Table 317 – Entries in the document information dictionary|[Info](gen/lib/ISO_32000/Info.pm6)|/Title /Author /Subject /Keywords /Creator /Producer /CreationDate /ModDate /Trapped
Table 182 – Additional entries specific to an ink annotation|[Ink_annotation_additional](gen/lib/ISO_32000/Ink_annotation_additional.pm6)|/Subtype /InkList /BS
Table 93 – Entries in an Inline Image Object|[Inline_Image](gen/lib/ISO_32000/Inline_Image.pm6)|/BitsPerComponent /ColorSpace /Decode /DecodeParms /Filter /Height /ImageMask /Intent /Interpolate /Width
Table 218 – Entries in the interactive form dictionary|[Interactive_form](gen/lib/ISO_32000/Interactive_form.pm6)|/Fields /NeedAppearances /SigFlags /CO /DR /DA /Q /XFA
Table 12 – Optional parameter for the JBIG2Decode filter|[JBIG2_filter](gen/lib/ISO_32000/JBIG2_filter.pm6)|/JBIG2Globals
Table 245 – Entries in the JavaScript dictionary|[JavaScript](gen/lib/ISO_32000/JavaScript.pm6)|/Before /After /AfterPermsReady /Doc
Table 217 – Additional entries specific to a JavaScript action|[JavaScript_action_additional](gen/lib/ISO_32000/JavaScript_action_additional.pm6)|/S /JS
Table 8 – Optional parameters for LZWDecode and FlateDecode filters|[LZW_and_Flate_filter](gen/lib/ISO_32000/LZW_and_Flate_filter.pm6)|/Predictor /Colors /BitsPerComponent /Columns /EarlyChange
Table 65 – Entries in a Lab Colour Space Dictionary|[Lab_colour_space](gen/lib/ISO_32000/Lab_colour_space.pm6)|/WhitePoint /BlackPoint /Range
Table 203 – Additional entries specific to a launch action|[Launch_action_additional](gen/lib/ISO_32000/Launch_action_additional.pm6)|/S /F /Win /Mac /Unix /NewWindow
Table 259 – Entries in a legal attestation dictionary|[Legal_attestation](gen/lib/ISO_32000/Legal_attestation.pm6)|/JavaScriptActions /LaunchActions /URIActions /MovieActions /SoundActions /HideAnnotationActions /GoToRemoteActions /AlternateImages /ExternalStreams /TrueTypeFonts /ExternalRefXobjects /ExternalOPIdicts /NonEmbeddedFonts /DevDepGS_OP /DevDepGS_HT /DevDepGS_TR /DevDepGS_UCR /DevDepGS_BG /DevDepGS_FL /Annotations /OptionalContent /Attestation
Table 175 – Additional entries specific to a line annotation|[Line_annotation_additional](gen/lib/ISO_32000/Line_annotation_additional.pm6)|/Subtype /L /BS /LE /IC /LL /LLE /Cap /IT /LLO /CP /Measure /CO
Table F. 1 – Entries in the linearization parameter dictionary|[Linearization_parameter](gen/lib/ISO_32000/Linearization_parameter.pm6)|/Linearized /L /H /O /E /N /T /P
Table 173 – Additional entries specific to a link annotation|[Link_annotation_additional](gen/lib/ISO_32000/Link_annotation_additional.pm6)|/Subtype /A /Dest /H /PA /QuadPoints /BS
Table 47 – Entries in a Mac OS file information dictionary|[MacOS_file_information](gen/lib/ISO_32000/MacOS_file_information.pm6)|/Subtype /Creator /ResFork
Table 321 – Entries in the mark information dictionary|[Mark_information](gen/lib/ISO_32000/Mark_information.pm6)|/Marked /UserProperties /Suspects
Table 324 – Entries in a marked-content reference dictionary|[Marked_content_reference](gen/lib/ISO_32000/Marked_content_reference.pm6)|/Type /Pg /Stm /StmOwn /MCID
Table 261 – Entries in a measure dictionary|[Measure](gen/lib/ISO_32000/Measure.pm6)|/Type /Subtype
Table 273 – Entries common to all media clip dictionaries|[Media_clip_common](gen/lib/ISO_32000/Media_clip_common.pm6)|/Type /S /N
Table 274 – Additional entries in a media clip data dictionary|[Media_clip_data](gen/lib/ISO_32000/Media_clip_data.pm6)|/D /CT /P /Alt /PL /MH /BE
Table 276 – Entries in a media clip data MH/BE dictionary|[Media_clip_data_MH-BE](gen/lib/ISO_32000/Media_clip_data_MH-BE.pm6)|/BU
Table 277 – Additional entries in a media clip section dictionary|[Media_clip_section](gen/lib/ISO_32000/Media_clip_section.pm6)|/D /Alt /MH /BE
Table 278 – Entries in a media clip section MH/BE dictionary|[Media_clip_section_MH-BE](gen/lib/ISO_32000/Media_clip_section_MH-BE.pm6)|/B /E
Table 281 – Entries in a media duration dictionary|[Media_duration](gen/lib/ISO_32000/Media_duration.pm6)|/Type /S /T
Table 285 – Entries common to all media offset dictionaries|[Media_offset_common](gen/lib/ISO_32000/Media_offset_common.pm6)|/Type /S
Table 287 – Additional entries in a media offset frame dictionary|[Media_offset_frame](gen/lib/ISO_32000/Media_offset_frame.pm6)|/F
Table 288 – Additional entries in a media offset marker dictionary|[Media_offset_marker](gen/lib/ISO_32000/Media_offset_marker.pm6)|/M
Table 286 – Additional entries in a media offset time dictionary|[Media_offset_time](gen/lib/ISO_32000/Media_offset_time.pm6)|/T
Table 275 – Entries in a media permissions dictionary|[Media_permissions](gen/lib/ISO_32000/Media_permissions.pm6)|/Type /TF
Table 279 – Entries in a media play parameters dictionary|[Media_play_parameters](gen/lib/ISO_32000/Media_play_parameters.pm6)|/Type /PL /MH /BE
Table 291 – Entries in a media player info dictionary|[Media_player_info](gen/lib/ISO_32000/Media_player_info.pm6)|/Type /PID /MH /BE
Table 290 – Entries in a media players dictionary|[Media_players](gen/lib/ISO_32000/Media_players.pm6)|/Type /MU /A /NU
Table 271 – Additional entries in a media rendition dictionary|[Media_rendition](gen/lib/ISO_32000/Media_rendition.pm6)|/C /P /SP
Table 282 – Entries in a media screen parameters dictionary|[Media_screen_parameters](gen/lib/ISO_32000/Media_screen_parameters.pm6)|/Type /MH /BE
Table 283 – Entries in a media screen parameters MH/BE dictionary|[Media_screen_parameters_MH-BE](gen/lib/ISO_32000/Media_screen_parameters_MH-BE.pm6)|/W /B /O /M /F
Table 316 – Additional entry for components having metadata|[Metadata_additional](gen/lib/ISO_32000/Metadata_additional.pm6)|/Metadata
Table 315 – Additional entries in a metadata stream dictionary|[Metadata_stream_additional](gen/lib/ISO_32000/Metadata_stream_additional.pm6)|/Type /Subtype
Table 269 – Entries in a minimum bit depth dictionary|[Minimum_bit_depth](gen/lib/ISO_32000/Minimum_bit_depth.pm6)|/Type /V /M
Table 270 – Entries in a minimum screen size dictionary|[Minimum_screen_size](gen/lib/ISO_32000/Minimum_screen_size.pm6)|/Type /V /M
Table 295 – Entries in a movie dictionary|[Movie](gen/lib/ISO_32000/Movie.pm6)|/F /Aspect /Rotate /Poster
Table 209 – Additional entries specific to a movie action|[Movie_action_additional](gen/lib/ISO_32000/Movie_action_additional.pm6)|/S /Annotation /T /Operation
Table 296 – Entries in a movie activation dictionary|[Movie_activation](gen/lib/ISO_32000/Movie_activation.pm6)|/Start /Duration /Rate /Volume /ShowControls /Mode /Synchronous /FWScale /FWPosition
Table 186 – Additional entries specific to a movie annotation|[Movie_annotation_additional](gen/lib/ISO_32000/Movie_annotation_additional.pm6)|/Subtype /T /Movie /A
Table 36 – Entries in a name tree node dictionary|[Name_tree_node](gen/lib/ISO_32000/Name_tree_node.pm6)|/Kids /Names /Limits
Table 212 – Additional entries specific to named actions|[Named_action_additional](gen/lib/ISO_32000/Named_action_additional.pm6)|/S /N
Table 163 – Entries in a navigation node dictionary|[Navigation_node](gen/lib/ISO_32000/Navigation_node.pm6)|/Type /NA /PA /Next /Prev /Dur
Table 263 – Entries in a number format dictionary|[Number_format](gen/lib/ISO_32000/Number_format.pm6)|/Type /U /C /F /D /FD /RT /RD /PS /SS /O
Table 37 – Entries in a number tree node dictionary|[Number_tree_node](gen/lib/ISO_32000/Number_tree_node.pm6)|/Kids /Nums /Limits
Table 368 – Entry in an OPI version dictionary|[OPI_version](gen/lib/ISO_32000/OPI_version.pm6)|
Table 369 – Entries in a version 1.3 OPI dictionary|[OPI_version_1_3](gen/lib/ISO_32000/OPI_version_1_3.pm6)|/Type /Version /F /ID /Comments /Size /CropRect /CropFixed /Position /Resolution /ColorType /Color /Tint /Overprint /ImageType /GrayMap /Transparency /Tags
Table 370 – Entries in a version 2.0 OPI dictionary|[OPI_version_2_0](gen/lib/ISO_32000/OPI_version_2_0.pm6)|/Type /Version /F /MainImage /Tags /Size /CropRect /Overprint /Inks /IncludedImageDimensions /IncludedImageQuality
Table 325 – Entries in an object reference dictionary|[Object_reference](gen/lib/ISO_32000/Object_reference.pm6)|/Type /Pg /Obj
Table 16 – Additional entries specific to an object stream dictionary|[Object_stream](gen/lib/ISO_32000/Object_stream.pm6)|/Type /N /First /Extends
Table 101 – Entries in an Optional Content Configuration Dictionary|[Optional_Content_Configuration](gen/lib/ISO_32000/Optional_Content_Configuration.pm6)|/Name /Creator /BaseState /ON /OFF /Intent /AS /Order /ListMode /RBGroups /Locked
Table 98 – Entries in an Optional Content Group Dictionary|[Optional_Content_Group](gen/lib/ISO_32000/Optional_Content_Group.pm6)|/Type /Name /Intent /Usage
Table 103 – Entries in a Usage Application Dictionary|[Optional_Content_Group_Application](gen/lib/ISO_32000/Optional_Content_Group_Application.pm6)|/Event /OCGs /Category
Table 99 – Entries in an Optional Content Membership Dictionary|[Optional_Content_Group_Membership](gen/lib/ISO_32000/Optional_Content_Group_Membership.pm6)|/Type /OCGs /P /VE
Table 100 – Entries in the Optional Content Properties Dictionary|[Optional_Content_Group_Properties](gen/lib/ISO_32000/Optional_Content_Group_Properties.pm6)|/OCGs /D /Configs
Table 102 – Entries in an Optional Content Usage Dictionary|[Optional_Content_Group_Usage](gen/lib/ISO_32000/Optional_Content_Group_Usage.pm6)|/CreatorInfo /Language /Export /Zoom /Print /View /User /PageElement
Table 152 – Entries in the outline dictionary|[Outline](gen/lib/ISO_32000/Outline.pm6)|/Type /First /Last /Count
Table 153 – Entries in an outline item dictionary|[Outline_item](gen/lib/ISO_32000/Outline_item.pm6)|/Title /Parent /Prev /Next /First /Last /Count /Dest /A /SE /C /F
Table 365 – Entries in an output intent dictionary|[Output_intent](gen/lib/ISO_32000/Output_intent.pm6)|/Type /S /OutputCondition /OutputConditionIdentifier /RegistryName /Info /DestOutputProfile
Table 318 – Entries in a page-piece dictionary|[Page-piece](gen/lib/ISO_32000/Page-piece.pm6)|
Table 30 – Entries in a page object|[Page](gen/lib/ISO_32000/Page.pm6)|/Type /Parent /LastModified /Resources /MediaBox /CropBox /BleedBox /TrimBox /ArtBox /BoxColorInfo /Contents /Rotate /Group /Thumb /B /Dur /Trans /Annots /AA /Metadata /PieceInfo /StructParents /ID /PZ /SeparationInfo /Tabs /TemplateInstantiated /PresSteps /UserUnit /VP
Table 195 – Entries in a page object’s additional-actions dictionary|[Page_additional_actions](gen/lib/ISO_32000/Page_additional_actions.pm6)|/O /C
Table 159 – Entries in a page label dictionary|[Page_label](gen/lib/ISO_32000/Page_label.pm6)|/Type /S /P /St
Table 29 – Required entries in a page tree node|[Pages](gen/lib/ISO_32000/Pages.pm6)|/Type /Parent /Kids /Count
Table 258 – Entries in a permissions dictionary|[Permissions](gen/lib/ISO_32000/Permissions.pm6)|/DocMDP /UR3
Table 178 – Additional entries specific to a polygon or polyline annotation|[Polygon_or_polyline_annotation_additional](gen/lib/ISO_32000/Polygon_or_polyline_annotation_additional.pm6)|/Subtype /Vertices /LE /BS /IC /BE /IT /Measure
Table 183 – Additional entries specific to a pop-up annotation|[Popup_annotation_additional](gen/lib/ISO_32000/Popup_annotation_additional.pm6)|/Subtype /Parent /Open
Table 88 – Additional Entries Specific to a PostScript XObject Dictionary|[Postscript_XObject](gen/lib/ISO_32000/Postscript_XObject.pm6)|/Type /Subtype /Level1
Table 348 – PrintField attributes|[PrintField](gen/lib/ISO_32000/PrintField.pm6)|/Role /checked /Desc
Table 362 – Additional entries specific to a printer’s mark annotation|[Printers_mark_annotation](gen/lib/ISO_32000/Printers_mark_annotation.pm6)|/Subtype /MN
Table 363 – Additional entries specific to a printer’s mark form dictionary|[Printers_mark_form](gen/lib/ISO_32000/Printers_mark_form.pm6)|/MarkStyle /Colorants
Table 305 – Entries in a projection dictionary|[Projection](gen/lib/ISO_32000/Projection.pm6)|/Subtype /CS /F /N /FOV /PS /OS /OB
Table 23 – Additional encryption dictionary entries for public-key security handlers|[Public_key_security_handler_additional](gen/lib/ISO_32000/Public_key_security_handler_additional.pm6)|/Recipients /P
Table 262 – Additional entries in a rectilinear measure dictionary|[Rectilinear_measure_additional](gen/lib/ISO_32000/Rectilinear_measure_additional.pm6)|/R /X /Y /D /A /T /S /O /CYX
Table 192 – Additional entries specific to a redaction annotation|[Redaction_annotation_additional](gen/lib/ISO_32000/Redaction_annotation_additional.pm6)|/Subtype /QuadPoints /IC /RO /OverlayText /Repeat /DA /Q
Table 97 – Entries in a Reference Dictionary|[Reference](gen/lib/ISO_32000/Reference.pm6)|/F /Page /ID
Table 200 – Additional entries specific to a remote go-to action|[Remote_goto_action_additional](gen/lib/ISO_32000/Remote_goto_action_additional.pm6)|/S /F /D /NewWindow
Table 307 – Entries in a render mode dictionary|[Render_mode](gen/lib/ISO_32000/Render_mode.pm6)|/Type /Subtype /AC /FC /O /CV
Table 267 – Entries in a rendition MH/BE dictionary|[Rendition_MH-BE](gen/lib/ISO_32000/Rendition_MH-BE.pm6)|/C
Table 214 – Additional entries specific to a rendition action|[Rendition_action_additional](gen/lib/ISO_32000/Rendition_action_additional.pm6)|/S /R /AN /OP /JS
Table 266 – Entries common to all rendition dictionaries|[Rendition_common](gen/lib/ISO_32000/Rendition_common.pm6)|/Type /S /N /MH /BE
Table 268 – Entries in a media criteria dictionary|[Rendition_criteria](gen/lib/ISO_32000/Rendition_criteria.pm6)|/Type /A /C /O /S /R /D /Z /V /P /L
Table 264 – Entries common to all requirement dictionaries|[Requirement_common](gen/lib/ISO_32000/Requirement_common.pm6)|/Type /S /RH
Table 265 – Entries in a requirement handler dictionary|[Requirement_handler](gen/lib/ISO_32000/Requirement_handler.pm6)|/Type /S /Script
Table 238 – Additional entries specific to a reset-form action|[Reset_form_action](gen/lib/ISO_32000/Reset_form_action.pm6)|/S /Fields /Flags
Table 33 – Entries in a resource dictionary|[Resource](gen/lib/ISO_32000/Resource.pm6)|/ExtGState /ColorSpace /Pattern /Shading /XObject /Font /ProcSet /Properties
Table 181 – Additional entries specific to a rubber stamp annotation|[Rubber_stamp_annotation_additional](gen/lib/ISO_32000/Rubber_stamp_annotation_additional.pm6)|/Subtype /Name
Table 187 – Additional entries specific to a screen annotation|[Screen_annotation_additional](gen/lib/ISO_32000/Screen_annotation_additional.pm6)|/Subtype /T /MK /A /AA
Table 272 – Additional entries specific to a selector rendition dictionary|[Selector_rendition](gen/lib/ISO_32000/Selector_rendition.pm6)|/R
Table 364 – Entries in a separation dictionary|[Separation](gen/lib/ISO_32000/Separation.pm6)|/Pages /DeviceColorant /ColorSpace
Table 213 – Additional entries specific to a set-OCG-state action|[Set-OCG-state_action_additional](gen/lib/ISO_32000/Set-OCG-state_action_additional.pm6)|/S /State /PreserveRB
Table 78 – Entries Common to All Shading Dictionaries|[Shading_common](gen/lib/ISO_32000/Shading_common.pm6)|/ShadingType /ColorSpace /Background /BBox /AntiAlias
Table 252 – Entries in a signature dictionary|[Signature](gen/lib/ISO_32000/Signature.pm6)|/Type /Filter /SubFilter /Contents /Cert /ByteRange /Reference /Changes /Name /M /Location /Reason /ContactInfo /R /V /Prop_Build /Prop_AuthTime /Prop_AuthType
Table 232 – Additional entries specific to a signature field|[Signature_field](gen/lib/ISO_32000/Signature_field.pm6)|/Lock /SV
Table 233 – Entries in a signature field lock dictionary|[Signature_field_lock](gen/lib/ISO_32000/Signature_field_lock.pm6)|/Type /Action /Fields
Table 234 – Entries in a signature field seed value dictionary|[Signature_field_seed_value](gen/lib/ISO_32000/Signature_field_seed_value.pm6)|/Type /Ff /Filter /SubFilter /DigestMethod /V /Cert /Reasons /MDP /TimeStamp /LegalAttestation /AddRevInfo
Table 253 – Entries in a signature reference dictionary|[Signature_reference](gen/lib/ISO_32000/Signature_reference.pm6)|/Type /TransformMethod /TransformParams /Data /DigestMethod
Table 297 – Entries in a slideshow dictionary|[Slideshow](gen/lib/ISO_32000/Slideshow.pm6)|/Type /Subtype /Resources /StartResource
Table 144 – Entries in a soft-mask dictionary|[Soft-mask](gen/lib/ISO_32000/Soft-mask.pm6)|/Type /S /G /BC /TR
Table 146 – Additional entry in a soft-mask image dictionary|[Soft-mask_image_additional](gen/lib/ISO_32000/Soft-mask_image_additional.pm6)|/Matte
Table 292 – Entries in a software identifier dictionary|[Software_identifier](gen/lib/ISO_32000/Software_identifier.pm6)|/Type /U /L /LI /H /HI /OS
Table 208 – Additional entries specific to a sound action|[Sound_action_additional](gen/lib/ISO_32000/Sound_action_additional.pm6)|/S /Sound /Volume /Synchronous /Repeat /Mix
Table 185 – Additional entries specific to a sound annotation|[Sound_annotation_additional](gen/lib/ISO_32000/Sound_annotation_additional.pm6)|/Subtype /Sound /Name
Table 294 – Additional entries specific to a sound object|[Sound_object](gen/lib/ISO_32000/Sound_object.pm6)|/Type /R /C /B /E /CO /CP
Table 355 – Entries in a source information dictionary|[Source_information](gen/lib/ISO_32000/Source_information.pm6)|/AU /TS /E /S /C
Table 177 – Additional entries specific to a square or circle annotation|[Square_or_circle_annotation_additional](gen/lib/ISO_32000/Square_or_circle_annotation_additional.pm6)|/Subtype /BS /IC /BE /RD
Table 346 – Standard column attributes|[Standard_column](gen/lib/ISO_32000/Standard_column.pm6)|/ColumnCount /ColumnGap /ColumnWidths
Table 345 – Standard layout attributes specific to inline-level structure elements|[Standard_inline-level_structure_element](gen/lib/ISO_32000/Standard_inline-level_structure_element.pm6)|/BaselineShift /LineHeight /TextDecorationColor /TextDecorationThickness /TextDecorationType /RubyAlign /RubyPosition /GlyphOrientationVertical
Table 344 – Additional standard layout attributes specific to block-level structure elements|[Standard_layout_block-level_structure_element](gen/lib/ISO_32000/Standard_layout_block-level_structure_element.pm6)|/SpaceBefore /SpaceAfter /StartIndent /EndIndent /TextIndent /TextAlign /BBox /Width /Height /BlockAlign /InlineAlign /TBorderStyle /TPadding
Table 343 – Standard layout attributes common to all standard structure types|[Standard_layout_structure_type](gen/lib/ISO_32000/Standard_layout_structure_type.pm6)|/Placement /WritingMode /BackgroundColor /BorderColor /BorderStyle /BorderThickness /Padding /Color
Table 347 – Standard list attribute|[Standard_list](gen/lib/ISO_32000/Standard_list.pm6)|/ListNumbering
Table 349 – Standard table attributes|[Standard_table](gen/lib/ISO_32000/Standard_table.pm6)|/RowSpan /ColSpan /Headers /Scope /Summary
Table 5 – Entries common to all stream dictionaries|[Stream_common](gen/lib/ISO_32000/Stream_common.pm6)|/Length /Filter /DecodeParms /F /FFilter /FDecodeParms /DL
Table 326 – Additional dictionary entries for structure element access|[Structure_element_access_additional](gen/lib/ISO_32000/Structure_element_access_additional.pm6)|/StructParent /StructParents
Table 323 – Entries in a structure element dictionary|[Structure_tree_element](gen/lib/ISO_32000/Structure_tree_element.pm6)|/Type /S /P /ID /Pg /K /A /C /R /T /Lang /Alt /E /ActualText
Table 322 – Entries in the structure tree root|[Structure_tree_root](gen/lib/ISO_32000/Structure_tree_root.pm6)|/Type /K /IDTree /ParentTree /ParentTreeNextKey /RoleMap /ClassMap
Table 236 – Additional entries specific to a submit-form action|[Submit_form_action](gen/lib/ISO_32000/Submit_form_action.pm6)|/S /F /Fields /Flags
Table 202 – Entries specific to a target dictionary|[Target](gen/lib/ISO_32000/Target.pm6)|/R /N /P /A /T
Table 172 – Additional entries specific to a text annotation|[Text_annotation_additional](gen/lib/ISO_32000/Text_annotation_additional.pm6)|/Subtype /Open /Name /State /StateModel
Table 229 – Additional entry specific to a text field|[Text_field_additional](gen/lib/ISO_32000/Text_field_additional.pm6)|/MaxLen
Table 179 – Additional entries specific to text markup annotations|[Text_markup_annotation_additional](gen/lib/ISO_32000/Text_markup_annotation_additional.pm6)|/Subtype /QuadPoints
Table 160 – Entries in a thread dictionary|[Thread](gen/lib/ISO_32000/Thread.pm6)|/Type /F /I
Table 205 – Additional entries specific to a thread action|[Thread_action_additional](gen/lib/ISO_32000/Thread_action_additional.pm6)|/S /F /D /B
Table 299 – Entries in a 3D activation dictionary|[Three-D_activation](gen/lib/ISO_32000/Three-D_activation.pm6)|/A /AIS /D /DIS /TB /NP
Table 301 – Entries in an 3D animation style dictionary|[Three-D_animation_style](gen/lib/ISO_32000/Three-D_animation_style.pm6)|/Type /Subtype /PC /TM
Table 298 – Additional entries specific to a 3D annotation|[Three-D_annotation](gen/lib/ISO_32000/Three-D_annotation.pm6)|/Subtype /3DD /3DV /3DA /3DI /3DB
Table 306 – Entries in a 3D background dictionary|[Three-D_background](gen/lib/ISO_32000/Three-D_background.pm6)|/Type /Subtype /CS /C /EA
Table 311 – Entries in a 3D cross section dictionary|[Three-D_cross_section](gen/lib/ISO_32000/Three-D_cross_section.pm6)|/Type /C /O /PO /PC /IV /IC
Table 313 – Entries in an external data dictionary used to markup 3D annotations|[Three-D_external_data](gen/lib/ISO_32000/Three-D_external_data.pm6)|/Type /Subtype /MD5 /3DA /3DV
Table 309 – Entries in a 3D lighting scheme dictionary|[Three-D_lighting](gen/lib/ISO_32000/Three-D_lighting.pm6)|/Type /Subtype
Table 312 – Entries in a 3D node dictionary|[Three-D_node](gen/lib/ISO_32000/Three-D_node.pm6)|/Type /N /O /V /M
Table 303 – Entries in a 3D reference dictionary|[Three-D_reference](gen/lib/ISO_32000/Three-D_reference.pm6)|/Type /3DD
Table 300 – Entries in a 3D stream dictionary|[Three-D_stream](gen/lib/ISO_32000/Three-D_stream.pm6)|/Type /Subtype /VA /DV /Resources /OnInstantiate /AN
Table 304 – Entries in a 3D view dictionary|[Three-D_view](gen/lib/ISO_32000/Three-D_view.pm6)|/Type /XN /IN /MS /C2W /U3DPath /CO /P /O /BG /RM /LS /SA /NA /NR
Table 289 – Entries in a timespan dictionary|[Timespan](gen/lib/ISO_32000/Timespan.pm6)|/Type /S /V
Table 162 – Entries in a transition dictionary|[Transition](gen/lib/ISO_32000/Transition.pm6)|/Type /S /D /Dm /M /Di /SS /B
Table 215 – Additional entries specific to a transition action|[Transition_action_additional](gen/lib/ISO_32000/Transition_action_additional.pm6)|/S /Trans
Table 147 – Additional entries specific to a transparency group attributes dictionary|[Transparency_group_additional](gen/lib/ISO_32000/Transparency_group_additional.pm6)|/S /CS /I /K
Table 366 – Additional entries specific to a trap network annotation|[Trap_network_annotation](gen/lib/ISO_32000/Trap_network_annotation.pm6)|/Subtype /LastModified /Version /AnnotStates /FontFauxing
Table 367 – Additional entries specific to a trap network appearance stream|[Trap_network_appearance_stream](gen/lib/ISO_32000/Trap_network_appearance_stream.pm6)|/PCM /SeparationColorNames /TrapRegions /TrapStyles
Table 121 – Entries in a Type 0 font dictionary|[Type_0_Font](gen/lib/ISO_32000/Type_0_Font.pm6)|/Type /Subtype /BaseFont /Encoding /DescendantFonts /ToUnicode
Table 39 – Additional entries specific to a type 0 function dictionary|[Type_0_Function](gen/lib/ISO_32000/Type_0_Function.pm6)|/Size /BitsPerSample /Order /Encode /Decode
Table 132 – Additional entries specific to a type 10 halftone dictionary|[Type_10_halftone](gen/lib/ISO_32000/Type_10_halftone.pm6)|/Type /HalftoneType /HalftoneName /Xsquare /Ysquare /TransferFunction
Table 133 – Additional entries specific to a type 16 halftone dictionary|[Type_16_halftone](gen/lib/ISO_32000/Type_16_halftone.pm6)|/Type /HalftoneType /HalftoneName /Width /Height /Width2 /Height2 /TransferFunction
Table 111 – Entries in a Type 1 font dictionary|[Type_1_Font](gen/lib/ISO_32000/Type_1_Font.pm6)|/Type /Subtype /Name /BaseFont /FirstChar /LastChar /Widths /FontDescriptor /Encoding /ToUnicode
Table 95 – Additional Entries Specific to a Type 1 Form Dictionary|[Type_1_Form](gen/lib/ISO_32000/Type_1_Form.pm6)|/Type /Subtype /FormType /BBox /Matrix /Resources /Group /Ref /Metadata /PieceInfo /LastModified /StructParent /StructParents /OPI /OC /Name
Table 75 – Additional Entries Specific to a Type 1 Pattern Dictionary|[Type_1_Pattern](gen/lib/ISO_32000/Type_1_Pattern.pm6)|/Type /PatternType /PaintType /TilingType /BBox /XStep /YStep /Resources /Matrix
Table 79 – Additional Entries Specific to a Type 1 Shading Dictionary|[Type_1_Shading](gen/lib/ISO_32000/Type_1_Shading.pm6)|/Domain /Matrix /Function
Table 130 – Entries in a type 1 halftone dictionary|[Type_1_halftone](gen/lib/ISO_32000/Type_1_halftone.pm6)|/Type /HalftoneType /HalftoneName /Frequency /Angle /SpotFunction /AccurateScreens /TransferFunction
Table 40 – Additional entries specific to a type 2 function dictionary|[Type_2_Function](gen/lib/ISO_32000/Type_2_Function.pm6)|/C0 /C1 /N
Table 76 – Entries in a Type 2 Pattern Dictionary|[Type_2_Pattern](gen/lib/ISO_32000/Type_2_Pattern.pm6)|/Type /PatternType /Shading /Matrix /ExtGState
Table 80 – Additional Entries Specific to a Type 2 Shading Dictionary|[Type_2_Shading](gen/lib/ISO_32000/Type_2_Shading.pm6)|/Coords /Domain /Function /Extend
Table 112 – Entries in a Type 3 font dictionary|[Type_3_Font](gen/lib/ISO_32000/Type_3_Font.pm6)|/Type /Subtype /Name /FontBBox /FontMatrix /CharProcs /Encoding /FirstChar /LastChar /Widths /FontDescriptor /Resources /ToUnicode
Table 41 – Additional entries specific to a type 3 function dictionary|[Type_3_Function](gen/lib/ISO_32000/Type_3_Function.pm6)|/Functions /Bounds /Encode
Table 81 – Additional Entries Specific to a Type 3 Shading Dictionary|[Type_3_Shading](gen/lib/ISO_32000/Type_3_Shading.pm6)|/Coords /Domain /Function /Extend
Table 82 – Additional Entries Specific to a Type 4 Shading Dictionary|[Type_4_Shading](gen/lib/ISO_32000/Type_4_Shading.pm6)|/BitsPerCoordinate /BitsPerComponent /BitsPerFlag /Decode /Function
Table 83 – Additional Entries Specific to a Type 5 Shading Dictionary|[Type_5_Shading](gen/lib/ISO_32000/Type_5_Shading.pm6)|/BitsPerCoordinate /BitsPerComponent /VerticesPerRow /Decode /Function
Table 134 – Entries in a type 5 halftone dictionary|[Type_5_halftone](gen/lib/ISO_32000/Type_5_halftone.pm6)|/Type /HalftoneType /HalftoneName /Default
Table 84 – Additional Entries Specific to a Type 6 Shading Dictionary|[Type_6_Shading](gen/lib/ISO_32000/Type_6_Shading.pm6)|/BitsPerCoordinate /BitsPerComponent /BitsPerFlag /Decode /Function
Table 131 – Additional entries specific to a type 6 halftone dictionary|[Type_6_halftone](gen/lib/ISO_32000/Type_6_halftone.pm6)|/Type /HalftoneType /HalftoneName /Width /Height /TransferFunction
Table 207 – Entry in a URI dictionary|[URI](gen/lib/ISO_32000/URI.pm6)|/Base
Table 206 – Additional entries specific to a URI action|[URI_action_additional](gen/lib/ISO_32000/URI_action_additional.pm6)|/S /URI /IsMap
Table 356 – Entries in a URL alias dictionary|[URL_alias](gen/lib/ISO_32000/URL_alias.pm6)|/U /C
Table 255 – Entries in the UR transform parameters dictionary|[UR_transform](gen/lib/ISO_32000/UR_transform.pm6)|/Type /Document /Msg /V /Annots /Form /Signature /EF /P
Table 329 – Entries in a user property dictionary|[User_property](gen/lib/ISO_32000/User_property.pm6)|/N /V /F /H
Table 222 – Additional entries common to all fields containing variable text|[Variable_text_field](gen/lib/ISO_32000/Variable_text_field.pm6)|/DA /Q /DS /RV
Table 150 – Entries in a viewer preferences dictionary|[Viewer_preferences](gen/lib/ISO_32000/Viewer_preferences.pm6)|/HideToolbar /HideMenubar /HideWindowUI /FitWindow /CenterWindow /DisplayDocTitle /NonFullScreenPageMode /Direction /ViewArea /ViewClip /PrintArea /PrintClip /PrintScaling /Duplex /PickTrayByPDFSize /PrintPageRange /NumCopies
Table 260 – Entries in a viewport dictionary|[Viewport](gen/lib/ISO_32000/Viewport.pm6)|/Type /BBox /Name /Measure
Table 190 – Additional entries specific to a watermark annotation|[Watermark_annotation_additional](gen/lib/ISO_32000/Watermark_annotation_additional.pm6)|/Subtype /FixedPrint
Table 352 – Entries common to all Web Capture content sets|[Web_Capture_content_sets](gen/lib/ISO_32000/Web_Capture_content_sets.pm6)|/Type /S /ID /O /SI /CT /TS
Table 354 – Additional entries specific to a Web Capture image set|[Web_Capture_image_set](gen/lib/ISO_32000/Web_Capture_image_set.pm6)|/S /R
Table 350 – Entries in the Web Capture information dictionary|[Web_Capture_information](gen/lib/ISO_32000/Web_Capture_information.pm6)|/V /C
Table 353 – Additional entries specific to a Web Capture page set|[Web_Capture_page_set_additional](gen/lib/ISO_32000/Web_Capture_page_set_additional.pm6)|/S /T /TID
Table 357 – Entries in a Web Capture command dictionary|[Web_capture_command](gen/lib/ISO_32000/Web_capture_command.pm6)|/URL /L /F /P /CT /H /S
Table 359 – Entries in a Web Capture command settings dictionary|[Web_capture_command_settings](gen/lib/ISO_32000/Web_capture_command_settings.pm6)|/G /C
Table 188 – Additional entries specific to a widget annotation|[Widget_annotation_additional](gen/lib/ISO_32000/Widget_annotation_additional.pm6)|/Subtype /H /MK /A /AA /BS /Parent
Table 204 – Entries in a Windows launch parameter dictionary|[Windows_launch_parameters](gen/lib/ISO_32000/Windows_launch_parameters.pm6)|/F /D /O /P

## Entry to table mappings

Entry|ISO_32000 Roles
----|-----
/3DA|[Three-D_annotation](gen/lib/ISO_32000/Three-D_annotation.pm6) [Three-D_external_data](gen/lib/ISO_32000/Three-D_external_data.pm6)
/3DB|[Three-D_annotation](gen/lib/ISO_32000/Three-D_annotation.pm6)
/3DD|[Three-D_annotation](gen/lib/ISO_32000/Three-D_annotation.pm6) [Three-D_reference](gen/lib/ISO_32000/Three-D_reference.pm6)
/3DI|[Three-D_annotation](gen/lib/ISO_32000/Three-D_annotation.pm6)
/3DV|[Three-D_annotation](gen/lib/ISO_32000/Three-D_annotation.pm6) [Three-D_external_data](gen/lib/ISO_32000/Three-D_external_data.pm6)
/A|[Collection_sort](gen/lib/ISO_32000/Collection_sort.pm6) [FDF_field](gen/lib/ISO_32000/FDF_field.pm6) [Icon_fit](gen/lib/ISO_32000/Icon_fit.pm6) [Link_annotation_additional](gen/lib/ISO_32000/Link_annotation_additional.pm6) [Media_players](gen/lib/ISO_32000/Media_players.pm6) [Movie_annotation_additional](gen/lib/ISO_32000/Movie_annotation_additional.pm6) [Outline_item](gen/lib/ISO_32000/Outline_item.pm6) [Rectilinear_measure_additional](gen/lib/ISO_32000/Rectilinear_measure_additional.pm6) [Rendition_criteria](gen/lib/ISO_32000/Rendition_criteria.pm6) [Screen_annotation_additional](gen/lib/ISO_32000/Screen_annotation_additional.pm6) [Structure_tree_element](gen/lib/ISO_32000/Structure_tree_element.pm6) [Target](gen/lib/ISO_32000/Target.pm6) [Three-D_activation](gen/lib/ISO_32000/Three-D_activation.pm6) [Widget_annotation_additional](gen/lib/ISO_32000/Widget_annotation_additional.pm6)
/AA|[Catalog](gen/lib/ISO_32000/Catalog.pm6) [FDF_field](gen/lib/ISO_32000/FDF_field.pm6) [Field_common](gen/lib/ISO_32000/Field_common.pm6) [Page](gen/lib/ISO_32000/Page.pm6) [Screen_annotation_additional](gen/lib/ISO_32000/Screen_annotation_additional.pm6) [Widget_annotation_additional](gen/lib/ISO_32000/Widget_annotation_additional.pm6)
/AC|[Appearance_characteristics](gen/lib/ISO_32000/Appearance_characteristics.pm6) [Render_mode](gen/lib/ISO_32000/Render_mode.pm6)
/AIS|[Graphics_state](gen/lib/ISO_32000/Graphics_state.pm6) [Three-D_activation](gen/lib/ISO_32000/Three-D_activation.pm6)
/AN|[Rendition_action_additional](gen/lib/ISO_32000/Rendition_action_additional.pm6) [Three-D_stream](gen/lib/ISO_32000/Three-D_stream.pm6)
/AP|[Annotation_common](gen/lib/ISO_32000/Annotation_common.pm6) [Catalog_Name_tree](gen/lib/ISO_32000/Catalog_Name_tree.pm6) [FDF_field](gen/lib/ISO_32000/FDF_field.pm6)
/APRef|[FDF_field](gen/lib/ISO_32000/FDF_field.pm6)
/AS|[Annotation_common](gen/lib/ISO_32000/Annotation_common.pm6) [Optional_Content_Configuration](gen/lib/ISO_32000/Optional_Content_Configuration.pm6)
/AU|[Source_information](gen/lib/ISO_32000/Source_information.pm6)
/AccurateScreens|[Type_1_halftone](gen/lib/ISO_32000/Type_1_halftone.pm6)
/AcroForm|[Catalog](gen/lib/ISO_32000/Catalog.pm6)
/Action|[FieldMDP_transform](gen/lib/ISO_32000/FieldMDP_transform.pm6) [Signature_field_lock](gen/lib/ISO_32000/Signature_field_lock.pm6)
/ActualText|[Structure_tree_element](gen/lib/ISO_32000/Structure_tree_element.pm6)
/AddRevInfo|[Signature_field_seed_value](gen/lib/ISO_32000/Signature_field_seed_value.pm6)
/After|[JavaScript](gen/lib/ISO_32000/JavaScript.pm6)
/AfterPermsReady|[JavaScript](gen/lib/ISO_32000/JavaScript.pm6)
/Alt|[Media_clip_data](gen/lib/ISO_32000/Media_clip_data.pm6) [Media_clip_section](gen/lib/ISO_32000/Media_clip_section.pm6) [Structure_tree_element](gen/lib/ISO_32000/Structure_tree_element.pm6)
/Alternate|[ICC_profile](gen/lib/ISO_32000/ICC_profile.pm6)
/AlternateImages|[Legal_attestation](gen/lib/ISO_32000/Legal_attestation.pm6)
/AlternatePresentations|[Catalog_Name_tree](gen/lib/ISO_32000/Catalog_Name_tree.pm6)
/Alternates|[Image](gen/lib/ISO_32000/Image.pm6)
/Angle|[Type_1_halftone](gen/lib/ISO_32000/Type_1_halftone.pm6)
/AnnotStates|[Trap_network_annotation](gen/lib/ISO_32000/Trap_network_annotation.pm6)
/Annotation|[Movie_action_additional](gen/lib/ISO_32000/Movie_action_additional.pm6)
/Annotations|[Legal_attestation](gen/lib/ISO_32000/Legal_attestation.pm6)
/Annots|[FDF_dictionary](gen/lib/ISO_32000/FDF_dictionary.pm6) [Page](gen/lib/ISO_32000/Page.pm6) [UR_transform](gen/lib/ISO_32000/UR_transform.pm6)
/AntiAlias|[Shading_common](gen/lib/ISO_32000/Shading_common.pm6)
/ArtBox|[Box_colour_information](gen/lib/ISO_32000/Box_colour_information.pm6) [Page](gen/lib/ISO_32000/Page.pm6)
/Ascent|[Font_descriptor_common](gen/lib/ISO_32000/Font_descriptor_common.pm6)
/Aspect|[Movie](gen/lib/ISO_32000/Movie.pm6)
/Attached|[Artifact](gen/lib/ISO_32000/Artifact.pm6)
/Attestation|[Legal_attestation](gen/lib/ISO_32000/Legal_attestation.pm6)
/AuthEvent|[Crypt_filter_common](gen/lib/ISO_32000/Crypt_filter_common.pm6)
/Author|[Info](gen/lib/ISO_32000/Info.pm6)
/AvgWidth|[Font_descriptor_common](gen/lib/ISO_32000/Font_descriptor_common.pm6)
/B|[Media_clip_section_MH-BE](gen/lib/ISO_32000/Media_clip_section_MH-BE.pm6) [Media_screen_parameters_MH-BE](gen/lib/ISO_32000/Media_screen_parameters_MH-BE.pm6) [Page](gen/lib/ISO_32000/Page.pm6) [Sound_object](gen/lib/ISO_32000/Sound_object.pm6) [Thread_action_additional](gen/lib/ISO_32000/Thread_action_additional.pm6) [Transition](gen/lib/ISO_32000/Transition.pm6)
/BBox|[Artifact](gen/lib/ISO_32000/Artifact.pm6) [Shading_common](gen/lib/ISO_32000/Shading_common.pm6) [Standard_layout_block-level_structure_element](gen/lib/ISO_32000/Standard_layout_block-level_structure_element.pm6) [Type_1_Form](gen/lib/ISO_32000/Type_1_Form.pm6) [Type_1_Pattern](gen/lib/ISO_32000/Type_1_Pattern.pm6) [Viewport](gen/lib/ISO_32000/Viewport.pm6)
/BC|[Appearance_characteristics](gen/lib/ISO_32000/Appearance_characteristics.pm6) [Soft-mask](gen/lib/ISO_32000/Soft-mask.pm6)
/BE|[Free_text_annotation_additional](gen/lib/ISO_32000/Free_text_annotation_additional.pm6) [Media_clip_data](gen/lib/ISO_32000/Media_clip_data.pm6) [Media_clip_section](gen/lib/ISO_32000/Media_clip_section.pm6) [Media_play_parameters](gen/lib/ISO_32000/Media_play_parameters.pm6) [Media_player_info](gen/lib/ISO_32000/Media_player_info.pm6) [Media_screen_parameters](gen/lib/ISO_32000/Media_screen_parameters.pm6) [Polygon_or_polyline_annotation_additional](gen/lib/ISO_32000/Polygon_or_polyline_annotation_additional.pm6) [Rendition_common](gen/lib/ISO_32000/Rendition_common.pm6) [Square_or_circle_annotation_additional](gen/lib/ISO_32000/Square_or_circle_annotation_additional.pm6)
/BG|[Appearance_characteristics](gen/lib/ISO_32000/Appearance_characteristics.pm6) [Graphics_state](gen/lib/ISO_32000/Graphics_state.pm6) [Three-D_view](gen/lib/ISO_32000/Three-D_view.pm6)
/BG2|[Graphics_state](gen/lib/ISO_32000/Graphics_state.pm6)
/BM|[Graphics_state](gen/lib/ISO_32000/Graphics_state.pm6)
/BS|[Free_text_annotation_additional](gen/lib/ISO_32000/Free_text_annotation_additional.pm6) [Ink_annotation_additional](gen/lib/ISO_32000/Ink_annotation_additional.pm6) [Line_annotation_additional](gen/lib/ISO_32000/Line_annotation_additional.pm6) [Link_annotation_additional](gen/lib/ISO_32000/Link_annotation_additional.pm6) [Polygon_or_polyline_annotation_additional](gen/lib/ISO_32000/Polygon_or_polyline_annotation_additional.pm6) [Square_or_circle_annotation_additional](gen/lib/ISO_32000/Square_or_circle_annotation_additional.pm6) [Widget_annotation_additional](gen/lib/ISO_32000/Widget_annotation_additional.pm6)
/BU|[Media_clip_data_MH-BE](gen/lib/ISO_32000/Media_clip_data_MH-BE.pm6)
/Background|[Shading_common](gen/lib/ISO_32000/Shading_common.pm6)
/BackgroundColor|[Standard_layout_structure_type](gen/lib/ISO_32000/Standard_layout_structure_type.pm6)
/Base|[URI](gen/lib/ISO_32000/URI.pm6)
/BaseEncoding|[Encoding](gen/lib/ISO_32000/Encoding.pm6)
/BaseFont|[CIDFont](gen/lib/ISO_32000/CIDFont.pm6) [Type_0_Font](gen/lib/ISO_32000/Type_0_Font.pm6) [Type_1_Font](gen/lib/ISO_32000/Type_1_Font.pm6)
/BaseState|[Optional_Content_Configuration](gen/lib/ISO_32000/Optional_Content_Configuration.pm6)
/BaseVersion|[Developer_extensions](gen/lib/ISO_32000/Developer_extensions.pm6)
/BaselineShift|[Standard_inline-level_structure_element](gen/lib/ISO_32000/Standard_inline-level_structure_element.pm6)
/Before|[JavaScript](gen/lib/ISO_32000/JavaScript.pm6)
/BitsPerComponent|[Image](gen/lib/ISO_32000/Image.pm6) [Inline_Image](gen/lib/ISO_32000/Inline_Image.pm6) [LZW_and_Flate_filter](gen/lib/ISO_32000/LZW_and_Flate_filter.pm6) [Type_4_Shading](gen/lib/ISO_32000/Type_4_Shading.pm6) [Type_5_Shading](gen/lib/ISO_32000/Type_5_Shading.pm6) [Type_6_Shading](gen/lib/ISO_32000/Type_6_Shading.pm6)
/BitsPerCoordinate|[Type_4_Shading](gen/lib/ISO_32000/Type_4_Shading.pm6) [Type_5_Shading](gen/lib/ISO_32000/Type_5_Shading.pm6) [Type_6_Shading](gen/lib/ISO_32000/Type_6_Shading.pm6)
/BitsPerFlag|[Type_4_Shading](gen/lib/ISO_32000/Type_4_Shading.pm6) [Type_6_Shading](gen/lib/ISO_32000/Type_6_Shading.pm6)
/BitsPerSample|[Type_0_Function](gen/lib/ISO_32000/Type_0_Function.pm6)
/Bl|[Annotation_additional_actions](gen/lib/ISO_32000/Annotation_additional_actions.pm6)
/BlackIs1|[CCITTFax_filter](gen/lib/ISO_32000/CCITTFax_filter.pm6)
/BlackPoint|[CalGray_colour_space](gen/lib/ISO_32000/CalGray_colour_space.pm6) [CalRGB_colour_space](gen/lib/ISO_32000/CalRGB_colour_space.pm6) [Lab_colour_space](gen/lib/ISO_32000/Lab_colour_space.pm6)
/BleedBox|[Box_colour_information](gen/lib/ISO_32000/Box_colour_information.pm6) [Page](gen/lib/ISO_32000/Page.pm6)
/BlockAlign|[Standard_layout_block-level_structure_element](gen/lib/ISO_32000/Standard_layout_block-level_structure_element.pm6)
/Border|[Annotation_common](gen/lib/ISO_32000/Annotation_common.pm6)
/BorderColor|[Standard_layout_structure_type](gen/lib/ISO_32000/Standard_layout_structure_type.pm6)
/BorderStyle|[Standard_layout_structure_type](gen/lib/ISO_32000/Standard_layout_structure_type.pm6)
/BorderThickness|[Standard_layout_structure_type](gen/lib/ISO_32000/Standard_layout_structure_type.pm6)
/Bounds|[Type_3_Function](gen/lib/ISO_32000/Type_3_Function.pm6)
/BoxColorInfo|[Page](gen/lib/ISO_32000/Page.pm6)
/ByteRange|[Signature](gen/lib/ISO_32000/Signature.pm6)
/C|[Annotation_common](gen/lib/ISO_32000/Annotation_common.pm6) [Box_style](gen/lib/ISO_32000/Box_style.pm6) [Form_additional_actions](gen/lib/ISO_32000/Form_additional_actions.pm6) [Media_rendition](gen/lib/ISO_32000/Media_rendition.pm6) [Number_format](gen/lib/ISO_32000/Number_format.pm6) [Outline_item](gen/lib/ISO_32000/Outline_item.pm6) [Page_additional_actions](gen/lib/ISO_32000/Page_additional_actions.pm6) [Rendition_MH-BE](gen/lib/ISO_32000/Rendition_MH-BE.pm6) [Rendition_criteria](gen/lib/ISO_32000/Rendition_criteria.pm6) [Sound_object](gen/lib/ISO_32000/Sound_object.pm6) [Source_information](gen/lib/ISO_32000/Source_information.pm6) [Structure_tree_element](gen/lib/ISO_32000/Structure_tree_element.pm6) [Three-D_background](gen/lib/ISO_32000/Three-D_background.pm6) [Three-D_cross_section](gen/lib/ISO_32000/Three-D_cross_section.pm6) [URL_alias](gen/lib/ISO_32000/URL_alias.pm6) [Web_Capture_information](gen/lib/ISO_32000/Web_Capture_information.pm6) [Web_capture_command_settings](gen/lib/ISO_32000/Web_capture_command_settings.pm6)
/C0|[Type_2_Function](gen/lib/ISO_32000/Type_2_Function.pm6)
/C1|[Type_2_Function](gen/lib/ISO_32000/Type_2_Function.pm6)
/C2W|[Three-D_view](gen/lib/ISO_32000/Three-D_view.pm6)
/CA|[Annotation_markup_additional](gen/lib/ISO_32000/Annotation_markup_additional.pm6) [Appearance_characteristics](gen/lib/ISO_32000/Appearance_characteristics.pm6) [Graphics_state](gen/lib/ISO_32000/Graphics_state.pm6)
/CF|[Encryption_common](gen/lib/ISO_32000/Encryption_common.pm6)
/CFM|[Crypt_filter_common](gen/lib/ISO_32000/Crypt_filter_common.pm6)
/CI|[File_specification](gen/lib/ISO_32000/File_specification.pm6)
/CIDSet|[CIDFont_descriptor_additional](gen/lib/ISO_32000/CIDFont_descriptor_additional.pm6)
/CIDSystemInfo|[CIDFont](gen/lib/ISO_32000/CIDFont.pm6) [CMap_stream](gen/lib/ISO_32000/CMap_stream.pm6)
/CIDToGIDMap|[CIDFont](gen/lib/ISO_32000/CIDFont.pm6)
/CL|[Free_text_annotation_additional](gen/lib/ISO_32000/Free_text_annotation_additional.pm6)
/CMapName|[CMap_stream](gen/lib/ISO_32000/CMap_stream.pm6)
/CO|[Interactive_form](gen/lib/ISO_32000/Interactive_form.pm6) [Line_annotation_additional](gen/lib/ISO_32000/Line_annotation_additional.pm6) [Sound_object](gen/lib/ISO_32000/Sound_object.pm6) [Three-D_view](gen/lib/ISO_32000/Three-D_view.pm6)
/CP|[Line_annotation_additional](gen/lib/ISO_32000/Line_annotation_additional.pm6) [Sound_object](gen/lib/ISO_32000/Sound_object.pm6)
/CS|[Projection](gen/lib/ISO_32000/Projection.pm6) [Three-D_background](gen/lib/ISO_32000/Three-D_background.pm6) [Transparency_group_additional](gen/lib/ISO_32000/Transparency_group_additional.pm6)
/CT|[Media_clip_data](gen/lib/ISO_32000/Media_clip_data.pm6) [Web_Capture_content_sets](gen/lib/ISO_32000/Web_Capture_content_sets.pm6) [Web_capture_command](gen/lib/ISO_32000/Web_capture_command.pm6)
/CV|[Render_mode](gen/lib/ISO_32000/Render_mode.pm6)
/CYX|[Rectilinear_measure_additional](gen/lib/ISO_32000/Rectilinear_measure_additional.pm6)
/Cap|[Line_annotation_additional](gen/lib/ISO_32000/Line_annotation_additional.pm6)
/CapHeight|[Font_descriptor_common](gen/lib/ISO_32000/Font_descriptor_common.pm6)
/Category|[Optional_Content_Group_Application](gen/lib/ISO_32000/Optional_Content_Group_Application.pm6)
/CenterWindow|[Viewer_preferences](gen/lib/ISO_32000/Viewer_preferences.pm6)
/Cert|[Signature](gen/lib/ISO_32000/Signature.pm6) [Signature_field_seed_value](gen/lib/ISO_32000/Signature_field_seed_value.pm6)
/Changes|[Signature](gen/lib/ISO_32000/Signature.pm6)
/CharProcs|[Type_3_Font](gen/lib/ISO_32000/Type_3_Font.pm6)
/CharSet|[Font_descriptor_common](gen/lib/ISO_32000/Font_descriptor_common.pm6)
/CheckSum|[Embedded_file_parameter](gen/lib/ISO_32000/Embedded_file_parameter.pm6)
/ClassMap|[Structure_tree_root](gen/lib/ISO_32000/Structure_tree_root.pm6)
/ClrF|[FDF_field](gen/lib/ISO_32000/FDF_field.pm6)
/ClrFf|[FDF_field](gen/lib/ISO_32000/FDF_field.pm6)
/ColSpan|[Standard_table](gen/lib/ISO_32000/Standard_table.pm6)
/Collection|[Catalog](gen/lib/ISO_32000/Catalog.pm6)
/Color|[OPI_version_1_3](gen/lib/ISO_32000/OPI_version_1_3.pm6) [Standard_layout_structure_type](gen/lib/ISO_32000/Standard_layout_structure_type.pm6)
/ColorSpace|[DeviceN_process](gen/lib/ISO_32000/DeviceN_process.pm6) [Image](gen/lib/ISO_32000/Image.pm6) [Inline_Image](gen/lib/ISO_32000/Inline_Image.pm6) [Resource](gen/lib/ISO_32000/Resource.pm6) [Separation](gen/lib/ISO_32000/Separation.pm6) [Shading_common](gen/lib/ISO_32000/Shading_common.pm6)
/ColorTransform|[DCT_filter](gen/lib/ISO_32000/DCT_filter.pm6)
/ColorType|[OPI_version_1_3](gen/lib/ISO_32000/OPI_version_1_3.pm6)
/Colorants|[DeviceN_colour_space](gen/lib/ISO_32000/DeviceN_colour_space.pm6) [Printers_mark_form](gen/lib/ISO_32000/Printers_mark_form.pm6)
/Colors|[LZW_and_Flate_filter](gen/lib/ISO_32000/LZW_and_Flate_filter.pm6)
/ColumnCount|[Standard_column](gen/lib/ISO_32000/Standard_column.pm6)
/ColumnGap|[Standard_column](gen/lib/ISO_32000/Standard_column.pm6)
/ColumnWidths|[Standard_column](gen/lib/ISO_32000/Standard_column.pm6)
/Columns|[CCITTFax_filter](gen/lib/ISO_32000/CCITTFax_filter.pm6) [LZW_and_Flate_filter](gen/lib/ISO_32000/LZW_and_Flate_filter.pm6)
/Comments|[OPI_version_1_3](gen/lib/ISO_32000/OPI_version_1_3.pm6)
/Components|[DeviceN_process](gen/lib/ISO_32000/DeviceN_process.pm6)
/Configs|[Optional_Content_Group_Properties](gen/lib/ISO_32000/Optional_Content_Group_Properties.pm6)
/ContactInfo|[Signature](gen/lib/ISO_32000/Signature.pm6)
/Contents|[Annotation_common](gen/lib/ISO_32000/Annotation_common.pm6) [Page](gen/lib/ISO_32000/Page.pm6) [Signature](gen/lib/ISO_32000/Signature.pm6)
/Coords|[Type_2_Shading](gen/lib/ISO_32000/Type_2_Shading.pm6) [Type_3_Shading](gen/lib/ISO_32000/Type_3_Shading.pm6)
/Count|[Outline](gen/lib/ISO_32000/Outline.pm6) [Outline_item](gen/lib/ISO_32000/Outline_item.pm6) [Pages](gen/lib/ISO_32000/Pages.pm6)
/CreationDate|[Annotation_markup_additional](gen/lib/ISO_32000/Annotation_markup_additional.pm6) [Embedded_file_parameter](gen/lib/ISO_32000/Embedded_file_parameter.pm6) [Info](gen/lib/ISO_32000/Info.pm6)
/Creator|[Info](gen/lib/ISO_32000/Info.pm6) [MacOS_file_information](gen/lib/ISO_32000/MacOS_file_information.pm6) [Optional_Content_Configuration](gen/lib/ISO_32000/Optional_Content_Configuration.pm6)
/CreatorInfo|[Optional_Content_Group_Usage](gen/lib/ISO_32000/Optional_Content_Group_Usage.pm6)
/CropBox|[Box_colour_information](gen/lib/ISO_32000/Box_colour_information.pm6) [Page](gen/lib/ISO_32000/Page.pm6)
/CropFixed|[OPI_version_1_3](gen/lib/ISO_32000/OPI_version_1_3.pm6)
/CropRect|[OPI_version_1_3](gen/lib/ISO_32000/OPI_version_1_3.pm6) [OPI_version_2_0](gen/lib/ISO_32000/OPI_version_2_0.pm6)
/D|[Annotation_additional_actions](gen/lib/ISO_32000/Annotation_additional_actions.pm6) [Appearance](gen/lib/ISO_32000/Appearance.pm6) [Border_style](gen/lib/ISO_32000/Border_style.pm6) [Box_style](gen/lib/ISO_32000/Box_style.pm6) [Collection](gen/lib/ISO_32000/Collection.pm6) [Collection_subitem](gen/lib/ISO_32000/Collection_subitem.pm6) [Embedded_goto_action_additional](gen/lib/ISO_32000/Embedded_goto_action_additional.pm6) [Floating_window_parameter](gen/lib/ISO_32000/Floating_window_parameter.pm6) [Goto_action_additional](gen/lib/ISO_32000/Goto_action_additional.pm6) [Graphics_state](gen/lib/ISO_32000/Graphics_state.pm6) [Media_clip_data](gen/lib/ISO_32000/Media_clip_data.pm6) [Media_clip_section](gen/lib/ISO_32000/Media_clip_section.pm6) [Number_format](gen/lib/ISO_32000/Number_format.pm6) [Optional_Content_Group_Properties](gen/lib/ISO_32000/Optional_Content_Group_Properties.pm6) [Rectilinear_measure_additional](gen/lib/ISO_32000/Rectilinear_measure_additional.pm6) [Remote_goto_action_additional](gen/lib/ISO_32000/Remote_goto_action_additional.pm6) [Rendition_criteria](gen/lib/ISO_32000/Rendition_criteria.pm6) [Thread_action_additional](gen/lib/ISO_32000/Thread_action_additional.pm6) [Three-D_activation](gen/lib/ISO_32000/Three-D_activation.pm6) [Transition](gen/lib/ISO_32000/Transition.pm6) [Windows_launch_parameters](gen/lib/ISO_32000/Windows_launch_parameters.pm6)
/DA|[Free_text_annotation_additional](gen/lib/ISO_32000/Free_text_annotation_additional.pm6) [Interactive_form](gen/lib/ISO_32000/Interactive_form.pm6) [Redaction_annotation_additional](gen/lib/ISO_32000/Redaction_annotation_additional.pm6) [Variable_text_field](gen/lib/ISO_32000/Variable_text_field.pm6)
/DIS|[Three-D_activation](gen/lib/ISO_32000/Three-D_activation.pm6)
/DL|[Stream_common](gen/lib/ISO_32000/Stream_common.pm6)
/DOS|[File_specification](gen/lib/ISO_32000/File_specification.pm6)
/DP|[Catalog_additional_actions](gen/lib/ISO_32000/Catalog_additional_actions.pm6)
/DR|[Interactive_form](gen/lib/ISO_32000/Interactive_form.pm6)
/DS|[Catalog_additional_actions](gen/lib/ISO_32000/Catalog_additional_actions.pm6) [Free_text_annotation_additional](gen/lib/ISO_32000/Free_text_annotation_additional.pm6) [Variable_text_field](gen/lib/ISO_32000/Variable_text_field.pm6)
/DV|[Field_common](gen/lib/ISO_32000/Field_common.pm6) [Three-D_stream](gen/lib/ISO_32000/Three-D_stream.pm6)
/DW|[CIDFont](gen/lib/ISO_32000/CIDFont.pm6)
/DW2|[CIDFont](gen/lib/ISO_32000/CIDFont.pm6)
/DamagedRowsBeforeError|[CCITTFax_filter](gen/lib/ISO_32000/CCITTFax_filter.pm6)
/Data|[Signature_reference](gen/lib/ISO_32000/Signature_reference.pm6)
/Decode|[Image](gen/lib/ISO_32000/Image.pm6) [Inline_Image](gen/lib/ISO_32000/Inline_Image.pm6) [Type_0_Function](gen/lib/ISO_32000/Type_0_Function.pm6) [Type_4_Shading](gen/lib/ISO_32000/Type_4_Shading.pm6) [Type_5_Shading](gen/lib/ISO_32000/Type_5_Shading.pm6) [Type_6_Shading](gen/lib/ISO_32000/Type_6_Shading.pm6)
/DecodeParms|[Inline_Image](gen/lib/ISO_32000/Inline_Image.pm6) [Stream_common](gen/lib/ISO_32000/Stream_common.pm6)
/Default|[Type_5_halftone](gen/lib/ISO_32000/Type_5_halftone.pm6)
/DefaultForPrinting|[Alternate_Image](gen/lib/ISO_32000/Alternate_Image.pm6)
/Desc|[File_specification](gen/lib/ISO_32000/File_specification.pm6) [PrintField](gen/lib/ISO_32000/PrintField.pm6)
/DescendantFonts|[Type_0_Font](gen/lib/ISO_32000/Type_0_Font.pm6)
/Descent|[Font_descriptor_common](gen/lib/ISO_32000/Font_descriptor_common.pm6)
/Dest|[Link_annotation_additional](gen/lib/ISO_32000/Link_annotation_additional.pm6) [Outline_item](gen/lib/ISO_32000/Outline_item.pm6)
/DestOutputProfile|[Output_intent](gen/lib/ISO_32000/Output_intent.pm6)
/Dests|[Catalog](gen/lib/ISO_32000/Catalog.pm6) [Catalog_Name_tree](gen/lib/ISO_32000/Catalog_Name_tree.pm6)
/DevDepGS_BG|[Legal_attestation](gen/lib/ISO_32000/Legal_attestation.pm6)
/DevDepGS_FL|[Legal_attestation](gen/lib/ISO_32000/Legal_attestation.pm6)
/DevDepGS_HT|[Legal_attestation](gen/lib/ISO_32000/Legal_attestation.pm6)
/DevDepGS_OP|[Legal_attestation](gen/lib/ISO_32000/Legal_attestation.pm6)
/DevDepGS_TR|[Legal_attestation](gen/lib/ISO_32000/Legal_attestation.pm6)
/DevDepGS_UCR|[Legal_attestation](gen/lib/ISO_32000/Legal_attestation.pm6)
/DeviceColorant|[Separation](gen/lib/ISO_32000/Separation.pm6)
/Di|[Transition](gen/lib/ISO_32000/Transition.pm6)
/Differences|[Encoding](gen/lib/ISO_32000/Encoding.pm6) [FDF_dictionary](gen/lib/ISO_32000/FDF_dictionary.pm6)
/DigestMethod|[Signature_field_seed_value](gen/lib/ISO_32000/Signature_field_seed_value.pm6) [Signature_reference](gen/lib/ISO_32000/Signature_reference.pm6)
/Direction|[Viewer_preferences](gen/lib/ISO_32000/Viewer_preferences.pm6)
/DisplayDocTitle|[Viewer_preferences](gen/lib/ISO_32000/Viewer_preferences.pm6)
/Dm|[Transition](gen/lib/ISO_32000/Transition.pm6)
/Doc|[JavaScript](gen/lib/ISO_32000/JavaScript.pm6)
/DocMDP|[Permissions](gen/lib/ISO_32000/Permissions.pm6)
/Document|[UR_transform](gen/lib/ISO_32000/UR_transform.pm6)
/Domain|[Function_common](gen/lib/ISO_32000/Function_common.pm6) [Type_1_Shading](gen/lib/ISO_32000/Type_1_Shading.pm6) [Type_2_Shading](gen/lib/ISO_32000/Type_2_Shading.pm6) [Type_3_Shading](gen/lib/ISO_32000/Type_3_Shading.pm6)
/DotGain|[DeviceN_mixing_hints](gen/lib/ISO_32000/DeviceN_mixing_hints.pm6)
/Duplex|[Viewer_preferences](gen/lib/ISO_32000/Viewer_preferences.pm6)
/Dur|[Navigation_node](gen/lib/ISO_32000/Navigation_node.pm6) [Page](gen/lib/ISO_32000/Page.pm6)
/Duration|[Movie_activation](gen/lib/ISO_32000/Movie_activation.pm6)
/E|[Annotation_additional_actions](gen/lib/ISO_32000/Annotation_additional_actions.pm6) [Collection_field](gen/lib/ISO_32000/Collection_field.pm6) [Linearization_parameter](gen/lib/ISO_32000/Linearization_parameter.pm6) [Media_clip_section_MH-BE](gen/lib/ISO_32000/Media_clip_section_MH-BE.pm6) [Sound_object](gen/lib/ISO_32000/Sound_object.pm6) [Source_information](gen/lib/ISO_32000/Source_information.pm6) [Structure_tree_element](gen/lib/ISO_32000/Structure_tree_element.pm6)
/EA|[Three-D_background](gen/lib/ISO_32000/Three-D_background.pm6)
/EF|[File_specification](gen/lib/ISO_32000/File_specification.pm6) [UR_transform](gen/lib/ISO_32000/UR_transform.pm6)
/EFF|[Encryption_common](gen/lib/ISO_32000/Encryption_common.pm6)
/EarlyChange|[LZW_and_Flate_filter](gen/lib/ISO_32000/LZW_and_Flate_filter.pm6)
/EmbeddedFDFs|[FDF_dictionary](gen/lib/ISO_32000/FDF_dictionary.pm6)
/EmbeddedFiles|[Catalog_Name_tree](gen/lib/ISO_32000/Catalog_Name_tree.pm6)
/Encode|[Type_0_Function](gen/lib/ISO_32000/Type_0_Function.pm6) [Type_3_Function](gen/lib/ISO_32000/Type_3_Function.pm6)
/EncodedByteAlign|[CCITTFax_filter](gen/lib/ISO_32000/CCITTFax_filter.pm6)
/Encoding|[FDF_dictionary](gen/lib/ISO_32000/FDF_dictionary.pm6) [Type_0_Font](gen/lib/ISO_32000/Type_0_Font.pm6) [Type_1_Font](gen/lib/ISO_32000/Type_1_Font.pm6) [Type_3_Font](gen/lib/ISO_32000/Type_3_Font.pm6)
/Encrypt|[File_trailer](gen/lib/ISO_32000/File_trailer.pm6)
/EncryptMetadata|[Additional_encryption](gen/lib/ISO_32000/Additional_encryption.pm6) [Crypt_filter_public-key_additional](gen/lib/ISO_32000/Crypt_filter_public-key_additional.pm6)
/EndIndent|[Standard_layout_block-level_structure_element](gen/lib/ISO_32000/Standard_layout_block-level_structure_element.pm6)
/EndOfBlock|[CCITTFax_filter](gen/lib/ISO_32000/CCITTFax_filter.pm6)
/EndOfLine|[CCITTFax_filter](gen/lib/ISO_32000/CCITTFax_filter.pm6)
/Event|[Optional_Content_Group_Application](gen/lib/ISO_32000/Optional_Content_Group_Application.pm6)
/ExData|[Annotation_markup_additional](gen/lib/ISO_32000/Annotation_markup_additional.pm6)
/Export|[Optional_Content_Group_Usage](gen/lib/ISO_32000/Optional_Content_Group_Usage.pm6)
/ExtGState|[Resource](gen/lib/ISO_32000/Resource.pm6) [Type_2_Pattern](gen/lib/ISO_32000/Type_2_Pattern.pm6)
/Extend|[Type_2_Shading](gen/lib/ISO_32000/Type_2_Shading.pm6) [Type_3_Shading](gen/lib/ISO_32000/Type_3_Shading.pm6)
/Extends|[Object_stream](gen/lib/ISO_32000/Object_stream.pm6)
/ExtensionLevel|[Developer_extensions](gen/lib/ISO_32000/Developer_extensions.pm6)
/Extensions|[Catalog](gen/lib/ISO_32000/Catalog.pm6)
/ExternalOPIdicts|[Legal_attestation](gen/lib/ISO_32000/Legal_attestation.pm6)
/ExternalRefXobjects|[Legal_attestation](gen/lib/ISO_32000/Legal_attestation.pm6)
/ExternalStreams|[Legal_attestation](gen/lib/ISO_32000/Legal_attestation.pm6)
/F|[Annotation_common](gen/lib/ISO_32000/Annotation_common.pm6) [Embedded_goto_action_additional](gen/lib/ISO_32000/Embedded_goto_action_additional.pm6) [FDF_dictionary](gen/lib/ISO_32000/FDF_dictionary.pm6) [FDF_field](gen/lib/ISO_32000/FDF_field.pm6) [FDF_named_page_reference](gen/lib/ISO_32000/FDF_named_page_reference.pm6) [File_specification](gen/lib/ISO_32000/File_specification.pm6) [Form_additional_actions](gen/lib/ISO_32000/Form_additional_actions.pm6) [Import-data_action_additional](gen/lib/ISO_32000/Import-data_action_additional.pm6) [Launch_action_additional](gen/lib/ISO_32000/Launch_action_additional.pm6) [Media_offset_frame](gen/lib/ISO_32000/Media_offset_frame.pm6) [Media_screen_parameters_MH-BE](gen/lib/ISO_32000/Media_screen_parameters_MH-BE.pm6) [Movie](gen/lib/ISO_32000/Movie.pm6) [Number_format](gen/lib/ISO_32000/Number_format.pm6) [OPI_version_1_3](gen/lib/ISO_32000/OPI_version_1_3.pm6) [OPI_version_2_0](gen/lib/ISO_32000/OPI_version_2_0.pm6) [Outline_item](gen/lib/ISO_32000/Outline_item.pm6) [Projection](gen/lib/ISO_32000/Projection.pm6) [Reference](gen/lib/ISO_32000/Reference.pm6) [Remote_goto_action_additional](gen/lib/ISO_32000/Remote_goto_action_additional.pm6) [Stream_common](gen/lib/ISO_32000/Stream_common.pm6) [Submit_form_action](gen/lib/ISO_32000/Submit_form_action.pm6) [Thread](gen/lib/ISO_32000/Thread.pm6) [Thread_action_additional](gen/lib/ISO_32000/Thread_action_additional.pm6) [User_property](gen/lib/ISO_32000/User_property.pm6) [Web_capture_command](gen/lib/ISO_32000/Web_capture_command.pm6) [Windows_launch_parameters](gen/lib/ISO_32000/Windows_launch_parameters.pm6)
/FB|[Icon_fit](gen/lib/ISO_32000/Icon_fit.pm6)
/FC|[Render_mode](gen/lib/ISO_32000/Render_mode.pm6)
/FD|[CIDFont_descriptor_additional](gen/lib/ISO_32000/CIDFont_descriptor_additional.pm6) [Number_format](gen/lib/ISO_32000/Number_format.pm6)
/FDF|[FDF_catalog](gen/lib/ISO_32000/FDF_catalog.pm6)
/FDecodeParms|[Stream_common](gen/lib/ISO_32000/Stream_common.pm6)
/FFilter|[Stream_common](gen/lib/ISO_32000/Stream_common.pm6)
/FL|[Graphics_state](gen/lib/ISO_32000/Graphics_state.pm6)
/FOV|[Projection](gen/lib/ISO_32000/Projection.pm6)
/FS|[File_attachment_annotation_additional](gen/lib/ISO_32000/File_attachment_annotation_additional.pm6) [File_specification](gen/lib/ISO_32000/File_specification.pm6)
/FT|[Field_common](gen/lib/ISO_32000/Field_common.pm6)
/FWPosition|[Movie_activation](gen/lib/ISO_32000/Movie_activation.pm6)
/FWScale|[Movie_activation](gen/lib/ISO_32000/Movie_activation.pm6)
/Ff|[Certificate_seed_value](gen/lib/ISO_32000/Certificate_seed_value.pm6) [FDF_field](gen/lib/ISO_32000/FDF_field.pm6) [Field_common](gen/lib/ISO_32000/Field_common.pm6) [Signature_field_seed_value](gen/lib/ISO_32000/Signature_field_seed_value.pm6)
/Fields|[FDF_dictionary](gen/lib/ISO_32000/FDF_dictionary.pm6) [FDF_template](gen/lib/ISO_32000/FDF_template.pm6) [FieldMDP_transform](gen/lib/ISO_32000/FieldMDP_transform.pm6) [Interactive_form](gen/lib/ISO_32000/Interactive_form.pm6) [Reset_form_action](gen/lib/ISO_32000/Reset_form_action.pm6) [Signature_field_lock](gen/lib/ISO_32000/Signature_field_lock.pm6) [Submit_form_action](gen/lib/ISO_32000/Submit_form_action.pm6)
/Filter|[Encryption_common](gen/lib/ISO_32000/Encryption_common.pm6) [Inline_Image](gen/lib/ISO_32000/Inline_Image.pm6) [Signature](gen/lib/ISO_32000/Signature.pm6) [Signature_field_seed_value](gen/lib/ISO_32000/Signature_field_seed_value.pm6) [Stream_common](gen/lib/ISO_32000/Stream_common.pm6)
/First|[Object_stream](gen/lib/ISO_32000/Object_stream.pm6) [Outline](gen/lib/ISO_32000/Outline.pm6) [Outline_item](gen/lib/ISO_32000/Outline_item.pm6)
/FirstChar|[Type_1_Font](gen/lib/ISO_32000/Type_1_Font.pm6) [Type_3_Font](gen/lib/ISO_32000/Type_3_Font.pm6)
/FitWindow|[Viewer_preferences](gen/lib/ISO_32000/Viewer_preferences.pm6)
/FixedPrint|[Watermark_annotation_additional](gen/lib/ISO_32000/Watermark_annotation_additional.pm6)
/Flags|[Font_descriptor_common](gen/lib/ISO_32000/Font_descriptor_common.pm6) [Reset_form_action](gen/lib/ISO_32000/Reset_form_action.pm6) [Submit_form_action](gen/lib/ISO_32000/Submit_form_action.pm6)
/Fo|[Annotation_additional_actions](gen/lib/ISO_32000/Annotation_additional_actions.pm6)
/Font|[Graphics_state](gen/lib/ISO_32000/Graphics_state.pm6) [Resource](gen/lib/ISO_32000/Resource.pm6)
/FontBBox|[Font_descriptor_common](gen/lib/ISO_32000/Font_descriptor_common.pm6) [Type_3_Font](gen/lib/ISO_32000/Type_3_Font.pm6)
/FontDescriptor|[CIDFont](gen/lib/ISO_32000/CIDFont.pm6) [Type_1_Font](gen/lib/ISO_32000/Type_1_Font.pm6) [Type_3_Font](gen/lib/ISO_32000/Type_3_Font.pm6)
/FontFamily|[Font_descriptor_common](gen/lib/ISO_32000/Font_descriptor_common.pm6) [Font_selector](gen/lib/ISO_32000/Font_selector.pm6)
/FontFauxing|[Trap_network_annotation](gen/lib/ISO_32000/Trap_network_annotation.pm6)
/FontFile|[Font_descriptor_common](gen/lib/ISO_32000/Font_descriptor_common.pm6)
/FontFile2|[Font_descriptor_common](gen/lib/ISO_32000/Font_descriptor_common.pm6)
/FontFile3|[Font_descriptor_common](gen/lib/ISO_32000/Font_descriptor_common.pm6)
/FontMatrix|[Type_3_Font](gen/lib/ISO_32000/Type_3_Font.pm6)
/FontName|[Font_descriptor_common](gen/lib/ISO_32000/Font_descriptor_common.pm6)
/FontSize|[Font_selector](gen/lib/ISO_32000/Font_selector.pm6)
/FontStretch|[Font_descriptor_common](gen/lib/ISO_32000/Font_descriptor_common.pm6) [Font_selector](gen/lib/ISO_32000/Font_selector.pm6)
/FontStyle|[Font_selector](gen/lib/ISO_32000/Font_selector.pm6)
/FontVariant|[Font_selector](gen/lib/ISO_32000/Font_selector.pm6)
/FontWeight|[Font_descriptor_common](gen/lib/ISO_32000/Font_descriptor_common.pm6) [Font_selector](gen/lib/ISO_32000/Font_selector.pm6)
/Form|[UR_transform](gen/lib/ISO_32000/UR_transform.pm6)
/FormType|[Type_1_Form](gen/lib/ISO_32000/Type_1_Form.pm6)
/Frequency|[Type_1_halftone](gen/lib/ISO_32000/Type_1_halftone.pm6)
/Function|[Type_1_Shading](gen/lib/ISO_32000/Type_1_Shading.pm6) [Type_2_Shading](gen/lib/ISO_32000/Type_2_Shading.pm6) [Type_3_Shading](gen/lib/ISO_32000/Type_3_Shading.pm6) [Type_4_Shading](gen/lib/ISO_32000/Type_4_Shading.pm6) [Type_5_Shading](gen/lib/ISO_32000/Type_5_Shading.pm6) [Type_6_Shading](gen/lib/ISO_32000/Type_6_Shading.pm6)
/FunctionType|[Function_common](gen/lib/ISO_32000/Function_common.pm6)
/Functions|[Type_3_Function](gen/lib/ISO_32000/Type_3_Function.pm6)
/G|[Soft-mask](gen/lib/ISO_32000/Soft-mask.pm6) [Web_capture_command_settings](gen/lib/ISO_32000/Web_capture_command_settings.pm6)
/Gamma|[CalGray_colour_space](gen/lib/ISO_32000/CalGray_colour_space.pm6) [CalRGB_colour_space](gen/lib/ISO_32000/CalRGB_colour_space.pm6)
/GenericFontFamily|[Font_selector](gen/lib/ISO_32000/Font_selector.pm6)
/GlyphOrientationVertical|[Standard_inline-level_structure_element](gen/lib/ISO_32000/Standard_inline-level_structure_element.pm6)
/GoToRemoteActions|[Legal_attestation](gen/lib/ISO_32000/Legal_attestation.pm6)
/GrayMap|[OPI_version_1_3](gen/lib/ISO_32000/OPI_version_1_3.pm6)
/Group|[Page](gen/lib/ISO_32000/Page.pm6) [Type_1_Form](gen/lib/ISO_32000/Type_1_Form.pm6)
/H|[Fixed_print](gen/lib/ISO_32000/Fixed_print.pm6) [Hide_action_additional](gen/lib/ISO_32000/Hide_action_additional.pm6) [Linearization_parameter](gen/lib/ISO_32000/Linearization_parameter.pm6) [Link_annotation_additional](gen/lib/ISO_32000/Link_annotation_additional.pm6) [Software_identifier](gen/lib/ISO_32000/Software_identifier.pm6) [User_property](gen/lib/ISO_32000/User_property.pm6) [Web_capture_command](gen/lib/ISO_32000/Web_capture_command.pm6) [Widget_annotation_additional](gen/lib/ISO_32000/Widget_annotation_additional.pm6)
/HI|[Software_identifier](gen/lib/ISO_32000/Software_identifier.pm6)
/HT|[Graphics_state](gen/lib/ISO_32000/Graphics_state.pm6)
/HalftoneName|[Type_10_halftone](gen/lib/ISO_32000/Type_10_halftone.pm6) [Type_16_halftone](gen/lib/ISO_32000/Type_16_halftone.pm6) [Type_1_halftone](gen/lib/ISO_32000/Type_1_halftone.pm6) [Type_5_halftone](gen/lib/ISO_32000/Type_5_halftone.pm6) [Type_6_halftone](gen/lib/ISO_32000/Type_6_halftone.pm6)
/HalftoneType|[Type_10_halftone](gen/lib/ISO_32000/Type_10_halftone.pm6) [Type_16_halftone](gen/lib/ISO_32000/Type_16_halftone.pm6) [Type_1_halftone](gen/lib/ISO_32000/Type_1_halftone.pm6) [Type_5_halftone](gen/lib/ISO_32000/Type_5_halftone.pm6) [Type_6_halftone](gen/lib/ISO_32000/Type_6_halftone.pm6)
/Headers|[Standard_table](gen/lib/ISO_32000/Standard_table.pm6)
/Height|[Image](gen/lib/ISO_32000/Image.pm6) [Inline_Image](gen/lib/ISO_32000/Inline_Image.pm6) [Standard_layout_block-level_structure_element](gen/lib/ISO_32000/Standard_layout_block-level_structure_element.pm6) [Type_16_halftone](gen/lib/ISO_32000/Type_16_halftone.pm6) [Type_6_halftone](gen/lib/ISO_32000/Type_6_halftone.pm6)
/Height2|[Type_16_halftone](gen/lib/ISO_32000/Type_16_halftone.pm6)
/HideAnnotationActions|[Legal_attestation](gen/lib/ISO_32000/Legal_attestation.pm6)
/HideMenubar|[Viewer_preferences](gen/lib/ISO_32000/Viewer_preferences.pm6)
/HideToolbar|[Viewer_preferences](gen/lib/ISO_32000/Viewer_preferences.pm6)
/HideWindowUI|[Viewer_preferences](gen/lib/ISO_32000/Viewer_preferences.pm6)
/I|[Appearance_characteristics](gen/lib/ISO_32000/Appearance_characteristics.pm6) [Border_effect](gen/lib/ISO_32000/Border_effect.pm6) [Choice_field_additional](gen/lib/ISO_32000/Choice_field_additional.pm6) [Thread](gen/lib/ISO_32000/Thread.pm6) [Transparency_group_additional](gen/lib/ISO_32000/Transparency_group_additional.pm6)
/IC|[Line_annotation_additional](gen/lib/ISO_32000/Line_annotation_additional.pm6) [Polygon_or_polyline_annotation_additional](gen/lib/ISO_32000/Polygon_or_polyline_annotation_additional.pm6) [Redaction_annotation_additional](gen/lib/ISO_32000/Redaction_annotation_additional.pm6) [Square_or_circle_annotation_additional](gen/lib/ISO_32000/Square_or_circle_annotation_additional.pm6) [Three-D_cross_section](gen/lib/ISO_32000/Three-D_cross_section.pm6)
/ID|[FDF_dictionary](gen/lib/ISO_32000/FDF_dictionary.pm6) [File_specification](gen/lib/ISO_32000/File_specification.pm6) [File_trailer](gen/lib/ISO_32000/File_trailer.pm6) [Image](gen/lib/ISO_32000/Image.pm6) [OPI_version_1_3](gen/lib/ISO_32000/OPI_version_1_3.pm6) [Page](gen/lib/ISO_32000/Page.pm6) [Reference](gen/lib/ISO_32000/Reference.pm6) [Structure_tree_element](gen/lib/ISO_32000/Structure_tree_element.pm6) [Web_Capture_content_sets](gen/lib/ISO_32000/Web_Capture_content_sets.pm6)
/IDS|[Catalog_Name_tree](gen/lib/ISO_32000/Catalog_Name_tree.pm6)
/IDTree|[Structure_tree_root](gen/lib/ISO_32000/Structure_tree_root.pm6)
/IF|[Appearance_characteristics](gen/lib/ISO_32000/Appearance_characteristics.pm6) [FDF_field](gen/lib/ISO_32000/FDF_field.pm6)
/IN|[Three-D_view](gen/lib/ISO_32000/Three-D_view.pm6)
/IRT|[Annotation_markup_additional](gen/lib/ISO_32000/Annotation_markup_additional.pm6)
/IT|[Annotation_markup_additional](gen/lib/ISO_32000/Annotation_markup_additional.pm6) [Free_text_annotation_additional](gen/lib/ISO_32000/Free_text_annotation_additional.pm6) [Line_annotation_additional](gen/lib/ISO_32000/Line_annotation_additional.pm6) [Polygon_or_polyline_annotation_additional](gen/lib/ISO_32000/Polygon_or_polyline_annotation_additional.pm6)
/IV|[Three-D_cross_section](gen/lib/ISO_32000/Three-D_cross_section.pm6)
/IX|[Appearance_characteristics](gen/lib/ISO_32000/Appearance_characteristics.pm6)
/Image|[Alternate_Image](gen/lib/ISO_32000/Alternate_Image.pm6)
/ImageMask|[Image](gen/lib/ISO_32000/Image.pm6) [Inline_Image](gen/lib/ISO_32000/Inline_Image.pm6)
/ImageType|[OPI_version_1_3](gen/lib/ISO_32000/OPI_version_1_3.pm6)
/IncludedImageDimensions|[OPI_version_2_0](gen/lib/ISO_32000/OPI_version_2_0.pm6)
/IncludedImageQuality|[OPI_version_2_0](gen/lib/ISO_32000/OPI_version_2_0.pm6)
/Index|[Cross_reference_stream](gen/lib/ISO_32000/Cross_reference_stream.pm6)
/Info|[FDF_page](gen/lib/ISO_32000/FDF_page.pm6) [File_trailer](gen/lib/ISO_32000/File_trailer.pm6) [Output_intent](gen/lib/ISO_32000/Output_intent.pm6)
/InkList|[Ink_annotation_additional](gen/lib/ISO_32000/Ink_annotation_additional.pm6)
/Inks|[OPI_version_2_0](gen/lib/ISO_32000/OPI_version_2_0.pm6)
/InlineAlign|[Standard_layout_block-level_structure_element](gen/lib/ISO_32000/Standard_layout_block-level_structure_element.pm6)
/Intent|[Image](gen/lib/ISO_32000/Image.pm6) [Inline_Image](gen/lib/ISO_32000/Inline_Image.pm6) [Optional_Content_Configuration](gen/lib/ISO_32000/Optional_Content_Configuration.pm6) [Optional_Content_Group](gen/lib/ISO_32000/Optional_Content_Group.pm6)
/Interpolate|[Image](gen/lib/ISO_32000/Image.pm6) [Inline_Image](gen/lib/ISO_32000/Inline_Image.pm6)
/IsMap|[URI_action_additional](gen/lib/ISO_32000/URI_action_additional.pm6)
/Issuer|[Certificate_seed_value](gen/lib/ISO_32000/Certificate_seed_value.pm6)
/ItalicAngle|[Font_descriptor_common](gen/lib/ISO_32000/Font_descriptor_common.pm6)
/JBIG2Globals|[JBIG2_filter](gen/lib/ISO_32000/JBIG2_filter.pm6)
/JS|[JavaScript_action_additional](gen/lib/ISO_32000/JavaScript_action_additional.pm6) [Rendition_action_additional](gen/lib/ISO_32000/Rendition_action_additional.pm6)
/JavaScript|[Catalog_Name_tree](gen/lib/ISO_32000/Catalog_Name_tree.pm6) [FDF_dictionary](gen/lib/ISO_32000/FDF_dictionary.pm6)
/JavaScriptActions|[Legal_attestation](gen/lib/ISO_32000/Legal_attestation.pm6)
/K|[CCITTFax_filter](gen/lib/ISO_32000/CCITTFax_filter.pm6) [Form_additional_actions](gen/lib/ISO_32000/Form_additional_actions.pm6) [Structure_tree_element](gen/lib/ISO_32000/Structure_tree_element.pm6) [Structure_tree_root](gen/lib/ISO_32000/Structure_tree_root.pm6) [Transparency_group_additional](gen/lib/ISO_32000/Transparency_group_additional.pm6)
/KeyUsage|[Certificate_seed_value](gen/lib/ISO_32000/Certificate_seed_value.pm6)
/Keywords|[Info](gen/lib/ISO_32000/Info.pm6)
/Kids|[FDF_field](gen/lib/ISO_32000/FDF_field.pm6) [Field_common](gen/lib/ISO_32000/Field_common.pm6) [Name_tree_node](gen/lib/ISO_32000/Name_tree_node.pm6) [Number_tree_node](gen/lib/ISO_32000/Number_tree_node.pm6) [Pages](gen/lib/ISO_32000/Pages.pm6)
/L|[Line_annotation_additional](gen/lib/ISO_32000/Line_annotation_additional.pm6) [Linearization_parameter](gen/lib/ISO_32000/Linearization_parameter.pm6) [Rendition_criteria](gen/lib/ISO_32000/Rendition_criteria.pm6) [Software_identifier](gen/lib/ISO_32000/Software_identifier.pm6) [Web_capture_command](gen/lib/ISO_32000/Web_capture_command.pm6)
/LC|[Graphics_state](gen/lib/ISO_32000/Graphics_state.pm6)
/LE|[Free_text_annotation_additional](gen/lib/ISO_32000/Free_text_annotation_additional.pm6) [Line_annotation_additional](gen/lib/ISO_32000/Line_annotation_additional.pm6) [Polygon_or_polyline_annotation_additional](gen/lib/ISO_32000/Polygon_or_polyline_annotation_additional.pm6)
/LI|[Software_identifier](gen/lib/ISO_32000/Software_identifier.pm6)
/LJ|[Graphics_state](gen/lib/ISO_32000/Graphics_state.pm6)
/LL|[Line_annotation_additional](gen/lib/ISO_32000/Line_annotation_additional.pm6)
/LLE|[Line_annotation_additional](gen/lib/ISO_32000/Line_annotation_additional.pm6)
/LLO|[Line_annotation_additional](gen/lib/ISO_32000/Line_annotation_additional.pm6)
/LS|[Three-D_view](gen/lib/ISO_32000/Three-D_view.pm6)
/LW|[Graphics_state](gen/lib/ISO_32000/Graphics_state.pm6)
/Lang|[CIDFont_descriptor_additional](gen/lib/ISO_32000/CIDFont_descriptor_additional.pm6) [Catalog](gen/lib/ISO_32000/Catalog.pm6) [Structure_tree_element](gen/lib/ISO_32000/Structure_tree_element.pm6)
/Language|[Optional_Content_Group_Usage](gen/lib/ISO_32000/Optional_Content_Group_Usage.pm6)
/Last|[Outline](gen/lib/ISO_32000/Outline.pm6) [Outline_item](gen/lib/ISO_32000/Outline_item.pm6)
/LastChar|[Type_1_Font](gen/lib/ISO_32000/Type_1_Font.pm6) [Type_3_Font](gen/lib/ISO_32000/Type_3_Font.pm6)
/LastModified|[Data](gen/lib/ISO_32000/Data.pm6) [Page](gen/lib/ISO_32000/Page.pm6) [Trap_network_annotation](gen/lib/ISO_32000/Trap_network_annotation.pm6) [Type_1_Form](gen/lib/ISO_32000/Type_1_Form.pm6)
/LaunchActions|[Legal_attestation](gen/lib/ISO_32000/Legal_attestation.pm6)
/Leading|[Font_descriptor_common](gen/lib/ISO_32000/Font_descriptor_common.pm6)
/Legal|[Catalog](gen/lib/ISO_32000/Catalog.pm6)
/LegalAttestation|[Signature_field_seed_value](gen/lib/ISO_32000/Signature_field_seed_value.pm6)
/Length|[Crypt_filter_common](gen/lib/ISO_32000/Crypt_filter_common.pm6) [Encryption_common](gen/lib/ISO_32000/Encryption_common.pm6) [Stream_common](gen/lib/ISO_32000/Stream_common.pm6)
/Length1|[Embedded_font_stream_additional](gen/lib/ISO_32000/Embedded_font_stream_additional.pm6)
/Length2|[Embedded_font_stream_additional](gen/lib/ISO_32000/Embedded_font_stream_additional.pm6)
/Length3|[Embedded_font_stream_additional](gen/lib/ISO_32000/Embedded_font_stream_additional.pm6)
/Level1|[Postscript_XObject](gen/lib/ISO_32000/Postscript_XObject.pm6)
/Limits|[Name_tree_node](gen/lib/ISO_32000/Name_tree_node.pm6) [Number_tree_node](gen/lib/ISO_32000/Number_tree_node.pm6)
/LineHeight|[Standard_inline-level_structure_element](gen/lib/ISO_32000/Standard_inline-level_structure_element.pm6)
/Linearized|[Linearization_parameter](gen/lib/ISO_32000/Linearization_parameter.pm6)
/ListMode|[Optional_Content_Configuration](gen/lib/ISO_32000/Optional_Content_Configuration.pm6)
/ListNumbering|[Standard_list](gen/lib/ISO_32000/Standard_list.pm6)
/Location|[Signature](gen/lib/ISO_32000/Signature.pm6)
/Lock|[Signature_field](gen/lib/ISO_32000/Signature_field.pm6)
/Locked|[Optional_Content_Configuration](gen/lib/ISO_32000/Optional_Content_Configuration.pm6)
/M|[Annotation_common](gen/lib/ISO_32000/Annotation_common.pm6) [Media_offset_marker](gen/lib/ISO_32000/Media_offset_marker.pm6) [Media_screen_parameters_MH-BE](gen/lib/ISO_32000/Media_screen_parameters_MH-BE.pm6) [Minimum_bit_depth](gen/lib/ISO_32000/Minimum_bit_depth.pm6) [Minimum_screen_size](gen/lib/ISO_32000/Minimum_screen_size.pm6) [Signature](gen/lib/ISO_32000/Signature.pm6) [Three-D_node](gen/lib/ISO_32000/Three-D_node.pm6) [Transition](gen/lib/ISO_32000/Transition.pm6)
/MCID|[Marked_content_reference](gen/lib/ISO_32000/Marked_content_reference.pm6)
/MD5|[Three-D_external_data](gen/lib/ISO_32000/Three-D_external_data.pm6)
/MDP|[Signature_field_seed_value](gen/lib/ISO_32000/Signature_field_seed_value.pm6)
/MH|[Media_clip_data](gen/lib/ISO_32000/Media_clip_data.pm6) [Media_clip_section](gen/lib/ISO_32000/Media_clip_section.pm6) [Media_play_parameters](gen/lib/ISO_32000/Media_play_parameters.pm6) [Media_player_info](gen/lib/ISO_32000/Media_player_info.pm6) [Media_screen_parameters](gen/lib/ISO_32000/Media_screen_parameters.pm6) [Rendition_common](gen/lib/ISO_32000/Rendition_common.pm6)
/MK|[Screen_annotation_additional](gen/lib/ISO_32000/Screen_annotation_additional.pm6) [Widget_annotation_additional](gen/lib/ISO_32000/Widget_annotation_additional.pm6)
/ML|[Graphics_state](gen/lib/ISO_32000/Graphics_state.pm6)
/MN|[Printers_mark_annotation](gen/lib/ISO_32000/Printers_mark_annotation.pm6)
/MS|[Three-D_view](gen/lib/ISO_32000/Three-D_view.pm6)
/MU|[Media_players](gen/lib/ISO_32000/Media_players.pm6)
/Mac|[Embedded_file_parameter](gen/lib/ISO_32000/Embedded_file_parameter.pm6) [File_specification](gen/lib/ISO_32000/File_specification.pm6) [Launch_action_additional](gen/lib/ISO_32000/Launch_action_additional.pm6)
/MainImage|[OPI_version_2_0](gen/lib/ISO_32000/OPI_version_2_0.pm6)
/MarkInfo|[Catalog](gen/lib/ISO_32000/Catalog.pm6)
/MarkStyle|[Printers_mark_form](gen/lib/ISO_32000/Printers_mark_form.pm6)
/Marked|[Mark_information](gen/lib/ISO_32000/Mark_information.pm6)
/Mask|[Image](gen/lib/ISO_32000/Image.pm6)
/Matrix|[CalRGB_colour_space](gen/lib/ISO_32000/CalRGB_colour_space.pm6) [Fixed_print](gen/lib/ISO_32000/Fixed_print.pm6) [Type_1_Form](gen/lib/ISO_32000/Type_1_Form.pm6) [Type_1_Pattern](gen/lib/ISO_32000/Type_1_Pattern.pm6) [Type_1_Shading](gen/lib/ISO_32000/Type_1_Shading.pm6) [Type_2_Pattern](gen/lib/ISO_32000/Type_2_Pattern.pm6)
/Matte|[Soft-mask_image_additional](gen/lib/ISO_32000/Soft-mask_image_additional.pm6)
/MaxLen|[Text_field_additional](gen/lib/ISO_32000/Text_field_additional.pm6)
/MaxWidth|[Font_descriptor_common](gen/lib/ISO_32000/Font_descriptor_common.pm6)
/Measure|[Line_annotation_additional](gen/lib/ISO_32000/Line_annotation_additional.pm6) [Polygon_or_polyline_annotation_additional](gen/lib/ISO_32000/Polygon_or_polyline_annotation_additional.pm6) [Viewport](gen/lib/ISO_32000/Viewport.pm6)
/MediaBox|[Page](gen/lib/ISO_32000/Page.pm6)
/Metadata|[Catalog](gen/lib/ISO_32000/Catalog.pm6) [Embedded_font_stream_additional](gen/lib/ISO_32000/Embedded_font_stream_additional.pm6) [ICC_profile](gen/lib/ISO_32000/ICC_profile.pm6) [Image](gen/lib/ISO_32000/Image.pm6) [Metadata_additional](gen/lib/ISO_32000/Metadata_additional.pm6) [Page](gen/lib/ISO_32000/Page.pm6) [Type_1_Form](gen/lib/ISO_32000/Type_1_Form.pm6)
/MissingWidth|[Font_descriptor_common](gen/lib/ISO_32000/Font_descriptor_common.pm6)
/Mix|[Sound_action_additional](gen/lib/ISO_32000/Sound_action_additional.pm6)
/MixingHints|[DeviceN_colour_space](gen/lib/ISO_32000/DeviceN_colour_space.pm6)
/ModDate|[Embedded_file_parameter](gen/lib/ISO_32000/Embedded_file_parameter.pm6) [Info](gen/lib/ISO_32000/Info.pm6)
/Mode|[Movie_activation](gen/lib/ISO_32000/Movie_activation.pm6)
/Movie|[Movie_annotation_additional](gen/lib/ISO_32000/Movie_annotation_additional.pm6)
/MovieActions|[Legal_attestation](gen/lib/ISO_32000/Legal_attestation.pm6)
/Msg|[UR_transform](gen/lib/ISO_32000/UR_transform.pm6)
/N|[Appearance](gen/lib/ISO_32000/Appearance.pm6) [Bead](gen/lib/ISO_32000/Bead.pm6) [Collection_field](gen/lib/ISO_32000/Collection_field.pm6) [ICC_profile](gen/lib/ISO_32000/ICC_profile.pm6) [Linearization_parameter](gen/lib/ISO_32000/Linearization_parameter.pm6) [Media_clip_common](gen/lib/ISO_32000/Media_clip_common.pm6) [Named_action_additional](gen/lib/ISO_32000/Named_action_additional.pm6) [Object_stream](gen/lib/ISO_32000/Object_stream.pm6) [Projection](gen/lib/ISO_32000/Projection.pm6) [Rendition_common](gen/lib/ISO_32000/Rendition_common.pm6) [Target](gen/lib/ISO_32000/Target.pm6) [Three-D_node](gen/lib/ISO_32000/Three-D_node.pm6) [Type_2_Function](gen/lib/ISO_32000/Type_2_Function.pm6) [User_property](gen/lib/ISO_32000/User_property.pm6)
/NA|[Navigation_node](gen/lib/ISO_32000/Navigation_node.pm6) [Three-D_view](gen/lib/ISO_32000/Three-D_view.pm6)
/NM|[Annotation_common](gen/lib/ISO_32000/Annotation_common.pm6)
/NP|[Three-D_activation](gen/lib/ISO_32000/Three-D_activation.pm6)
/NR|[Three-D_view](gen/lib/ISO_32000/Three-D_view.pm6)
/NU|[Media_players](gen/lib/ISO_32000/Media_players.pm6)
/Name|[Crypt_filter](gen/lib/ISO_32000/Crypt_filter.pm6) [FDF_named_page_reference](gen/lib/ISO_32000/FDF_named_page_reference.pm6) [File_attachment_annotation_additional](gen/lib/ISO_32000/File_attachment_annotation_additional.pm6) [Image](gen/lib/ISO_32000/Image.pm6) [Optional_Content_Configuration](gen/lib/ISO_32000/Optional_Content_Configuration.pm6) [Optional_Content_Group](gen/lib/ISO_32000/Optional_Content_Group.pm6) [Rubber_stamp_annotation_additional](gen/lib/ISO_32000/Rubber_stamp_annotation_additional.pm6) [Signature](gen/lib/ISO_32000/Signature.pm6) [Sound_annotation_additional](gen/lib/ISO_32000/Sound_annotation_additional.pm6) [Text_annotation_additional](gen/lib/ISO_32000/Text_annotation_additional.pm6) [Type_1_Font](gen/lib/ISO_32000/Type_1_Font.pm6) [Type_1_Form](gen/lib/ISO_32000/Type_1_Form.pm6) [Type_3_Font](gen/lib/ISO_32000/Type_3_Font.pm6) [Viewport](gen/lib/ISO_32000/Viewport.pm6)
/Names|[Catalog](gen/lib/ISO_32000/Catalog.pm6) [Name_tree_node](gen/lib/ISO_32000/Name_tree_node.pm6)
/NeedAppearances|[Interactive_form](gen/lib/ISO_32000/Interactive_form.pm6)
/NeedsRendering|[Catalog](gen/lib/ISO_32000/Catalog.pm6)
/NewWindow|[Embedded_goto_action_additional](gen/lib/ISO_32000/Embedded_goto_action_additional.pm6) [Launch_action_additional](gen/lib/ISO_32000/Launch_action_additional.pm6) [Remote_goto_action_additional](gen/lib/ISO_32000/Remote_goto_action_additional.pm6)
/Next|[Action_common](gen/lib/ISO_32000/Action_common.pm6) [Navigation_node](gen/lib/ISO_32000/Navigation_node.pm6) [Outline_item](gen/lib/ISO_32000/Outline_item.pm6)
/NonEmbeddedFonts|[Legal_attestation](gen/lib/ISO_32000/Legal_attestation.pm6)
/NonFullScreenPageMode|[Viewer_preferences](gen/lib/ISO_32000/Viewer_preferences.pm6)
/NumCopies|[Viewer_preferences](gen/lib/ISO_32000/Viewer_preferences.pm6)
/Nums|[Number_tree_node](gen/lib/ISO_32000/Number_tree_node.pm6)
/O|[Additional_encryption](gen/lib/ISO_32000/Additional_encryption.pm6) [Attribute_object](gen/lib/ISO_32000/Attribute_object.pm6) [Attribute_object_for_user_properties](gen/lib/ISO_32000/Attribute_object_for_user_properties.pm6) [Collection_field](gen/lib/ISO_32000/Collection_field.pm6) [Floating_window_parameter](gen/lib/ISO_32000/Floating_window_parameter.pm6) [Linearization_parameter](gen/lib/ISO_32000/Linearization_parameter.pm6) [Media_screen_parameters_MH-BE](gen/lib/ISO_32000/Media_screen_parameters_MH-BE.pm6) [Number_format](gen/lib/ISO_32000/Number_format.pm6) [Page_additional_actions](gen/lib/ISO_32000/Page_additional_actions.pm6) [Rectilinear_measure_additional](gen/lib/ISO_32000/Rectilinear_measure_additional.pm6) [Render_mode](gen/lib/ISO_32000/Render_mode.pm6) [Rendition_criteria](gen/lib/ISO_32000/Rendition_criteria.pm6) [Three-D_cross_section](gen/lib/ISO_32000/Three-D_cross_section.pm6) [Three-D_node](gen/lib/ISO_32000/Three-D_node.pm6) [Three-D_view](gen/lib/ISO_32000/Three-D_view.pm6) [Web_Capture_content_sets](gen/lib/ISO_32000/Web_Capture_content_sets.pm6) [Windows_launch_parameters](gen/lib/ISO_32000/Windows_launch_parameters.pm6)
/OB|[Projection](gen/lib/ISO_32000/Projection.pm6)
/OC|[Alternate_Image](gen/lib/ISO_32000/Alternate_Image.pm6) [Annotation_common](gen/lib/ISO_32000/Annotation_common.pm6) [Image](gen/lib/ISO_32000/Image.pm6) [Type_1_Form](gen/lib/ISO_32000/Type_1_Form.pm6)
/OCGs|[Optional_Content_Group_Application](gen/lib/ISO_32000/Optional_Content_Group_Application.pm6) [Optional_Content_Group_Membership](gen/lib/ISO_32000/Optional_Content_Group_Membership.pm6) [Optional_Content_Group_Properties](gen/lib/ISO_32000/Optional_Content_Group_Properties.pm6)
/OCProperties|[Catalog](gen/lib/ISO_32000/Catalog.pm6)
/OFF|[Optional_Content_Configuration](gen/lib/ISO_32000/Optional_Content_Configuration.pm6)
/OID|[Certificate_seed_value](gen/lib/ISO_32000/Certificate_seed_value.pm6)
/ON|[Optional_Content_Configuration](gen/lib/ISO_32000/Optional_Content_Configuration.pm6)
/OP|[Graphics_state](gen/lib/ISO_32000/Graphics_state.pm6) [Rendition_action_additional](gen/lib/ISO_32000/Rendition_action_additional.pm6)
/OPI|[Image](gen/lib/ISO_32000/Image.pm6) [Type_1_Form](gen/lib/ISO_32000/Type_1_Form.pm6)
/OPM|[Graphics_state](gen/lib/ISO_32000/Graphics_state.pm6)
/OS|[Projection](gen/lib/ISO_32000/Projection.pm6) [Software_identifier](gen/lib/ISO_32000/Software_identifier.pm6)
/Obj|[Object_reference](gen/lib/ISO_32000/Object_reference.pm6)
/OnInstantiate|[Three-D_stream](gen/lib/ISO_32000/Three-D_stream.pm6)
/Open|[Popup_annotation_additional](gen/lib/ISO_32000/Popup_annotation_additional.pm6) [Text_annotation_additional](gen/lib/ISO_32000/Text_annotation_additional.pm6)
/OpenAction|[Catalog](gen/lib/ISO_32000/Catalog.pm6)
/Operation|[Movie_action_additional](gen/lib/ISO_32000/Movie_action_additional.pm6)
/Opt|[Check_box_and_radio_button_additional](gen/lib/ISO_32000/Check_box_and_radio_button_additional.pm6) [Choice_field_additional](gen/lib/ISO_32000/Choice_field_additional.pm6) [FDF_field](gen/lib/ISO_32000/FDF_field.pm6)
/OptionalContent|[Legal_attestation](gen/lib/ISO_32000/Legal_attestation.pm6)
/Order|[Optional_Content_Configuration](gen/lib/ISO_32000/Optional_Content_Configuration.pm6) [Type_0_Function](gen/lib/ISO_32000/Type_0_Function.pm6)
/Ordering|[CIDSystemInfo](gen/lib/ISO_32000/CIDSystemInfo.pm6)
/Outlines|[Catalog](gen/lib/ISO_32000/Catalog.pm6)
/OutputCondition|[Output_intent](gen/lib/ISO_32000/Output_intent.pm6)
/OutputConditionIdentifier|[Output_intent](gen/lib/ISO_32000/Output_intent.pm6)
/OutputIntents|[Catalog](gen/lib/ISO_32000/Catalog.pm6)
/OverlayText|[Redaction_annotation_additional](gen/lib/ISO_32000/Redaction_annotation_additional.pm6)
/Overprint|[OPI_version_1_3](gen/lib/ISO_32000/OPI_version_1_3.pm6) [OPI_version_2_0](gen/lib/ISO_32000/OPI_version_2_0.pm6)
/P|[Additional_encryption](gen/lib/ISO_32000/Additional_encryption.pm6) [Annotation_common](gen/lib/ISO_32000/Annotation_common.pm6) [Attribute_object_for_user_properties](gen/lib/ISO_32000/Attribute_object_for_user_properties.pm6) [Bead](gen/lib/ISO_32000/Bead.pm6) [Collection_subitem](gen/lib/ISO_32000/Collection_subitem.pm6) [DocMDP_transform](gen/lib/ISO_32000/DocMDP_transform.pm6) [Floating_window_parameter](gen/lib/ISO_32000/Floating_window_parameter.pm6) [Linearization_parameter](gen/lib/ISO_32000/Linearization_parameter.pm6) [Media_clip_data](gen/lib/ISO_32000/Media_clip_data.pm6) [Media_rendition](gen/lib/ISO_32000/Media_rendition.pm6) [Optional_Content_Group_Membership](gen/lib/ISO_32000/Optional_Content_Group_Membership.pm6) [Page_label](gen/lib/ISO_32000/Page_label.pm6) [Public_key_security_handler_additional](gen/lib/ISO_32000/Public_key_security_handler_additional.pm6) [Rendition_criteria](gen/lib/ISO_32000/Rendition_criteria.pm6) [Structure_tree_element](gen/lib/ISO_32000/Structure_tree_element.pm6) [Target](gen/lib/ISO_32000/Target.pm6) [Three-D_view](gen/lib/ISO_32000/Three-D_view.pm6) [UR_transform](gen/lib/ISO_32000/UR_transform.pm6) [Web_capture_command](gen/lib/ISO_32000/Web_capture_command.pm6) [Windows_launch_parameters](gen/lib/ISO_32000/Windows_launch_parameters.pm6)
/PA|[Link_annotation_additional](gen/lib/ISO_32000/Link_annotation_additional.pm6) [Navigation_node](gen/lib/ISO_32000/Navigation_node.pm6)
/PC|[Annotation_additional_actions](gen/lib/ISO_32000/Annotation_additional_actions.pm6) [Three-D_animation_style](gen/lib/ISO_32000/Three-D_animation_style.pm6) [Three-D_cross_section](gen/lib/ISO_32000/Three-D_cross_section.pm6)
/PCM|[Trap_network_appearance_stream](gen/lib/ISO_32000/Trap_network_appearance_stream.pm6)
/PI|[Annotation_additional_actions](gen/lib/ISO_32000/Annotation_additional_actions.pm6)
/PID|[Media_player_info](gen/lib/ISO_32000/Media_player_info.pm6)
/PL|[Media_clip_data](gen/lib/ISO_32000/Media_clip_data.pm6) [Media_play_parameters](gen/lib/ISO_32000/Media_play_parameters.pm6)
/PO|[Annotation_additional_actions](gen/lib/ISO_32000/Annotation_additional_actions.pm6) [Three-D_cross_section](gen/lib/ISO_32000/Three-D_cross_section.pm6)
/PS|[Number_format](gen/lib/ISO_32000/Number_format.pm6) [Projection](gen/lib/ISO_32000/Projection.pm6)
/PV|[Annotation_additional_actions](gen/lib/ISO_32000/Annotation_additional_actions.pm6)
/PZ|[Page](gen/lib/ISO_32000/Page.pm6)
/Padding|[Standard_layout_structure_type](gen/lib/ISO_32000/Standard_layout_structure_type.pm6)
/Page|[FDF_annotation_additional](gen/lib/ISO_32000/FDF_annotation_additional.pm6) [Reference](gen/lib/ISO_32000/Reference.pm6)
/PageElement|[Optional_Content_Group_Usage](gen/lib/ISO_32000/Optional_Content_Group_Usage.pm6)
/PageLabels|[Catalog](gen/lib/ISO_32000/Catalog.pm6)
/PageLayout|[Catalog](gen/lib/ISO_32000/Catalog.pm6)
/PageMode|[Catalog](gen/lib/ISO_32000/Catalog.pm6)
/Pages|[Catalog](gen/lib/ISO_32000/Catalog.pm6) [Catalog_Name_tree](gen/lib/ISO_32000/Catalog_Name_tree.pm6) [FDF_dictionary](gen/lib/ISO_32000/FDF_dictionary.pm6) [Separation](gen/lib/ISO_32000/Separation.pm6)
/PaintType|[Type_1_Pattern](gen/lib/ISO_32000/Type_1_Pattern.pm6)
/Params|[Embedded_file_stream](gen/lib/ISO_32000/Embedded_file_stream.pm6)
/Parent|[Field_common](gen/lib/ISO_32000/Field_common.pm6) [Outline_item](gen/lib/ISO_32000/Outline_item.pm6) [Page](gen/lib/ISO_32000/Page.pm6) [Pages](gen/lib/ISO_32000/Pages.pm6) [Popup_annotation_additional](gen/lib/ISO_32000/Popup_annotation_additional.pm6) [Widget_annotation_additional](gen/lib/ISO_32000/Widget_annotation_additional.pm6)
/ParentTree|[Structure_tree_root](gen/lib/ISO_32000/Structure_tree_root.pm6)
/ParentTreeNextKey|[Structure_tree_root](gen/lib/ISO_32000/Structure_tree_root.pm6)
/Pattern|[Resource](gen/lib/ISO_32000/Resource.pm6)
/PatternType|[Type_1_Pattern](gen/lib/ISO_32000/Type_1_Pattern.pm6) [Type_2_Pattern](gen/lib/ISO_32000/Type_2_Pattern.pm6)
/Perms|[Catalog](gen/lib/ISO_32000/Catalog.pm6)
/Pg|[Marked_content_reference](gen/lib/ISO_32000/Marked_content_reference.pm6) [Object_reference](gen/lib/ISO_32000/Object_reference.pm6) [Structure_tree_element](gen/lib/ISO_32000/Structure_tree_element.pm6)
/PickTrayByPDFSize|[Viewer_preferences](gen/lib/ISO_32000/Viewer_preferences.pm6)
/PieceInfo|[Catalog](gen/lib/ISO_32000/Catalog.pm6) [Page](gen/lib/ISO_32000/Page.pm6) [Type_1_Form](gen/lib/ISO_32000/Type_1_Form.pm6)
/Placement|[Standard_layout_structure_type](gen/lib/ISO_32000/Standard_layout_structure_type.pm6)
/Popup|[Annotation_markup_additional](gen/lib/ISO_32000/Annotation_markup_additional.pm6)
/Position|[OPI_version_1_3](gen/lib/ISO_32000/OPI_version_1_3.pm6)
/Poster|[Movie](gen/lib/ISO_32000/Movie.pm6)
/Predictor|[LZW_and_Flate_filter](gen/lib/ISO_32000/LZW_and_Flate_filter.pm6)
/PresSteps|[Page](gen/lib/ISO_32000/Page.pm6)
/PreserveRB|[Set-OCG-state_action_additional](gen/lib/ISO_32000/Set-OCG-state_action_additional.pm6)
/Prev|[Cross_reference_stream](gen/lib/ISO_32000/Cross_reference_stream.pm6) [File_trailer](gen/lib/ISO_32000/File_trailer.pm6) [Navigation_node](gen/lib/ISO_32000/Navigation_node.pm6) [Outline_item](gen/lib/ISO_32000/Outline_item.pm6)
/Print|[Optional_Content_Group_Usage](gen/lib/ISO_32000/Optional_Content_Group_Usage.pm6)
/PrintArea|[Viewer_preferences](gen/lib/ISO_32000/Viewer_preferences.pm6)
/PrintClip|[Viewer_preferences](gen/lib/ISO_32000/Viewer_preferences.pm6)
/PrintPageRange|[Viewer_preferences](gen/lib/ISO_32000/Viewer_preferences.pm6)
/PrintScaling|[Viewer_preferences](gen/lib/ISO_32000/Viewer_preferences.pm6)
/PrintingOrder|[DeviceN_mixing_hints](gen/lib/ISO_32000/DeviceN_mixing_hints.pm6)
/Private|[Data](gen/lib/ISO_32000/Data.pm6)
/ProcSet|[Resource](gen/lib/ISO_32000/Resource.pm6)
/Process|[DeviceN_colour_space](gen/lib/ISO_32000/DeviceN_colour_space.pm6)
/Producer|[Info](gen/lib/ISO_32000/Info.pm6)
/Prop_AuthTime|[Signature](gen/lib/ISO_32000/Signature.pm6)
/Prop_AuthType|[Signature](gen/lib/ISO_32000/Signature.pm6)
/Prop_Build|[Signature](gen/lib/ISO_32000/Signature.pm6)
/Properties|[Resource](gen/lib/ISO_32000/Resource.pm6)
/Q|[Free_text_annotation_additional](gen/lib/ISO_32000/Free_text_annotation_additional.pm6) [Interactive_form](gen/lib/ISO_32000/Interactive_form.pm6) [Redaction_annotation_additional](gen/lib/ISO_32000/Redaction_annotation_additional.pm6) [Variable_text_field](gen/lib/ISO_32000/Variable_text_field.pm6)
/QuadPoints|[Link_annotation_additional](gen/lib/ISO_32000/Link_annotation_additional.pm6) [Redaction_annotation_additional](gen/lib/ISO_32000/Redaction_annotation_additional.pm6) [Text_markup_annotation_additional](gen/lib/ISO_32000/Text_markup_annotation_additional.pm6)
/R|[Additional_encryption](gen/lib/ISO_32000/Additional_encryption.pm6) [Appearance](gen/lib/ISO_32000/Appearance.pm6) [Appearance_characteristics](gen/lib/ISO_32000/Appearance_characteristics.pm6) [Bead](gen/lib/ISO_32000/Bead.pm6) [Floating_window_parameter](gen/lib/ISO_32000/Floating_window_parameter.pm6) [Rectilinear_measure_additional](gen/lib/ISO_32000/Rectilinear_measure_additional.pm6) [Rendition_action_additional](gen/lib/ISO_32000/Rendition_action_additional.pm6) [Rendition_criteria](gen/lib/ISO_32000/Rendition_criteria.pm6) [Selector_rendition](gen/lib/ISO_32000/Selector_rendition.pm6) [Signature](gen/lib/ISO_32000/Signature.pm6) [Sound_object](gen/lib/ISO_32000/Sound_object.pm6) [Structure_tree_element](gen/lib/ISO_32000/Structure_tree_element.pm6) [Target](gen/lib/ISO_32000/Target.pm6) [Web_Capture_image_set](gen/lib/ISO_32000/Web_Capture_image_set.pm6)
/RBGroups|[Optional_Content_Configuration](gen/lib/ISO_32000/Optional_Content_Configuration.pm6)
/RC|[Annotation_markup_additional](gen/lib/ISO_32000/Annotation_markup_additional.pm6) [Appearance_characteristics](gen/lib/ISO_32000/Appearance_characteristics.pm6) [Free_text_annotation_additional](gen/lib/ISO_32000/Free_text_annotation_additional.pm6)
/RD|[Caret_annotation_additional](gen/lib/ISO_32000/Caret_annotation_additional.pm6) [Free_text_annotation_additional](gen/lib/ISO_32000/Free_text_annotation_additional.pm6) [Number_format](gen/lib/ISO_32000/Number_format.pm6) [Square_or_circle_annotation_additional](gen/lib/ISO_32000/Square_or_circle_annotation_additional.pm6)
/RF|[File_specification](gen/lib/ISO_32000/File_specification.pm6)
/RH|[Requirement_common](gen/lib/ISO_32000/Requirement_common.pm6)
/RI|[Appearance_characteristics](gen/lib/ISO_32000/Appearance_characteristics.pm6) [Graphics_state](gen/lib/ISO_32000/Graphics_state.pm6)
/RM|[Three-D_view](gen/lib/ISO_32000/Three-D_view.pm6)
/RO|[Redaction_annotation_additional](gen/lib/ISO_32000/Redaction_annotation_additional.pm6)
/RT|[Annotation_markup_additional](gen/lib/ISO_32000/Annotation_markup_additional.pm6) [Floating_window_parameter](gen/lib/ISO_32000/Floating_window_parameter.pm6) [Number_format](gen/lib/ISO_32000/Number_format.pm6)
/RV|[FDF_field](gen/lib/ISO_32000/FDF_field.pm6) [Variable_text_field](gen/lib/ISO_32000/Variable_text_field.pm6)
/Range|[Function_common](gen/lib/ISO_32000/Function_common.pm6) [ICC_profile](gen/lib/ISO_32000/ICC_profile.pm6) [Lab_colour_space](gen/lib/ISO_32000/Lab_colour_space.pm6)
/Rate|[Movie_activation](gen/lib/ISO_32000/Movie_activation.pm6)
/Reason|[Signature](gen/lib/ISO_32000/Signature.pm6)
/Reasons|[Signature_field_seed_value](gen/lib/ISO_32000/Signature_field_seed_value.pm6)
/Recipients|[Crypt_filter_public-key_additional](gen/lib/ISO_32000/Crypt_filter_public-key_additional.pm6) [Public_key_security_handler_additional](gen/lib/ISO_32000/Public_key_security_handler_additional.pm6)
/Rect|[Annotation_common](gen/lib/ISO_32000/Annotation_common.pm6)
/Ref|[Type_1_Form](gen/lib/ISO_32000/Type_1_Form.pm6)
/Reference|[Signature](gen/lib/ISO_32000/Signature.pm6)
/Registry|[CIDSystemInfo](gen/lib/ISO_32000/CIDSystemInfo.pm6)
/RegistryName|[Output_intent](gen/lib/ISO_32000/Output_intent.pm6)
/Rename|[FDF_template](gen/lib/ISO_32000/FDF_template.pm6)
/Renditions|[Catalog_Name_tree](gen/lib/ISO_32000/Catalog_Name_tree.pm6)
/Repeat|[Redaction_annotation_additional](gen/lib/ISO_32000/Redaction_annotation_additional.pm6) [Sound_action_additional](gen/lib/ISO_32000/Sound_action_additional.pm6)
/Requirements|[Catalog](gen/lib/ISO_32000/Catalog.pm6)
/ResFork|[MacOS_file_information](gen/lib/ISO_32000/MacOS_file_information.pm6)
/Resolution|[OPI_version_1_3](gen/lib/ISO_32000/OPI_version_1_3.pm6)
/Resources|[Page](gen/lib/ISO_32000/Page.pm6) [Slideshow](gen/lib/ISO_32000/Slideshow.pm6) [Three-D_stream](gen/lib/ISO_32000/Three-D_stream.pm6) [Type_1_Form](gen/lib/ISO_32000/Type_1_Form.pm6) [Type_1_Pattern](gen/lib/ISO_32000/Type_1_Pattern.pm6) [Type_3_Font](gen/lib/ISO_32000/Type_3_Font.pm6)
/Role|[PrintField](gen/lib/ISO_32000/PrintField.pm6)
/RoleMap|[Structure_tree_root](gen/lib/ISO_32000/Structure_tree_root.pm6)
/Root|[FDF_trailer](gen/lib/ISO_32000/FDF_trailer.pm6) [File_trailer](gen/lib/ISO_32000/File_trailer.pm6)
/Rotate|[Movie](gen/lib/ISO_32000/Movie.pm6) [Page](gen/lib/ISO_32000/Page.pm6)
/RowSpan|[Standard_table](gen/lib/ISO_32000/Standard_table.pm6)
/Rows|[CCITTFax_filter](gen/lib/ISO_32000/CCITTFax_filter.pm6)
/RubyAlign|[Standard_inline-level_structure_element](gen/lib/ISO_32000/Standard_inline-level_structure_element.pm6)
/RubyPosition|[Standard_inline-level_structure_element](gen/lib/ISO_32000/Standard_inline-level_structure_element.pm6)
/S|[Action_common](gen/lib/ISO_32000/Action_common.pm6) [Border_effect](gen/lib/ISO_32000/Border_effect.pm6) [Border_style](gen/lib/ISO_32000/Border_style.pm6) [Box_style](gen/lib/ISO_32000/Box_style.pm6) [Collection_sort](gen/lib/ISO_32000/Collection_sort.pm6) [Embedded_goto_action_additional](gen/lib/ISO_32000/Embedded_goto_action_additional.pm6) [Goto_3D_view_action_additional](gen/lib/ISO_32000/Goto_3D_view_action_additional.pm6) [Goto_action_additional](gen/lib/ISO_32000/Goto_action_additional.pm6) [Group_Attributes_common](gen/lib/ISO_32000/Group_Attributes_common.pm6) [Hide_action_additional](gen/lib/ISO_32000/Hide_action_additional.pm6) [Icon_fit](gen/lib/ISO_32000/Icon_fit.pm6) [Import-data_action_additional](gen/lib/ISO_32000/Import-data_action_additional.pm6) [JavaScript_action_additional](gen/lib/ISO_32000/JavaScript_action_additional.pm6) [Launch_action_additional](gen/lib/ISO_32000/Launch_action_additional.pm6) [Media_clip_common](gen/lib/ISO_32000/Media_clip_common.pm6) [Media_duration](gen/lib/ISO_32000/Media_duration.pm6) [Media_offset_common](gen/lib/ISO_32000/Media_offset_common.pm6) [Movie_action_additional](gen/lib/ISO_32000/Movie_action_additional.pm6) [Named_action_additional](gen/lib/ISO_32000/Named_action_additional.pm6) [Output_intent](gen/lib/ISO_32000/Output_intent.pm6) [Page_label](gen/lib/ISO_32000/Page_label.pm6) [Rectilinear_measure_additional](gen/lib/ISO_32000/Rectilinear_measure_additional.pm6) [Remote_goto_action_additional](gen/lib/ISO_32000/Remote_goto_action_additional.pm6) [Rendition_action_additional](gen/lib/ISO_32000/Rendition_action_additional.pm6) [Rendition_common](gen/lib/ISO_32000/Rendition_common.pm6) [Rendition_criteria](gen/lib/ISO_32000/Rendition_criteria.pm6) [Requirement_common](gen/lib/ISO_32000/Requirement_common.pm6) [Requirement_handler](gen/lib/ISO_32000/Requirement_handler.pm6) [Reset_form_action](gen/lib/ISO_32000/Reset_form_action.pm6) [Set-OCG-state_action_additional](gen/lib/ISO_32000/Set-OCG-state_action_additional.pm6) [Soft-mask](gen/lib/ISO_32000/Soft-mask.pm6) [Sound_action_additional](gen/lib/ISO_32000/Sound_action_additional.pm6) [Source_information](gen/lib/ISO_32000/Source_information.pm6) [Structure_tree_element](gen/lib/ISO_32000/Structure_tree_element.pm6) [Submit_form_action](gen/lib/ISO_32000/Submit_form_action.pm6) [Thread_action_additional](gen/lib/ISO_32000/Thread_action_additional.pm6) [Timespan](gen/lib/ISO_32000/Timespan.pm6) [Transition](gen/lib/ISO_32000/Transition.pm6) [Transition_action_additional](gen/lib/ISO_32000/Transition_action_additional.pm6) [Transparency_group_additional](gen/lib/ISO_32000/Transparency_group_additional.pm6) [URI_action_additional](gen/lib/ISO_32000/URI_action_additional.pm6) [Web_Capture_content_sets](gen/lib/ISO_32000/Web_Capture_content_sets.pm6) [Web_Capture_image_set](gen/lib/ISO_32000/Web_Capture_image_set.pm6) [Web_Capture_page_set_additional](gen/lib/ISO_32000/Web_Capture_page_set_additional.pm6) [Web_capture_command](gen/lib/ISO_32000/Web_capture_command.pm6)
/SA|[Graphics_state](gen/lib/ISO_32000/Graphics_state.pm6) [Three-D_view](gen/lib/ISO_32000/Three-D_view.pm6)
/SE|[Outline_item](gen/lib/ISO_32000/Outline_item.pm6)
/SI|[Web_Capture_content_sets](gen/lib/ISO_32000/Web_Capture_content_sets.pm6)
/SM|[Graphics_state](gen/lib/ISO_32000/Graphics_state.pm6)
/SMask|[Graphics_state](gen/lib/ISO_32000/Graphics_state.pm6) [Image](gen/lib/ISO_32000/Image.pm6)
/SMaskInData|[Image](gen/lib/ISO_32000/Image.pm6)
/SP|[Media_rendition](gen/lib/ISO_32000/Media_rendition.pm6)
/SS|[Number_format](gen/lib/ISO_32000/Number_format.pm6) [Transition](gen/lib/ISO_32000/Transition.pm6)
/SV|[Signature_field](gen/lib/ISO_32000/Signature_field.pm6)
/SW|[Icon_fit](gen/lib/ISO_32000/Icon_fit.pm6)
/Schema|[Collection](gen/lib/ISO_32000/Collection.pm6)
/Scope|[Standard_table](gen/lib/ISO_32000/Standard_table.pm6)
/Script|[Requirement_handler](gen/lib/ISO_32000/Requirement_handler.pm6)
/SeparationColorNames|[Trap_network_appearance_stream](gen/lib/ISO_32000/Trap_network_appearance_stream.pm6)
/SeparationInfo|[Page](gen/lib/ISO_32000/Page.pm6)
/SetF|[FDF_field](gen/lib/ISO_32000/FDF_field.pm6)
/SetFf|[FDF_field](gen/lib/ISO_32000/FDF_field.pm6)
/Shading|[Resource](gen/lib/ISO_32000/Resource.pm6) [Type_2_Pattern](gen/lib/ISO_32000/Type_2_Pattern.pm6)
/ShadingType|[Shading_common](gen/lib/ISO_32000/Shading_common.pm6)
/ShowControls|[Movie_activation](gen/lib/ISO_32000/Movie_activation.pm6)
/SigFlags|[Interactive_form](gen/lib/ISO_32000/Interactive_form.pm6)
/Signature|[UR_transform](gen/lib/ISO_32000/UR_transform.pm6)
/Size|[Cross_reference_stream](gen/lib/ISO_32000/Cross_reference_stream.pm6) [Embedded_file_parameter](gen/lib/ISO_32000/Embedded_file_parameter.pm6) [File_trailer](gen/lib/ISO_32000/File_trailer.pm6) [OPI_version_1_3](gen/lib/ISO_32000/OPI_version_1_3.pm6) [OPI_version_2_0](gen/lib/ISO_32000/OPI_version_2_0.pm6) [Type_0_Function](gen/lib/ISO_32000/Type_0_Function.pm6)
/Solidities|[DeviceN_mixing_hints](gen/lib/ISO_32000/DeviceN_mixing_hints.pm6)
/Sort|[Collection](gen/lib/ISO_32000/Collection.pm6)
/Sound|[Sound_action_additional](gen/lib/ISO_32000/Sound_action_additional.pm6) [Sound_annotation_additional](gen/lib/ISO_32000/Sound_annotation_additional.pm6)
/SoundActions|[Legal_attestation](gen/lib/ISO_32000/Legal_attestation.pm6)
/SpaceAfter|[Standard_layout_block-level_structure_element](gen/lib/ISO_32000/Standard_layout_block-level_structure_element.pm6)
/SpaceBefore|[Standard_layout_block-level_structure_element](gen/lib/ISO_32000/Standard_layout_block-level_structure_element.pm6)
/SpiderInfo|[Catalog](gen/lib/ISO_32000/Catalog.pm6)
/SpotFunction|[Type_1_halftone](gen/lib/ISO_32000/Type_1_halftone.pm6)
/St|[Page_label](gen/lib/ISO_32000/Page_label.pm6)
/Start|[Movie_activation](gen/lib/ISO_32000/Movie_activation.pm6)
/StartIndent|[Standard_layout_block-level_structure_element](gen/lib/ISO_32000/Standard_layout_block-level_structure_element.pm6)
/StartResource|[Slideshow](gen/lib/ISO_32000/Slideshow.pm6)
/State|[Set-OCG-state_action_additional](gen/lib/ISO_32000/Set-OCG-state_action_additional.pm6) [Text_annotation_additional](gen/lib/ISO_32000/Text_annotation_additional.pm6)
/StateModel|[Text_annotation_additional](gen/lib/ISO_32000/Text_annotation_additional.pm6)
/Status|[FDF_dictionary](gen/lib/ISO_32000/FDF_dictionary.pm6)
/StemH|[Font_descriptor_common](gen/lib/ISO_32000/Font_descriptor_common.pm6)
/StemV|[Font_descriptor_common](gen/lib/ISO_32000/Font_descriptor_common.pm6)
/Stm|[Marked_content_reference](gen/lib/ISO_32000/Marked_content_reference.pm6)
/StmF|[Encryption_common](gen/lib/ISO_32000/Encryption_common.pm6)
/StmOwn|[Marked_content_reference](gen/lib/ISO_32000/Marked_content_reference.pm6)
/StrF|[Encryption_common](gen/lib/ISO_32000/Encryption_common.pm6)
/StructParent|[Annotation_common](gen/lib/ISO_32000/Annotation_common.pm6) [Image](gen/lib/ISO_32000/Image.pm6) [Structure_element_access_additional](gen/lib/ISO_32000/Structure_element_access_additional.pm6) [Type_1_Form](gen/lib/ISO_32000/Type_1_Form.pm6)
/StructParents|[Page](gen/lib/ISO_32000/Page.pm6) [Structure_element_access_additional](gen/lib/ISO_32000/Structure_element_access_additional.pm6) [Type_1_Form](gen/lib/ISO_32000/Type_1_Form.pm6)
/StructTreeRoot|[Catalog](gen/lib/ISO_32000/Catalog.pm6)
/Style|[CIDFont_descriptor_additional](gen/lib/ISO_32000/CIDFont_descriptor_additional.pm6)
/SubFilter|[Encryption_common](gen/lib/ISO_32000/Encryption_common.pm6) [Signature](gen/lib/ISO_32000/Signature.pm6) [Signature_field_seed_value](gen/lib/ISO_32000/Signature_field_seed_value.pm6)
/Subj|[Annotation_markup_additional](gen/lib/ISO_32000/Annotation_markup_additional.pm6)
/Subject|[Certificate_seed_value](gen/lib/ISO_32000/Certificate_seed_value.pm6) [Info](gen/lib/ISO_32000/Info.pm6)
/SubjectDN|[Certificate_seed_value](gen/lib/ISO_32000/Certificate_seed_value.pm6)
/Subtype|[Annotation_common](gen/lib/ISO_32000/Annotation_common.pm6) [Artifact](gen/lib/ISO_32000/Artifact.pm6) [CIDFont](gen/lib/ISO_32000/CIDFont.pm6) [Caret_annotation_additional](gen/lib/ISO_32000/Caret_annotation_additional.pm6) [Collection_field](gen/lib/ISO_32000/Collection_field.pm6) [DeviceN_colour_space](gen/lib/ISO_32000/DeviceN_colour_space.pm6) [Embedded_file_stream](gen/lib/ISO_32000/Embedded_file_stream.pm6) [Embedded_font_stream_additional](gen/lib/ISO_32000/Embedded_font_stream_additional.pm6) [File_attachment_annotation_additional](gen/lib/ISO_32000/File_attachment_annotation_additional.pm6) [Free_text_annotation_additional](gen/lib/ISO_32000/Free_text_annotation_additional.pm6) [Image](gen/lib/ISO_32000/Image.pm6) [Ink_annotation_additional](gen/lib/ISO_32000/Ink_annotation_additional.pm6) [Line_annotation_additional](gen/lib/ISO_32000/Line_annotation_additional.pm6) [Link_annotation_additional](gen/lib/ISO_32000/Link_annotation_additional.pm6) [MacOS_file_information](gen/lib/ISO_32000/MacOS_file_information.pm6) [Measure](gen/lib/ISO_32000/Measure.pm6) [Metadata_stream_additional](gen/lib/ISO_32000/Metadata_stream_additional.pm6) [Movie_annotation_additional](gen/lib/ISO_32000/Movie_annotation_additional.pm6) [Polygon_or_polyline_annotation_additional](gen/lib/ISO_32000/Polygon_or_polyline_annotation_additional.pm6) [Popup_annotation_additional](gen/lib/ISO_32000/Popup_annotation_additional.pm6) [Postscript_XObject](gen/lib/ISO_32000/Postscript_XObject.pm6) [Printers_mark_annotation](gen/lib/ISO_32000/Printers_mark_annotation.pm6) [Projection](gen/lib/ISO_32000/Projection.pm6) [Redaction_annotation_additional](gen/lib/ISO_32000/Redaction_annotation_additional.pm6) [Render_mode](gen/lib/ISO_32000/Render_mode.pm6) [Rubber_stamp_annotation_additional](gen/lib/ISO_32000/Rubber_stamp_annotation_additional.pm6) [Screen_annotation_additional](gen/lib/ISO_32000/Screen_annotation_additional.pm6) [Slideshow](gen/lib/ISO_32000/Slideshow.pm6) [Sound_annotation_additional](gen/lib/ISO_32000/Sound_annotation_additional.pm6) [Square_or_circle_annotation_additional](gen/lib/ISO_32000/Square_or_circle_annotation_additional.pm6) [Text_annotation_additional](gen/lib/ISO_32000/Text_annotation_additional.pm6) [Text_markup_annotation_additional](gen/lib/ISO_32000/Text_markup_annotation_additional.pm6) [Three-D_animation_style](gen/lib/ISO_32000/Three-D_animation_style.pm6) [Three-D_annotation](gen/lib/ISO_32000/Three-D_annotation.pm6) [Three-D_background](gen/lib/ISO_32000/Three-D_background.pm6) [Three-D_external_data](gen/lib/ISO_32000/Three-D_external_data.pm6) [Three-D_lighting](gen/lib/ISO_32000/Three-D_lighting.pm6) [Three-D_stream](gen/lib/ISO_32000/Three-D_stream.pm6) [Trap_network_annotation](gen/lib/ISO_32000/Trap_network_annotation.pm6) [Type_0_Font](gen/lib/ISO_32000/Type_0_Font.pm6) [Type_1_Font](gen/lib/ISO_32000/Type_1_Font.pm6) [Type_1_Form](gen/lib/ISO_32000/Type_1_Form.pm6) [Type_3_Font](gen/lib/ISO_32000/Type_3_Font.pm6) [Watermark_annotation_additional](gen/lib/ISO_32000/Watermark_annotation_additional.pm6) [Widget_annotation_additional](gen/lib/ISO_32000/Widget_annotation_additional.pm6)
/Summary|[Standard_table](gen/lib/ISO_32000/Standard_table.pm6)
/Supplement|[CIDSystemInfo](gen/lib/ISO_32000/CIDSystemInfo.pm6)
/Suspects|[Mark_information](gen/lib/ISO_32000/Mark_information.pm6)
/Sy|[Caret_annotation_additional](gen/lib/ISO_32000/Caret_annotation_additional.pm6)
/Synchronous|[Movie_activation](gen/lib/ISO_32000/Movie_activation.pm6) [Sound_action_additional](gen/lib/ISO_32000/Sound_action_additional.pm6)
/T|[Annotation_markup_additional](gen/lib/ISO_32000/Annotation_markup_additional.pm6) [Bead](gen/lib/ISO_32000/Bead.pm6) [Embedded_goto_action_additional](gen/lib/ISO_32000/Embedded_goto_action_additional.pm6) [FDF_field](gen/lib/ISO_32000/FDF_field.pm6) [Field_common](gen/lib/ISO_32000/Field_common.pm6) [Floating_window_parameter](gen/lib/ISO_32000/Floating_window_parameter.pm6) [Hide_action_additional](gen/lib/ISO_32000/Hide_action_additional.pm6) [Linearization_parameter](gen/lib/ISO_32000/Linearization_parameter.pm6) [Media_duration](gen/lib/ISO_32000/Media_duration.pm6) [Media_offset_time](gen/lib/ISO_32000/Media_offset_time.pm6) [Movie_action_additional](gen/lib/ISO_32000/Movie_action_additional.pm6) [Movie_annotation_additional](gen/lib/ISO_32000/Movie_annotation_additional.pm6) [Rectilinear_measure_additional](gen/lib/ISO_32000/Rectilinear_measure_additional.pm6) [Screen_annotation_additional](gen/lib/ISO_32000/Screen_annotation_additional.pm6) [Structure_tree_element](gen/lib/ISO_32000/Structure_tree_element.pm6) [Target](gen/lib/ISO_32000/Target.pm6) [Web_Capture_page_set_additional](gen/lib/ISO_32000/Web_Capture_page_set_additional.pm6)
/TA|[Goto_3D_view_action_additional](gen/lib/ISO_32000/Goto_3D_view_action_additional.pm6)
/TB|[Three-D_activation](gen/lib/ISO_32000/Three-D_activation.pm6)
/TBorderStyle|[Standard_layout_block-level_structure_element](gen/lib/ISO_32000/Standard_layout_block-level_structure_element.pm6)
/TF|[Media_permissions](gen/lib/ISO_32000/Media_permissions.pm6)
/TI|[Choice_field_additional](gen/lib/ISO_32000/Choice_field_additional.pm6)
/TID|[Web_Capture_page_set_additional](gen/lib/ISO_32000/Web_Capture_page_set_additional.pm6)
/TK|[Graphics_state](gen/lib/ISO_32000/Graphics_state.pm6)
/TM|[Field_common](gen/lib/ISO_32000/Field_common.pm6) [Three-D_animation_style](gen/lib/ISO_32000/Three-D_animation_style.pm6)
/TP|[Appearance_characteristics](gen/lib/ISO_32000/Appearance_characteristics.pm6)
/TPadding|[Standard_layout_block-level_structure_element](gen/lib/ISO_32000/Standard_layout_block-level_structure_element.pm6)
/TR|[Graphics_state](gen/lib/ISO_32000/Graphics_state.pm6) [Soft-mask](gen/lib/ISO_32000/Soft-mask.pm6)
/TR2|[Graphics_state](gen/lib/ISO_32000/Graphics_state.pm6)
/TRef|[FDF_template](gen/lib/ISO_32000/FDF_template.pm6)
/TS|[Source_information](gen/lib/ISO_32000/Source_information.pm6) [Web_Capture_content_sets](gen/lib/ISO_32000/Web_Capture_content_sets.pm6)
/TT|[Floating_window_parameter](gen/lib/ISO_32000/Floating_window_parameter.pm6)
/TU|[Field_common](gen/lib/ISO_32000/Field_common.pm6)
/Tabs|[Page](gen/lib/ISO_32000/Page.pm6)
/Tags|[OPI_version_1_3](gen/lib/ISO_32000/OPI_version_1_3.pm6) [OPI_version_2_0](gen/lib/ISO_32000/OPI_version_2_0.pm6)
/Target|[FDF_dictionary](gen/lib/ISO_32000/FDF_dictionary.pm6)
/TemplateInstantiated|[Page](gen/lib/ISO_32000/Page.pm6)
/Templates|[Catalog_Name_tree](gen/lib/ISO_32000/Catalog_Name_tree.pm6) [FDF_page](gen/lib/ISO_32000/FDF_page.pm6)
/TextAlign|[Standard_layout_block-level_structure_element](gen/lib/ISO_32000/Standard_layout_block-level_structure_element.pm6)
/TextDecorationColor|[Standard_inline-level_structure_element](gen/lib/ISO_32000/Standard_inline-level_structure_element.pm6)
/TextDecorationThickness|[Standard_inline-level_structure_element](gen/lib/ISO_32000/Standard_inline-level_structure_element.pm6)
/TextDecorationType|[Standard_inline-level_structure_element](gen/lib/ISO_32000/Standard_inline-level_structure_element.pm6)
/TextIndent|[Standard_layout_block-level_structure_element](gen/lib/ISO_32000/Standard_layout_block-level_structure_element.pm6)
/Threads|[Catalog](gen/lib/ISO_32000/Catalog.pm6)
/Thumb|[Page](gen/lib/ISO_32000/Page.pm6)
/TilingType|[Type_1_Pattern](gen/lib/ISO_32000/Type_1_Pattern.pm6)
/TimeStamp|[Signature_field_seed_value](gen/lib/ISO_32000/Signature_field_seed_value.pm6)
/Tint|[OPI_version_1_3](gen/lib/ISO_32000/OPI_version_1_3.pm6)
/Title|[Info](gen/lib/ISO_32000/Info.pm6) [Outline_item](gen/lib/ISO_32000/Outline_item.pm6)
/ToUnicode|[Type_0_Font](gen/lib/ISO_32000/Type_0_Font.pm6) [Type_1_Font](gen/lib/ISO_32000/Type_1_Font.pm6) [Type_3_Font](gen/lib/ISO_32000/Type_3_Font.pm6)
/Trans|[Page](gen/lib/ISO_32000/Page.pm6) [Transition_action_additional](gen/lib/ISO_32000/Transition_action_additional.pm6)
/TransferFunction|[Type_10_halftone](gen/lib/ISO_32000/Type_10_halftone.pm6) [Type_16_halftone](gen/lib/ISO_32000/Type_16_halftone.pm6) [Type_1_halftone](gen/lib/ISO_32000/Type_1_halftone.pm6) [Type_6_halftone](gen/lib/ISO_32000/Type_6_halftone.pm6)
/TransformMethod|[Signature_reference](gen/lib/ISO_32000/Signature_reference.pm6)
/TransformParams|[Signature_reference](gen/lib/ISO_32000/Signature_reference.pm6)
/Transparency|[OPI_version_1_3](gen/lib/ISO_32000/OPI_version_1_3.pm6)
/TrapRegions|[Trap_network_appearance_stream](gen/lib/ISO_32000/Trap_network_appearance_stream.pm6)
/TrapStyles|[Trap_network_appearance_stream](gen/lib/ISO_32000/Trap_network_appearance_stream.pm6)
/Trapped|[Info](gen/lib/ISO_32000/Info.pm6)
/TrimBox|[Box_colour_information](gen/lib/ISO_32000/Box_colour_information.pm6) [Page](gen/lib/ISO_32000/Page.pm6)
/TrueTypeFonts|[Legal_attestation](gen/lib/ISO_32000/Legal_attestation.pm6)
/Type|[Action_common](gen/lib/ISO_32000/Action_common.pm6) [Annotation_common](gen/lib/ISO_32000/Annotation_common.pm6) [Artifact](gen/lib/ISO_32000/Artifact.pm6) [Bead](gen/lib/ISO_32000/Bead.pm6) [Border_style](gen/lib/ISO_32000/Border_style.pm6) [CIDFont](gen/lib/ISO_32000/CIDFont.pm6) [CMap_stream](gen/lib/ISO_32000/CMap_stream.pm6) [Catalog](gen/lib/ISO_32000/Catalog.pm6) [Certificate_seed_value](gen/lib/ISO_32000/Certificate_seed_value.pm6) [Collection](gen/lib/ISO_32000/Collection.pm6) [Collection_field](gen/lib/ISO_32000/Collection_field.pm6) [Collection_item](gen/lib/ISO_32000/Collection_item.pm6) [Collection_schema](gen/lib/ISO_32000/Collection_schema.pm6) [Collection_sort](gen/lib/ISO_32000/Collection_sort.pm6) [Collection_subitem](gen/lib/ISO_32000/Collection_subitem.pm6) [Cross_reference_stream](gen/lib/ISO_32000/Cross_reference_stream.pm6) [Crypt_filter](gen/lib/ISO_32000/Crypt_filter.pm6) [Crypt_filter_common](gen/lib/ISO_32000/Crypt_filter_common.pm6) [Developer_extensions](gen/lib/ISO_32000/Developer_extensions.pm6) [DocMDP_transform](gen/lib/ISO_32000/DocMDP_transform.pm6) [Embedded_file_stream](gen/lib/ISO_32000/Embedded_file_stream.pm6) [Encoding](gen/lib/ISO_32000/Encoding.pm6) [FieldMDP_transform](gen/lib/ISO_32000/FieldMDP_transform.pm6) [File_specification](gen/lib/ISO_32000/File_specification.pm6) [Fixed_print](gen/lib/ISO_32000/Fixed_print.pm6) [Floating_window_parameter](gen/lib/ISO_32000/Floating_window_parameter.pm6) [Font_descriptor_common](gen/lib/ISO_32000/Font_descriptor_common.pm6) [Graphics_state](gen/lib/ISO_32000/Graphics_state.pm6) [Group_Attributes_common](gen/lib/ISO_32000/Group_Attributes_common.pm6) [Image](gen/lib/ISO_32000/Image.pm6) [Marked_content_reference](gen/lib/ISO_32000/Marked_content_reference.pm6) [Measure](gen/lib/ISO_32000/Measure.pm6) [Media_clip_common](gen/lib/ISO_32000/Media_clip_common.pm6) [Media_duration](gen/lib/ISO_32000/Media_duration.pm6) [Media_offset_common](gen/lib/ISO_32000/Media_offset_common.pm6) [Media_permissions](gen/lib/ISO_32000/Media_permissions.pm6) [Media_play_parameters](gen/lib/ISO_32000/Media_play_parameters.pm6) [Media_player_info](gen/lib/ISO_32000/Media_player_info.pm6) [Media_players](gen/lib/ISO_32000/Media_players.pm6) [Media_screen_parameters](gen/lib/ISO_32000/Media_screen_parameters.pm6) [Metadata_stream_additional](gen/lib/ISO_32000/Metadata_stream_additional.pm6) [Minimum_bit_depth](gen/lib/ISO_32000/Minimum_bit_depth.pm6) [Minimum_screen_size](gen/lib/ISO_32000/Minimum_screen_size.pm6) [Navigation_node](gen/lib/ISO_32000/Navigation_node.pm6) [Number_format](gen/lib/ISO_32000/Number_format.pm6) [OPI_version_1_3](gen/lib/ISO_32000/OPI_version_1_3.pm6) [OPI_version_2_0](gen/lib/ISO_32000/OPI_version_2_0.pm6) [Object_reference](gen/lib/ISO_32000/Object_reference.pm6) [Object_stream](gen/lib/ISO_32000/Object_stream.pm6) [Optional_Content_Group](gen/lib/ISO_32000/Optional_Content_Group.pm6) [Optional_Content_Group_Membership](gen/lib/ISO_32000/Optional_Content_Group_Membership.pm6) [Outline](gen/lib/ISO_32000/Outline.pm6) [Output_intent](gen/lib/ISO_32000/Output_intent.pm6) [Page](gen/lib/ISO_32000/Page.pm6) [Page_label](gen/lib/ISO_32000/Page_label.pm6) [Pages](gen/lib/ISO_32000/Pages.pm6) [Postscript_XObject](gen/lib/ISO_32000/Postscript_XObject.pm6) [Render_mode](gen/lib/ISO_32000/Render_mode.pm6) [Rendition_common](gen/lib/ISO_32000/Rendition_common.pm6) [Rendition_criteria](gen/lib/ISO_32000/Rendition_criteria.pm6) [Requirement_common](gen/lib/ISO_32000/Requirement_common.pm6) [Requirement_handler](gen/lib/ISO_32000/Requirement_handler.pm6) [Signature](gen/lib/ISO_32000/Signature.pm6) [Signature_field_lock](gen/lib/ISO_32000/Signature_field_lock.pm6) [Signature_field_seed_value](gen/lib/ISO_32000/Signature_field_seed_value.pm6) [Signature_reference](gen/lib/ISO_32000/Signature_reference.pm6) [Slideshow](gen/lib/ISO_32000/Slideshow.pm6) [Soft-mask](gen/lib/ISO_32000/Soft-mask.pm6) [Software_identifier](gen/lib/ISO_32000/Software_identifier.pm6) [Sound_object](gen/lib/ISO_32000/Sound_object.pm6) [Structure_tree_element](gen/lib/ISO_32000/Structure_tree_element.pm6) [Structure_tree_root](gen/lib/ISO_32000/Structure_tree_root.pm6) [Thread](gen/lib/ISO_32000/Thread.pm6) [Three-D_animation_style](gen/lib/ISO_32000/Three-D_animation_style.pm6) [Three-D_background](gen/lib/ISO_32000/Three-D_background.pm6) [Three-D_cross_section](gen/lib/ISO_32000/Three-D_cross_section.pm6) [Three-D_external_data](gen/lib/ISO_32000/Three-D_external_data.pm6) [Three-D_lighting](gen/lib/ISO_32000/Three-D_lighting.pm6) [Three-D_node](gen/lib/ISO_32000/Three-D_node.pm6) [Three-D_reference](gen/lib/ISO_32000/Three-D_reference.pm6) [Three-D_stream](gen/lib/ISO_32000/Three-D_stream.pm6) [Three-D_view](gen/lib/ISO_32000/Three-D_view.pm6) [Timespan](gen/lib/ISO_32000/Timespan.pm6) [Transition](gen/lib/ISO_32000/Transition.pm6) [Type_0_Font](gen/lib/ISO_32000/Type_0_Font.pm6) [Type_10_halftone](gen/lib/ISO_32000/Type_10_halftone.pm6) [Type_16_halftone](gen/lib/ISO_32000/Type_16_halftone.pm6) [Type_1_Font](gen/lib/ISO_32000/Type_1_Font.pm6) [Type_1_Form](gen/lib/ISO_32000/Type_1_Form.pm6) [Type_1_Pattern](gen/lib/ISO_32000/Type_1_Pattern.pm6) [Type_1_halftone](gen/lib/ISO_32000/Type_1_halftone.pm6) [Type_2_Pattern](gen/lib/ISO_32000/Type_2_Pattern.pm6) [Type_3_Font](gen/lib/ISO_32000/Type_3_Font.pm6) [Type_5_halftone](gen/lib/ISO_32000/Type_5_halftone.pm6) [Type_6_halftone](gen/lib/ISO_32000/Type_6_halftone.pm6) [UR_transform](gen/lib/ISO_32000/UR_transform.pm6) [Viewport](gen/lib/ISO_32000/Viewport.pm6) [Web_Capture_content_sets](gen/lib/ISO_32000/Web_Capture_content_sets.pm6)
/U|[Additional_encryption](gen/lib/ISO_32000/Additional_encryption.pm6) [Annotation_additional_actions](gen/lib/ISO_32000/Annotation_additional_actions.pm6) [Number_format](gen/lib/ISO_32000/Number_format.pm6) [Software_identifier](gen/lib/ISO_32000/Software_identifier.pm6) [URL_alias](gen/lib/ISO_32000/URL_alias.pm6)
/U3DPath|[Three-D_view](gen/lib/ISO_32000/Three-D_view.pm6)
/UC|[Floating_window_parameter](gen/lib/ISO_32000/Floating_window_parameter.pm6)
/UCR|[Graphics_state](gen/lib/ISO_32000/Graphics_state.pm6)
/UCR2|[Graphics_state](gen/lib/ISO_32000/Graphics_state.pm6)
/UF|[File_specification](gen/lib/ISO_32000/File_specification.pm6)
/UR3|[Permissions](gen/lib/ISO_32000/Permissions.pm6)
/URI|[Catalog](gen/lib/ISO_32000/Catalog.pm6) [URI_action_additional](gen/lib/ISO_32000/URI_action_additional.pm6)
/URIActions|[Legal_attestation](gen/lib/ISO_32000/Legal_attestation.pm6)
/URL|[Certificate_seed_value](gen/lib/ISO_32000/Certificate_seed_value.pm6) [Web_capture_command](gen/lib/ISO_32000/Web_capture_command.pm6)
/URLS|[Catalog_Name_tree](gen/lib/ISO_32000/Catalog_Name_tree.pm6)
/URLType|[Certificate_seed_value](gen/lib/ISO_32000/Certificate_seed_value.pm6)
/Unix|[File_specification](gen/lib/ISO_32000/File_specification.pm6) [Launch_action_additional](gen/lib/ISO_32000/Launch_action_additional.pm6)
/Usage|[Optional_Content_Group](gen/lib/ISO_32000/Optional_Content_Group.pm6)
/UseCMap|[CMap_stream](gen/lib/ISO_32000/CMap_stream.pm6)
/User|[Optional_Content_Group_Usage](gen/lib/ISO_32000/Optional_Content_Group_Usage.pm6)
/UserProperties|[Mark_information](gen/lib/ISO_32000/Mark_information.pm6)
/UserUnit|[Page](gen/lib/ISO_32000/Page.pm6)
/V|[Bead](gen/lib/ISO_32000/Bead.pm6) [Collection_field](gen/lib/ISO_32000/Collection_field.pm6) [DocMDP_transform](gen/lib/ISO_32000/DocMDP_transform.pm6) [Encryption_common](gen/lib/ISO_32000/Encryption_common.pm6) [FDF_field](gen/lib/ISO_32000/FDF_field.pm6) [FieldMDP_transform](gen/lib/ISO_32000/FieldMDP_transform.pm6) [Field_common](gen/lib/ISO_32000/Field_common.pm6) [File_specification](gen/lib/ISO_32000/File_specification.pm6) [Fixed_print](gen/lib/ISO_32000/Fixed_print.pm6) [Form_additional_actions](gen/lib/ISO_32000/Form_additional_actions.pm6) [Goto_3D_view_action_additional](gen/lib/ISO_32000/Goto_3D_view_action_additional.pm6) [Minimum_bit_depth](gen/lib/ISO_32000/Minimum_bit_depth.pm6) [Minimum_screen_size](gen/lib/ISO_32000/Minimum_screen_size.pm6) [Rendition_criteria](gen/lib/ISO_32000/Rendition_criteria.pm6) [Signature](gen/lib/ISO_32000/Signature.pm6) [Signature_field_seed_value](gen/lib/ISO_32000/Signature_field_seed_value.pm6) [Three-D_node](gen/lib/ISO_32000/Three-D_node.pm6) [Timespan](gen/lib/ISO_32000/Timespan.pm6) [UR_transform](gen/lib/ISO_32000/UR_transform.pm6) [User_property](gen/lib/ISO_32000/User_property.pm6) [Web_Capture_information](gen/lib/ISO_32000/Web_Capture_information.pm6)
/VA|[Three-D_stream](gen/lib/ISO_32000/Three-D_stream.pm6)
/VE|[Optional_Content_Group_Membership](gen/lib/ISO_32000/Optional_Content_Group_Membership.pm6)
/VP|[Page](gen/lib/ISO_32000/Page.pm6)
/Version|[Catalog](gen/lib/ISO_32000/Catalog.pm6) [FDF_catalog](gen/lib/ISO_32000/FDF_catalog.pm6) [OPI_version_1_3](gen/lib/ISO_32000/OPI_version_1_3.pm6) [OPI_version_2_0](gen/lib/ISO_32000/OPI_version_2_0.pm6) [Trap_network_annotation](gen/lib/ISO_32000/Trap_network_annotation.pm6)
/Vertices|[Polygon_or_polyline_annotation_additional](gen/lib/ISO_32000/Polygon_or_polyline_annotation_additional.pm6)
/VerticesPerRow|[Type_5_Shading](gen/lib/ISO_32000/Type_5_Shading.pm6)
/View|[Collection](gen/lib/ISO_32000/Collection.pm6) [Optional_Content_Group_Usage](gen/lib/ISO_32000/Optional_Content_Group_Usage.pm6)
/ViewArea|[Viewer_preferences](gen/lib/ISO_32000/Viewer_preferences.pm6)
/ViewClip|[Viewer_preferences](gen/lib/ISO_32000/Viewer_preferences.pm6)
/ViewerPreferences|[Catalog](gen/lib/ISO_32000/Catalog.pm6)
/Volume|[Movie_activation](gen/lib/ISO_32000/Movie_activation.pm6) [Sound_action_additional](gen/lib/ISO_32000/Sound_action_additional.pm6)
/W|[Border_style](gen/lib/ISO_32000/Border_style.pm6) [Box_style](gen/lib/ISO_32000/Box_style.pm6) [CIDFont](gen/lib/ISO_32000/CIDFont.pm6) [Cross_reference_stream](gen/lib/ISO_32000/Cross_reference_stream.pm6) [Media_screen_parameters_MH-BE](gen/lib/ISO_32000/Media_screen_parameters_MH-BE.pm6)
/W2|[CIDFont](gen/lib/ISO_32000/CIDFont.pm6)
/WC|[Catalog_additional_actions](gen/lib/ISO_32000/Catalog_additional_actions.pm6)
/WMode|[CMap_stream](gen/lib/ISO_32000/CMap_stream.pm6)
/WP|[Catalog_additional_actions](gen/lib/ISO_32000/Catalog_additional_actions.pm6)
/WS|[Catalog_additional_actions](gen/lib/ISO_32000/Catalog_additional_actions.pm6)
/WhitePoint|[CalGray_colour_space](gen/lib/ISO_32000/CalGray_colour_space.pm6) [CalRGB_colour_space](gen/lib/ISO_32000/CalRGB_colour_space.pm6) [Lab_colour_space](gen/lib/ISO_32000/Lab_colour_space.pm6)
/Width|[Image](gen/lib/ISO_32000/Image.pm6) [Inline_Image](gen/lib/ISO_32000/Inline_Image.pm6) [Standard_layout_block-level_structure_element](gen/lib/ISO_32000/Standard_layout_block-level_structure_element.pm6) [Type_16_halftone](gen/lib/ISO_32000/Type_16_halftone.pm6) [Type_6_halftone](gen/lib/ISO_32000/Type_6_halftone.pm6)
/Width2|[Type_16_halftone](gen/lib/ISO_32000/Type_16_halftone.pm6)
/Widths|[Type_1_Font](gen/lib/ISO_32000/Type_1_Font.pm6) [Type_3_Font](gen/lib/ISO_32000/Type_3_Font.pm6)
/Win|[Launch_action_additional](gen/lib/ISO_32000/Launch_action_additional.pm6)
/WritingMode|[Standard_layout_structure_type](gen/lib/ISO_32000/Standard_layout_structure_type.pm6)
/X|[Annotation_additional_actions](gen/lib/ISO_32000/Annotation_additional_actions.pm6) [Rectilinear_measure_additional](gen/lib/ISO_32000/Rectilinear_measure_additional.pm6)
/XFA|[Interactive_form](gen/lib/ISO_32000/Interactive_form.pm6)
/XHeight|[Font_descriptor_common](gen/lib/ISO_32000/Font_descriptor_common.pm6)
/XN|[Three-D_view](gen/lib/ISO_32000/Three-D_view.pm6)
/XObject|[Resource](gen/lib/ISO_32000/Resource.pm6)
/XRefStm|[Hybrid-reference](gen/lib/ISO_32000/Hybrid-reference.pm6)
/XStep|[Type_1_Pattern](gen/lib/ISO_32000/Type_1_Pattern.pm6)
/Xsquare|[Type_10_halftone](gen/lib/ISO_32000/Type_10_halftone.pm6)
/Y|[Rectilinear_measure_additional](gen/lib/ISO_32000/Rectilinear_measure_additional.pm6)
/YStep|[Type_1_Pattern](gen/lib/ISO_32000/Type_1_Pattern.pm6)
/Ysquare|[Type_10_halftone](gen/lib/ISO_32000/Type_10_halftone.pm6)
/Z|[Rendition_criteria](gen/lib/ISO_32000/Rendition_criteria.pm6)
/Zoom|[Optional_Content_Group_Usage](gen/lib/ISO_32000/Optional_Content_Group_Usage.pm6)
/ca|[Graphics_state](gen/lib/ISO_32000/Graphics_state.pm6)
/checked|[PrintField](gen/lib/ISO_32000/PrintField.pm6)
/color|[CSS2_style](gen/lib/ISO_32000/CSS2_style.pm6)
/font|[CSS2_style](gen/lib/ISO_32000/CSS2_style.pm6)
/font-family|[CSS2_style](gen/lib/ISO_32000/CSS2_style.pm6)
/font-size|[CSS2_style](gen/lib/ISO_32000/CSS2_style.pm6)
/font-stretch|[CSS2_style](gen/lib/ISO_32000/CSS2_style.pm6)
/font-style|[CSS2_style](gen/lib/ISO_32000/CSS2_style.pm6)
/font-weight|[CSS2_style](gen/lib/ISO_32000/CSS2_style.pm6)
/op|[Graphics_state](gen/lib/ISO_32000/Graphics_state.pm6)
/text-align|[CSS2_style](gen/lib/ISO_32000/CSS2_style.pm6)
/text-decoration|[CSS2_style](gen/lib/ISO_32000/CSS2_style.pm6)
/vertical-align|[CSS2_style](gen/lib/ISO_32000/CSS2_style.pm6)
