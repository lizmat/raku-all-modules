use v6;
use Test;

use PDF::DAO::Stream;
use PDF::IO::IndObj;
use PDF::Grammar::PDF;
use PDF::Grammar::PDF::Actions;
use PDF::Font::Loader::Enc::CMap;

my $actions = PDF::Grammar::PDF::Actions.new;

my $input = q:to<--END-->;
593 0 obj <<
  /Length 1816
>> stream
/CIDInit /ProcSet findresource begin
12 dict begin
begincmap
/CIDSystemInfo
<< /Registry (TTX+0)
/Ordering (T42UV)
/Supplement 0
>> def
/CMapName /TTX+0 def
/CMapType 2 def
1 begincodespacerange
<0000><FFFF>
endcodespacerange
1 beginbfchar
<0005><0022>
endbfchar
79 beginbfrange
<0003><0003><0020>
<0004><0004><0021>
<0009><0009><0026>
<000a><000a><0027>
<000b><000b><0028>
<000c><000c><0029>
<000e><000e><002b>
<000f><000f><002c>
<0010><0010><002d>
<0011><0011><002e>
<0012><0012><002f>
<0013><0013><0030>
<0014><0014><0031>
<0015><0015><0032>
<0016><0016><0033>
<0017><0017><0034>
<0018><0018><0035>
<0019><0019><0036>
<001a><001a><0037>
<001b><001b><0038>
<001c><001c><0039>
<001d><001d><003a>
<001e><001e><003b>
<0024><0024><0041>
<0025><0025><0042>
<0026><0026><0043>
<0027><0027><0044>
<0028><0028><0045>
<0029><0029><0046>
<002a><002a><0047>
<002b><002b><0048>
<002c><002c><0049>
<002d><002d><004a>
<002e><002e><004b>
<002f><002f><004c>
<0030><0030><004d>
<0031><0031><004e>
<0032><0032><004f>
<0033><0033><0050>
<0034><0034><0051>
<0035><0035><0052>
<0036><0036><0053>
<0037><0037><0054>
<0038><0038><0055>
<0039><0039><0056>
<003a><003a><0057>
<003b><003b><0058>
<003c><003c><0059>
<003d><003d><005a>
<003f><003f><005c>
<0041><0041><005e>
<0042><0042><005f>
<0044><0044><0061>
<0045><0045><0062>
<0046><0046><0063>
<0047><0047><0064>
<0048><0048><0065>
<0049><0049><0066>
<004a><004a><0067>
<004b><004b><0068>
<004c><004c><0069>
<004d><004d><006a>
<004e><004e><006b>
<004f><004f><006c>
<0050><0050><006d>
<0051><0051><006e>
<0052><0052><006f>
<0053><0053><0070>
<0054><0054><0071>
<0055><0055><0072>
<0056><0056><0073>
<0057><0057><0074>
<0058><0058><0075>
<0059><0059><0076>
<005a><005a><0077>
<005b><005b><0078>
<005c><005c><0079>
<005d><005d><007a>
endbfrange
endcmap
CMapName currentdict /CMap defineresource pop
end end

endstream
endobj
--END--

PDF::Grammar::PDF.parse($input, :$actions, :rule<ind-obj>)
    // die "parse failed: $input";
my %ast = $/.ast;

my $ind-obj = PDF::IO::IndObj.new( :$input, |%ast );
my $cmap = $ind-obj.object;

my $cmap-obj = PDF::Font::Loader::Enc::CMap.new: :$cmap;

is-deeply $cmap-obj.decode("\x5\xF"), Buf[uint32].new(0x22, 0x2c), "decode";
is $cmap-obj.decode("\x24\x25\x26", :str), 'ABC', "decode:str";
done-testing;
