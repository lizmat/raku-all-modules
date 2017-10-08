unit class Testo::Test::Result;

has Bool:D $.so is required;
has Str:D  $.desc = '';
has        $.fail is default(Nil) = Nil;
