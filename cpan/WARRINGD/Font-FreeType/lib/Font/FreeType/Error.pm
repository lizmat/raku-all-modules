class Font::FreeType::Error is Exception {
    use Font::FreeType::Native::Types;
    our @Messages is export(:Messages);
    sub error-def(UInt $num, Str $message) {
        @Messages[$num] = $message;
        $num
    }
    our enum FT_ERROR is export(:FT_ERROR) (

  # generic errors

        Ok => error-def(0x00, "no error"),
        Cannot_Open_Resource => error-def(0x01, "cannot open resource"),
        Unknown_File_Format => error-def(0x02, "unknown file format"),
        Invalid_File_Format => error-def(0x03, "invalid file format"),
        Invalid_Version => error-def(0x04, "invalid FreeType version"),
        Lower_Module_Version=> error-def(0x05, "module version is too low"),
        Invalid_Argument => error-def(0x06, "invalid argument"),
        Unimplemented_Feature => error-def(0x07, "unimplemented feature"),
        Invalid_Table => error-def(0x08, "corrupted table"),
        Invalid_Offset => error-def(0x09, "invalid offset within table"),
        Array_Too_Large => error-def(0xA, "array allocation size too large"),
        Missing_Module => error-def(0xB, "missing module"),
        Missing_Property => error-def(0xC, "missing property"),

  # glyph/character errors

        Invalid_Glyph_Index => error-def(0x10, "invalid glyph index"),
        Invalid_Character_Code => error-def(0x11, "invalid character code"),
        Invalid_Glyph_Format => error-def(0x12, "unsupported glyph image format"),
        Cannot_Render_Glyph => error-def(0x13, "cannot render this glyph format"),
        Invalid_Outline => error-def(0x14, "invalid-outline"),
        Invalid_Pixel_Size => error-def(0x17, "invalid pixel size"),
  # handle errors

        Invalid_Handle => error-def(0x20, "invalid object handle" ),
        Invalid_Library_Handle => error-def(0x21, "invalid library handle" ),
        Invalid_Driver_Handle => error-def(0x22, "invalid module handle" ),
        Invalid_Face_Handle => error-def(0x23, "invalid face handle" ),
        Invalid_Size_Handle => error-def(0x24, "invalid size handle" ),
        Invalid_Slot_Handle => error-def(0x25, "invalid glyph slot handle" ),
        Invalid_CharMap_Handle => error-def(0x26, "invalid charmap handle" ),
        Invalid_Cache_Handle => error-def(0x27, "invalid cache manager handle" ),
        Invalid_Stream_Handle => error-def(0x28, "invalid stream handle" ),
  # driver errors

        Too_Many_Drivers => error-def(0x30, "too many modules" ),
        Too_Many_Extensions => error-def(0x31, "too many extensions" ),

  # memory errors

        Out_Of_Memory => error-def(0x40, "out of memory" ),
        Unlisted_Object => error-def(0x41, "unlisted object" ),

  # stream errors

        Cannot_Open_Stream => error-def(0x51, "cannot open stream" ),
        Invalid_Stream_Seek => error-def(0x52, "invalid stream seek" ),
        Invalid_Stream_Skip => error-def(0x53, "invalid stream skip" ),
        Invalid_Stream_Read => error-def(0x54, "invalid stream read" ),
        Invalid_Stream_Operation => error-def(0x55, "invalid stream operation" ),
        Invalid_Frame_Operation => error-def(0x56, "invalid frame operation" ),
        Nested_Frame_Access => error-def(0x57, "nested frame access" ),
        Invalid_Frame_Read => error-def(0x58, "invalid frame read" ),

  # raster errors

        Raster_Uninitialized => error-def(0x60, "raster uninitialized" ),
        Raster_Corrupted => error-def(0x61, "raster corrupted" ),
        Raster_Overflow => error-def(0x62, "raster overflow" ),
        Raster_Negative_Height => error-def(0x63, "negative height while rastering" ),

  # cache errors

        Too_Many_Caches => error-def(0x70, "too many registered caches" ),

  # TrueType and SFNT errors

        Invalid_Opcode => error-def(0x80, "invalid opcode" ),
        Too_Few_Arguments => error-def(0x81, "too few arguments" ),
        Stack_Overflow => error-def(0x82, "stack overflow" ),
        Code_Overflow => error-def(0x83, "code overflow" ),
        Bad_Argument => error-def(0x84, "bad argument" ),
        Divide_By_Zero => error-def(0x85, "division by zero" ),
        Invalid_Reference => error-def(0x86, "invalid reference" ),
        Debug_OpCode => error-def(0x87, "found debug opcode" ),
        ENDF_In_Exec_Stream => error-def(0x88, "found ENDF opcode in execution stream" ),
        Nested_DEFS => error-def(0x89, "nested DEFS" ),
        Invalid_CodeRange => error-def(0x8A, "invalid code range" ),
        Execution_Too_Long => error-def(0x8B, "execution context too long" ),
        Too_Many_Function_Defs => error-def(0x8C, "too many function definitions" ),
        Too_Many_Instruction_Defs => error-def(0x8D, "too many instruction definitions" ),
        Table_Missing => error-def(0x8E, "SFNT font table missing" ),
        Horiz_Header_Missing => error-def(0x8F, "horizontal header (hhea) table missing" ),
        Locations_Missing => error-def(0x90, "locations (loca) table missing" ),
        Name_Table_Missing => error-def(0x91, "name table missing" ),
        CMap_Table_Missing => error-def(0x92, "character map (cmap) table missing" ),
        Hmtx_Table_Missing => error-def(0x93, "horizontal metrics (hmtx) table missing" ),
        Post_Table_Missing => error-def(0x94, "PostScript (post) table missing" ),
        Invalid_Horiz_Metrics => error-def(0x95, "invalid horizontal metrics" ),
        Invalid_CharMap_Format => error-def(0x96, "invalid character map (cmap) format" ),
        Invalid_PPem => error-def(0x97, "invalid ppem value" ),
        Invalid_Vert_Metrics => error-def(0x98, "invalid vertical metrics" ),
        Could_Not_Find_Context => error-def(0x99, "could not find context" ),
        Invalid_Post_Table_Format => error-def(0x9A, "invalid PostScript (post) table format" ),
        Invalid_Post_Table => error-def(0x9B, "invalid PostScript (post) table" ),

  # CFF, CID, and Type 1 errors

        Syntax_Error => error-def(0xA0, "opcode syntax error" ),
        Stack_Underflow => error-def(0xA1, "argument stack underflow" ),
        Ignore => error-def(0xA2, "ignore" ),
        No_Unicode_Glyph_Name => error-def(0xA3, "no Unicode glyph name found" ),
        Glyph_Too_Big => error-def(0xA4, "glyph too big for hinting" ),

  # BDF errors

        Missing_Startfont_Field => error-def(0xB0, "`STARTFONT' field missing" ),
        Missing_Font_Field => error-def(0xB1, "`FONT' field missing" ),
        Missing_Size_Field => error-def(0xB2, "`SIZE' field missing" ),
        Missing_Fontboundingbox_Field => error-def(0xB3, "`FONTBOUNDINGBOX' field missing" ),
        Missing_Chars_Field => error-def(0xB4, "`CHARS' field missing" ),
        Missing_Startchar_Field => error-def(0xB5, "`STARTCHAR' field missing" ),
        Missing_Encoding_Field => error-def(0xB6, "`ENCODING' field missing" ),
        Missing_Bbx_Field => error-def(0xB7, "`BBX' field missing" ),
        Bbx_Too_Big => error-def(0xB8, "`BBX' too big" ),
        Corrupted_Font_Header => error-def(0xB9, "Font header corrupted or missing fields" ),
        Corrupted_Font_Glyphs => error-def(0xBA, "Font glyphs corrupted or missing fields" ),

        );
    has Int $.error is required;
    method message {
        my $message = @Messages[$!error]
            // "unknown error code: {$!error.fmt('0x%02X')}";
        "FreeType Error: $message";
    }

    sub ft-try(&sub) is export {
        my FT_Error $error = &sub();
        Font::FreeType::Error.new(:$error).throw
            if $error;
        True;
    }
}

