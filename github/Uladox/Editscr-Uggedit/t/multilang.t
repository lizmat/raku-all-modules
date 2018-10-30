use v6;

use Test;
plan 1;

use Editsrc::Uggedit;
# Note this needs more work
{
    my $test-Uggedit = Editsrc::Uggedit::Editor.new(
     	editLineName => 'src_k',
    	editFile => 'multilang',
	captureField => True,
    );
    my $capturedText = $test-Uggedit.edit;
    ok $capturedText.index("#! e = \"demons\"").defined,
      'Can run code';
}

done;
