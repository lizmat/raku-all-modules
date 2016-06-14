
use v6;

unit module GTK::Scintilla;

# Scintilla.h
constant SCI_INSERTTEXT is export    = 2003;
constant SCI_STYLECLEARALL is export = 2050;
constant SCI_STYLESETFORE is export  = 2051;
constant SCI_STYLESETBOLD is export  = 2053;
constant SCI_GETTEXTLENGTH is export = 2183;
constant SCI_ZOOMIN is export        = 2333;
constant SCI_ZOOMOUT is export       = 2334;
constant SCI_GETEDGECOLUMN is export = 2360;
constant SCI_SETEDGECOLUMN is export = 2361;
constant SCI_GETEDGEMODE is export   = 2362;
constant SCI_SETEDGEMODE is export   = 2363;
constant SCI_GETEDGECOLOUR is export = 2364;
constant SCI_SETEDGECOLOUR is export = 2365;
constant SCI_SETZOOM is export       = 2373;
constant SCI_GETZOOM is export       = 2374;
constant SCI_SETLEXER is export      = 4001;
constant SCI_SETKEYWORDS is export   = 4005;


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

constant EDGE_NONE is export       = 0;
constant EDGE_LINE is export       = 1;
constant EDGE_BACKGROUND is export = 2;
