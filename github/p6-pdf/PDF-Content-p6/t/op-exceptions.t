use v6;
use Test;

use lib '.';
use PDF::Grammar::Test :is-json-equiv;
use PDF::Content;
use PDF::Content::Ops :OpCode;
use PDF::Content::Matrix :scale;
use t::GfxParent;

sub warns-like(&code, $ex-type, $desc = 'warning') {
    my $ex;
    my Bool $w = False;
    &code();
    CONTROL {
	default {
	    $ex = $_;
	    $w = True;
	}
    }
    if $w {
        isa-ok $ex, $ex-type, $desc;
    }
    else {
        flunk $desc;
        diag "no warnings found";
    }
}

my $dummy-font = %() does role { method cb-finish {} }

my $parent = {
    :Font{ :F1($dummy-font) },
    :ExtGState{ :G1{ :ca(0.5) } },
} does t::GfxParent;
my PDF::Content $g .= new: :$parent;

throws-like {$g.Blah}, X::Method::NotFound, :message("No such method 'Blah' for invocant of type 'PDF::Content'");

$g.Save;
lives-ok {$g.Restore}, 'valid Restore';
throws-like {$g.Restore}, X::PDF::Content::OP::BadNesting, :message("Bad nesting; 'Q' (Restore) operator not matched by preceeding 'q' (Save)");

lives-ok {$g.SetFont('F1', 10)}, 'valid SetFont';
throws-like {$g.SetFont('F2', 10)}, X::PDF::Content::UnknownResource, :message("Unknown Font resource: /F2");

$g.Save;

lives-ok {$g.SetStrokeColorSpace('DeviceRGB')};
lives-ok {$g.SetStrokeColor(.2, .3, .4)};
throws-like {$g.SetStrokeColor(.2, .3)}, X::PDF::Content::OP::ArgCount, :message("Incorrect number of arguments in SC command, expected 3 DeviceRGB colors, got: 2");

lives-ok {$g.SetStrokeColorSpace('C1')};

lives-ok {$g.SetGraphicsState('G1')}, 'valid SetGraphicsState';
throws-like {$g.SetGraphicsState('G2'); }, X::PDF::Content::UnknownResource, :message("Unknown ExtGState resource: /G2");
$g.Restore;

$g.BeginMarkedContent('foo');
lives-ok {$g.EndMarkedContent}, 'valid EndMarkedContent';
throws-like {$g.EndMarkedContent}, X::PDF::Content::OP::BadNesting, :message("Bad nesting; 'EMC' (EndMarkedContent) operator not matched by preceeding 'BMC' or 'BDC' (BeginMarkedContent)");

$g.BeginText;
lives-ok {$g.ShowText('hi')};
lives-ok {$g.ShowSpaceText([['Hi', -10, 'There']])};
throws-like {$g.ShowSpaceText([['Hi', {}, 'There']])}, X::PDF::Content::OP::BadArrayArg, :message("Invalid entry in 'TJ' (ShowSpaceText) array: \$\{\}");
lives-ok {$g.EndText};

warns-like {$g.ShowText('there')}, X::PDF::Content::OP::Unexpected;

warns-like {$g.SetLineWidth(2)}, X::PDF::Content::OP::Unexpected;

$g.Save;
throws-like {$g.finish}, X::PDF::Content::Unclosed, :message("'q' (Save) unmatched by closing 'Q' (Restore) at end of content stream");
$g.Restore;

lives-ok {$g.finish};

done-testing();

