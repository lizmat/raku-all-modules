
use v6;
use Test;
use Getopt::Kinoko;
use Getopt::Kinoko::Group;
use Getopt::Kinoko::Option;
use Getopt::Kinoko::OptionSet;
use Getopt::Kinoko::NonOption;

plan 5;

{
    my Option $opt = create-option("s=s");
    my Option $opt-copy = $opt.deep-clone;

    ok $opt.WHERE != $opt-copy.WHERE, "Option deep copy ok.";
}

{
    my OptionSet $optset .= new();
    my OptionSet $optset-copy = $optset.deep-clone;

    ok $optset.WHERE != $optset-copy.WHERE, "OptionSet deep copy ok.";
}

{
	my NonOption $front = NonOption::Front.new(callback => -> $arg { });
	my $other-front = $front.deep-clone;

	ok $front.WHERE != $other-front.WHERE, "OptionSet deep copy ok.";
}

{
	my Group $a-radio = Group::Radio.new();
	my $o-radio = $a-radio.deep-clone;

	$a-radio.append("s|string=s;d|diff=i");
	ok $a-radio.has-option("s", :short), "a-radio has option s";
	nok $o-radio.has-option("s", :short), "o-radio has no option s";
}

done-testing();
