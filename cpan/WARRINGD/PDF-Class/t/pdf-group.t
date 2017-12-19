use v6;
use Test;

use PDF::Class;
use PDF::Grammar::PDF;
use PDF::Grammar::PDF::Actions;
use PDF::IO::IndObj;

my $input = q:to"--END--";
42 0 obj <<
    /Type /Group
    /S /Transparency
    /I true
    /CS /DeviceRGB
>>
endobj
--END--

my $actions = PDF::Grammar::PDF::Actions.new;
PDF::Grammar::PDF.parse($input, :$actions, :rule<ind-obj>)
    // die "parse failed: $input";
my %ast = $/.ast;

my $ind-obj = PDF::IO::IndObj.new( :$input, |%ast );
my $group-obj = $ind-obj.object;
isa-ok $group-obj, ::('PDF::Group');
is $group-obj.Type, 'Group', 'Group Type';
is $group-obj.S, 'Transparency', 'Subtype';
is $group-obj.I, True, 'I';
is $group-obj.CS, 'DeviceRGB', 'CS';

done-testing;
