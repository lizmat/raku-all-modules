use v6;
use Test;

plan 10;

use PDF::Class;
use PDF::IO::IndObj;
use PDF::Grammar::PDF;
use PDF::Grammar::PDF::Actions;
use PDF::Grammar::Test :is-json-equiv;

my $actions = PDF::Grammar::PDF::Actions.new;
my $reader = class { has $.auto-deref = False }.new;

my $input = q:to"--END-OBJ--";
49 0 obj <<
  /Type /OCMD
  /OCGs <<
    /Type /OCG
    /Name (Watermark)
    /Usage <<
      /Export <<
        /ExportState /ON
      >>
      /PageElement <<
        /Subtype /FG
      >>
      /Print <<
        /PrintState /ON
      >>
      /View <<
        /ViewState /ON
      >>
    >>
  >>
>>
endobj
--END-OBJ--

PDF::Grammar::PDF.parse($input, :$actions, :rule<ind-obj>)
    // die "parse failed";
my %ast = $/.ast;
my $ind-obj = PDF::IO::IndObj.new( |%ast, :$reader);
is $ind-obj.obj-num, 49, '$.obj-num';
is $ind-obj.gen-num, 0, '$.gen-num';
my $ocmd-obj = $ind-obj.object;
my $ocg-obj = $ocmd-obj.OCGs;
isa-ok $ocg-obj, ::('PDF')::('OCG');
is $ocg-obj.Type, 'OCG', '$.Type accessor';
is $ocg-obj.type, 'OCG', '$.type accessor';
is $ocg-obj.Name, 'Watermark', '$.Name accessor';

my $usage = $ocg-obj.Usage;
does-ok $usage, ::('PDF')::('OCG')::('Usage'), 'Usage';

my $export = $usage.Export;
is $export.ExportState, 'ON', 'Usage.Export.ExportState';

lives-ok {$ocg-obj.check}, '$ocg-obj.check lives';

is-json-equiv $ind-obj.ast, %ast, 'ast regeneration';
