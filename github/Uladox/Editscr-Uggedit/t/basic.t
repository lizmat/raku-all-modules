use v6;

use Test;
plan 3;

use Editsrc::Uggedit;
# Note this needs more work
{
    my $test-Uggedit = Editsrc::Uggedit::Editor.new(
     	editLineName => 'src_k',
    	editFile => 'basic',
	ignoreEditLine => True,
	addText => True,
	addTextOnce => True,
	textToAdd => "# This is some added Text\n",
	captureField => True,
    );
    my $capturedText = $test-Uggedit.edit;
    ok $capturedText.index("# This is some added Text").defined,
      'Able to add Text';
    ok 1 == $capturedText.comb(/"# This is some added Text"/),
      'Only added text once';
    $test-Uggedit.ignoreEditLine = False;
    $test-Uggedit.addText = False;
    $capturedText = $test-Uggedit.edit;
    ok $capturedText.index('Look: "This text won\'t be added the first time"').defined,
      'Able to run perl 6 code';
}

done;
