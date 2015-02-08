use DateTime::Format;

module DateTime::Format::LikeGo;

# Change whitespace to _, per go's time spec
my $reference-date = DateTime.new('2006-01-02T15:04:05-0700');
# See http://golang.org/pkg/time/
my %map = (
	'%a' => 'Mon',
	'%A' => 'Monday',
	'%b' => 'Jan',
	'%B' => 'January',
	'%d' => '02',
	'%e' => '_2',
	'%m' => '01',
	'%H' => '15',
	'%I' => '03',
	'%l' => '_3',
	'%M' => '04',
	'%P' => 'pm',
	'%p' => 'PM',
	'%S' => '05',
	'%y' => '06',
	'%Y' => '2006',
	'%Z' => 'MST',
);

our sub go-to-strftime($goformat is copy) {
	$goformat ~~ s:g/\%/%%/; # Non-word match, do it first
	for %map.keys -> $code {
		my $gostyle = %map{$code};
		$goformat ~~ s:g/<<$gostyle>>/$code/;
	}
	if $goformat ~~ /\d/ {
		die qq:to/END/;
		Format string contains numbers after conversion, typo likely.
		Resulting string was "$goformat".
		Reference date is "$reference-date".
		END
	}
	return $goformat;
}

our sub go-date-format($goformat, $date) is export {
	return strftime(go-to-strftime($goformat), $date);
}

