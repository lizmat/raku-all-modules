use v6;

use lib 'lib';

use DNS::Zone;
#use DNS::Zone::Grammars::Modern;
#use DNS::Zone::Grammars::ModernActions;
#use DNS::Zone::ResourceRecord;

sub MAIN(Str :$testFile!)
{
	my $data = $testFile.IO.slurp;
	if $data
	{
		# Load the file
		my $zone = DNS::Zone.new;
		$zone.load( :$data );

		# Print the new file
		say $zone.gen;
	}

	return 0;
}
