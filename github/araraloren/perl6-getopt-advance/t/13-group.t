
use Test;
use Getopt::Advance;

{
	my OptionSet $optset .= new;

	$optset.append(
		"S=b" => 'S option',
		"E=b" => 'E option',
		"C=b" => 'C option',
		:radio
	);

	dies-ok {
		getopt( ["-E", "-S"],  $optset,);
	}, "can not set two option both from one radio group same time.";
}

{
	my OptionSet $optset .= new;

	$optset.append(
		"S=b" => 'S option',
		"E=b" => 'E option',
		"C=b" => 'C option',
		:radio,
		:!optional
	);
	$optset.push("a=b");

	dies-ok {
		getopt( ["-a", ],  $optset,);
	}, "must set one option when use force group.";
}

{
	my OptionSet $optset .= new;

	$optset.append(
		"a=b" => 'a option',
		"b=b" => 'b option',
		"c=b" => 'c option',
		:multi
	);

	lives-ok {
		getopt( ["-a", "-b", "-c"],  $optset,);
	}, "can set multi option which from one multi group same time.";
}

{
	my OptionSet $optset .= new;

	$optset.append(
		"a=b" => 'a option',
		"b=b" => 'b option',
		"c=b" => 'c option',
		:multi,
		:!optional
	);
	$optset.push("d=b");

	dies-ok {
		getopt( ["-d", ],  $optset,);
	}, "must set one option when use force group.";
}

done-testing();