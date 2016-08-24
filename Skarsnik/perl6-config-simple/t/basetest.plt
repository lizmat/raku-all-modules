use Config::Simple;
{
	my $conf;
	$conf = Config::Simple.read($file) if $format eq '';
	$conf = Config::Simple.read($file, :f($format)) if $format ne '';

	ok $conf<video><title> eq "Dune", "Video title is Dune";
	ok $conf<subtitle><file> eq "Dune_sub.txt", "Subtitle file is Dune_sub.txt";
	nok $conf<dont><exist>.defined, "Calling something that don't exist";

	$conf<subtitle><format> = "ssa";
        if $format ne 'ini' {
  	$conf.write('t/temp.temp');

	$conf = Config::Simple.read("t/temp.temp") if $format eq '';
	$conf = Config::Simple.read("t/temp.temp", :f($format)) if $format ne '';

	ok $conf<subtitle><format> eq "ssa", "Changing subtitle format";

	unlink 't/temp.temp';
        }
        else {
          ok True, "fudging for ini";
        }
}
