
use v6;

unit class GTK::Scintilla;

enum CursorType is export (
    Normal       => -1,
    Arrow        => 2,
    Wait         => 4,
    ReverseArrow => 7
);

enum EdgeMode is export (
    None         => 0,
    Line         => 1,
    Background   => 2,
    MultiLine    => 3
);

# SciLexer.h
constant SCLEX_PERL is export = 6;
#----
constant SCE_PL_DEFAULT is export = 0;
constant SCE_PL_ERROR is export = 1;
constant SCE_PL_COMMENTLINE is export = 2;
constant SCE_PL_POD is export = 3;
constant SCE_PL_NUMBER is export = 4;
constant SCE_PL_WORD is export = 5;
constant SCE_PL_STRING is export = 6;
constant SCE_PL_CHARACTER is export = 7;
constant SCE_PL_PUNCTUATION is export = 8;
constant SCE_PL_PREPROCESSOR is export = 9;
constant SCE_PL_OPERATOR is export = 10;
constant SCE_PL_IDENTIFIER is export = 11;
constant SCE_PL_SCALAR is export = 12;
constant SCE_PL_ARRAY is export = 13;
constant SCE_PL_HASH is export = 14;
constant SCE_PL_SYMBOLTABLE is export = 15;
constant SCE_PL_VARIABLE_INDEXER is export = 16;
constant SCE_PL_REGEX is export = 17;
constant SCE_PL_REGSUBST is export = 18;
constant SCE_PL_LONGQUOTE is export = 19;
constant SCE_PL_BACKTICKS is export = 20;
constant SCE_PL_DATASECTION is export = 21;
constant SCE_PL_HERE_DELIM is export = 22;
constant SCE_PL_HERE_Q is export = 23;
constant SCE_PL_HERE_QQ is export = 24;
constant SCE_PL_HERE_QX is export = 25;
constant SCE_PL_STRING_Q is export = 26;
constant SCE_PL_STRING_QQ is export = 27;
constant SCE_PL_STRING_QX is export = 28;
constant SCE_PL_STRING_QR is export = 29;
constant SCE_PL_STRING_QW is export = 30;
constant SCE_PL_POD_VERB is export = 31;
constant SCE_PL_SUB_PROTOTYPE is export = 40;
constant SCE_PL_FORMAT_IDENT is export = 41;
constant SCE_PL_FORMAT is export = 42;
constant SCE_PL_STRING_VAR is export = 43;
constant SCE_PL_XLAT is export = 44;
constant SCE_PL_REGEX_VAR is export = 54;
constant SCE_PL_REGSUBST_VAR is export = 55;
constant SCE_PL_BACKTICKS_VAR is export = 57;
constant SCE_PL_HERE_QQ_VAR is export = 61;
constant SCE_PL_HERE_QX_VAR is export = 62;
constant SCE_PL_STRING_QQ_VAR is export = 64;
constant SCE_PL_STRING_QX_VAR is export = 65;
constant SCE_PL_STRING_QR_VAR is export = 66;

method version {
    return {
        major  => 3,
        minor  => 7,
        patch  => 2,
        string => "3.7.2"
    }
}
