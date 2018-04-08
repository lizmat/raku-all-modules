use v6;
use Test;

plan 8;

use PDF::Class;
use PDF::IO::IndObj;
use PDF::Grammar::Test :is-json-equiv;
use PDF::Grammar::PDF;
use PDF::Grammar::PDF::Actions;
use PDF::COS;
use PDF::Content::Font::CoreFont;

my $actions = PDF::Grammar::PDF::Actions.new;

my $input = q:to"--END-OBJ--";
7 0 obj 
<<
  /CIDSystemInfo <<
    /Ordering (Identity)
    /Registry (Adobe)
    /Supplement 0
  >>
  /CIDToGIDMap /Identity
  /Subtype /CIDFontType2
  /Type /Font
  /W [15 [278]]
  /FontDescriptor 8 0 R
  /DW 1000
  /BaseFont /CBJNIG+Helvetica-Bold
>>
endobj
--END-OBJ--

PDF::Grammar::PDF.parse($input, :$actions, :rule<ind-obj>)
    // die "parse failed";
my %ast = $/.ast;
my $reader = class { has $.auto-deref = False }.new;
my $ind-obj = PDF::IO::IndObj.new( |%ast, :$input, :$reader);
my $object = $ind-obj.object;
is $ind-obj.obj-num, 7, '$.obj-num';
is $ind-obj.gen-num, 0, '$.gen-num';
isa-ok $object, (require ::('PDF::Font::CIDFontType2'));
is $object.Type, 'Font', '$.Type accessor';
is $object.Subtype, 'CIDFontType2', '$.Subype accessor';
$object.reader = $reader;
lives-ok {$object.check}, '$object.check lives';

# this test doesn't work unless PDF::Class has been installed
lives-ok { $object.CIDSystemInfo }, 'CIDSystemInfo accessor';

sub to-doc($font-obj) {
    my $dict = $font-obj.to-dict;
    { :$dict, :$font-obj }
}

skip 'CID Font Development';
##my %params = to-doc($object.font-obj);
##my $font = PDF::COS.coerce( |%params );
##isa-ok $font, (require ::('PDF::Font::CIDFontType2'));
