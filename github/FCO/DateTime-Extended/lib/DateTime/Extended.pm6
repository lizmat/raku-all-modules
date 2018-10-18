enum DayOfTheWeek (:7sunday :1monday :2tuesday :3wednesday :4thursday :5friday :6saturday);

use MONKEY-TYPING;
augment class Int {
	method DayOfTheWeek {
		DayOfTheWeek(self)
	}
}

role DateTime::Extended {
	method later	{...}
	method earlier	{...}
	method clone	{...}
	method year		{...}
	method month	{...}
	method day		{...}

	method day-of-week {
		DayOfTheWeek(callsame)
	}

	method next-day-of-week(DayOfTheWeek() $day, :$times = 1) {
		my $actual = $.day-of-week;
		my $diff = $day - $actual;
		$diff = abs $diff + 7 if $diff < 0;
		$.later(days => $diff)
			.later: weeks => $times - 1
	}

	method last-day-of-week(DayOfTheWeek() $day, :$times = 1) {
		my $actual = $.day-of-week;
		my $diff = $actual - $day;
		$diff = 7 - abs $diff if $diff < 0;
		$.earlier(days => $diff)
			.earlier: weeks => $times - 1
	}

	method first-day-of-month {
		$.clone(:1day)
	}

	method last-day-of-month {
		$.later(:1month).first-day-of-month.earlier: :1day
	}

	method years-until($target where Date | DateTime) {
		$target.year - $.year
	}

	method months-until($target where Date | DateTime) {
		($target.month - $.month) + (12 * ($.years-until($target)))
	}

	multi method next-riopm-social(Date:U:) {
		date-extended.today.next-riopm-social
	}

	multi method next-riopm-social(DateTime:U:) {
		datetime-extended.now.next-riopm-social
	}

	multi method next-riopm-social(Mu:D:) {
		my $first = self.new: :2017year:1month:13day    :18hour:0minute:0second;
		$first does DateTime::Extended;
		my $m = $first.months-until(self) + 3;
		$m %= 5;
		$m++;
		my $clone = self;
		$clone .= clone(:18hour, :0minute, :0second) if self ~~ DateTime;
		my $fd = $.clone(:18hour, :0minute, :0second).first-day-of-month;
		my $es = $fd.next-day-of-week($m, :2times);
		return $es if $es >= self;
		$fd.later(:1month).next-day-of-week(($m % 5) + 1, :2times);
	}
}

sub date-extended is export {
	Date but DateTime::Extended
}

sub datetime-extended is export {
	DateTime but DateTime::Extended
}
