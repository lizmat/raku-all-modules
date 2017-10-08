use v6;
unit module Lingua::Number;

use XML;
use JSON::Tiny;

my $data_location = $?FILE.split( /'.pm' $/ ).[0];   # i.e. lib/Lingua/Number/

my %rbnf;
my %rbnf-rulesets;

my %numberformat := from-json("$data_location/digitformat.json".IO.slurp);

sub load_xml ($lingua) {
	my @locs := @*INC.grep: { "$_/Lingua/Number/rbnf-xml".path.e }
	my $xml = from-xml(file => "@locs[0]/Lingua/Number/rbnf-xml/$lingua.xml");
	
	#my @rulesets := $xml.elements(:TAG<rbnf>)[0].[0].elements(:TAG<ruleset>);
	my @rulesets := $xml.elements(:TAG<rbnf>)[0].elements(:TAG<rulesetGrouping>)».elements(:TAG<ruleset>);

	my @nonprivaterulesets;
	for @rulesets -> $rulesetxml {
		my $ruletype = $rulesetxml<type>;
		if $rulesetxml<access>.defined { $ruletype = "%" ~ $ruletype; }
		push @nonprivaterulesets, $ruletype; # unless $rulesetxml<access>.defined;
		
		my @rulevals;
		for $rulesetxml.elements(:TAG<rbnfrule>) -> $r {
			%rbnf{$lingua}{$ruletype}{ ~$r<value> } = {
				text => cleanrule( ~$r[0] ),
				radix => +($r<radix> // 10) };
			@rulevals.push: $r<value>;
		}
		%rbnf{$lingua}{$ruletype}<values> = [ @rulevals.grep( *.Numeric.defined )];
	}
	%rbnf-rulesets{$lingua} := @nonprivaterulesets;
	# tree:
	# %rbnf<$lingua><$ruleset><$value>   $value = "10", for example
	# %rbnf<$lingua><$ruleset><$value><text> = ten;
	# %rbnf<$lingua><$ruleset><$value><radix> = 10
	#                         <values> = ( -x, x.x, 0, 1, 2...)
	1;
}


sub load_json ($lingua) {
	my $json = from-json("$data_location/rbnf-json/$lingua.json".IO.slurp);

	my @rulesetnames;

	my @rulesets := $json.<ldml>[0]<rbnf>[0]<ruleset>;
	for @rulesets -> $rs {
		my $ruletype = $rs.<type>;
		$ruletype = "%" ~ $ruletype if $rs<access>.defined;
		@rulesetnames.push: $ruletype;
		
		my @rulevals;
		#say $rs<rbnfrule>.perl;
		for $rs<rbnfrule>.list -> %r {
			#say $ruletype, ":", %r.perl; #exit;
			%rbnf{$lingua}{$ruletype}{ %r<value> } = {
				text => cleanrule( %r<text> ),
				radix => +(%r<radix> // 10) };
			@rulevals.push: %r<value>;
		}
		%rbnf{$lingua}{$ruletype}<values> = [ @rulevals.grep( *.Numeric.defined )];

	}

	%rbnf-rulesets{$lingua} = @rulesetnames.perl;
	1;
}
	
#load_json('en');



sub cleanrule (Str $ruletext is copy) {
	$ruletext ~~ s/ ';' .* $ //;
	$ruletext ~~ s/^ \s* \' //;
	$ruletext;
}

my $ruleregex = rx/^ $<begin>=[ <-[←=→\[]>* ] [
		   [
			|| $<call>=[ $<arrow>='[' ~ ']' $<func>=[ <-[\]]>+ ] ]
			|| $<call>=[ $<arrow>=<[←=→]> \%? $<func>=[<-[←=→]>*] $<arrow> ]
		   ]
		   $<text>=[ <-[\[←=→]>* ] ]* $/;


sub rule2text (Str $lingua, Str $ruletype, $number) is export {
	%rbnf{$lingua}.defined or load_json($lingua);

	my $ruleset := %rbnf{$lingua}{$ruletype}
		or fail "Invalid ruleset $ruletype for language $lingua.";

	#special cases for negative, decimal fraction numbers
	if $number < 0 and $ruleset<-x>.defined {
		my $ruletext = $ruleset<-x><text>;
		$ruletext ~~ s/ '→→' /{rule2text($lingua, $ruletype, $number.abs)}/;
		return $ruletext;
	}
	if $number.Int != $number and $ruleset<x.x>.defined {
		my $ruletext = $ruleset<x.x><text>;
		my ($ipart, $fpart) = $number.split('.');
		my @fracspelling = $fpart.comb.map: { rule2text($lingua, $ruletype, $_) };
		$ruletext ~~ s/	'←←' /{rule2text($lingua, $ruletype, $ipart)}/;
		$ruletext ~~ s/ (\s?) '→→' '→'? /{~$0 ~ @fracspelling.join(~$0)}/;
			  # here '→→' really means something different than normal :'(
		return $ruletext;
	}

	#find the appropriate rule value
	my $i = 0;
	my @rvalues := $ruleset<values>;
	while @rvalues[$i].defined and $number >= @rvalues[$i] { $i++; }
	my $ruleval =  @rvalues[$i-1];

	my $rule := $ruleset{ $ruleval };
	my $ruletext = $rule<text>;
	my $radix = $rule<radix> // 10;

	# Find arrows in the text
	my $match = $rule<text> ~~ $ruleregex;
	
	my @items;
	for ($match<func>.list Z $match<arrow>.list)».Str -> $func is copy, $arrow is copy {
		my ($next-number, $before, $after) = ('' xx 3);
		if $arrow eq '[' {
			my $m2 = $func ~~ $ruleregex;
			($arrow, $before, $after, $func) = ~$m2<arrow>[0], ~$m2<begin>, ~$m2<text>[0], ~$m2<func>[0];
		}

		given $arrow {
			$next-number = prev-digits($number, $ruleval, $radix)   when '←';
			$next-number = next-digits($number, $ruleval, $radix)   when '→';
			$next-number = $number	                                when '=';
		}
		#say $number, " $next-number=", so +$next-number, " '", $func, "'=", so $func ~~ /^'%'/, ;
		unless +$next-number or $func ~~ /^'%'/ { @items.push: ''; next; }
		$func ||= $ruletype;
		

		if $func ~~ /^'#'/ {
			@items.push: format_digital($func, $lingua, $number);
		}
		else {
			@items.push: $before ~ rule2text($lingua, $func, $next-number) ~ $after;
		}
		
	}
	
	[~] ($match<begin>».Str, (@items Z $match<text>».Str));
	
}  #end rule2text

sub next-digits ($number, $rule_val, $radix = 10) {
	### Not sure which is actually faster here
	#if $radix == 10 {  $old_num mod 10 ** ($rule_val.chars-1) }
	if $radix == 10 {
		$number.Str.substr(* - $rule_val.chars + 1);
	}
	else { 
		$number mod $radix ** ($rule_val.log($radix) + 2**-50).Int;
	}

}
;
sub prev-digits ($number, $rule_val, $radix = 10) {
	if $radix == 10 {
		$number.Str.substr(0, * - $rule_val.chars + 1)
	}
	else { 
		$number div $radix ** ($rule_val.log($radix) + 2**-50).Int;
	}
}

sub format_digital ($func, $lingua, $number is copy) {
	my $match = $func ~~ / ',' $<len>=['#'* '0'] ['.' | $] /;
	my $grouping_size = (~$match<len>).chars;
	#say join '|', $func, ~$match<len>, $grouping_size;

	my $grouping_char = %numberformat{$lingua}<group> // ',';
	my $decimal_point = %numberformat{$lingua}<decimal> // '.';

	my $fractional_part = '';
	if $number.Int != $number {
		($number, $fractional_part) = $number.split('.');
		$fractional_part = $decimal_point ~ $fractional_part;
	}	

	my $out;
	my ($i, $maxi) = $number.chars xx 2;
	for $number.comb -> $n {
		$out ~= $grouping_char if $i %% $grouping_size and $i != $maxi;
		$i--;
		$out ~= $n;
	}
	$out ~ $fractional_part;

}


sub Lingua-Number-rulesets (Str $lingua) is export {
	%rbnf-rulesets{$lingua}.defined or load_json($lingua);
	%rbnf-rulesets{$lingua};
}


sub get_gender ($lingua, $gender) {
	my $w_gender =
		do given $gender {
			when m:i/^ 'm' / { '-masculine' }    #:
			when m:i/^ 'f' / { '-feminine' }     #:
			when m:i/^ 'n' / { '-neuter' }       #:
			default { '' };
		};
	if $lingua eq any( <ar ca cs hr es fr he hi it lt lv mr nl pl pt ro ru sk sl sr uk ur zh zh_Hant>) {
		$w_gender ||= '-masculine';
	}
	$w_gender;
}

sub cardinal ($number, Str $lingua = 'en', :$gender is copy = '', :$plural = False, :$slang is copy = '') is export {
	$gender = get_gender($lingua, $gender);
	$slang = $slang ?? "-$slang" !! '';

	my $ruleset = [~] "spellout-cardinal", $gender, $slang;
	rule2text($lingua, $ruleset, $number);
}


sub ordinal ($number, Str $lingua = 'en', :$gender is copy = '', :$plural = False, :$slang is copy = '') is export {
	$gender = get_gender($lingua, $gender);
	$slang = $slang ?? "-$slang" !! '';
	
	my $ruleset = [~] "spellout-ordinal", $gender, $slang;
	rule2text($lingua, $ruleset, $number);
}


sub ordinal-digits ($number, Str $lingua = 'en', :$gender is copy = '', :$plural = False, :$slang is copy = '') is export {
	$gender = get_gender($lingua, $gender);
	$slang = $slang ?? "-$slang" !! '';
	
	my $ruleset = [~] "digits-ordinal", $gender, $slang;
	rule2text($lingua, $ruleset, $number);
}


sub roman-numeral ($number) is export {
	rule2text('root', 'roman-upper', $number);
}

sub timetest {
	my $t = now;
	load_xml('en'); load_xml('it'); load_xml('es');
	say "xml:", now - $t;
	%rbnf = Nil;
	$t = now;
	load_json('en'); load_json('it'); load_json('es');
	say "json:", now - $t;
}

