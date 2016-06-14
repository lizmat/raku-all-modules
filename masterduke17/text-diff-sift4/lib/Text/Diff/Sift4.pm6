use v6;

unit module Text::Diff::Sift4;

sub sift4(Str $s1, Str $s2, Int $maxOffset = 100, Int $maxDistance = 100 --> Int) is export {
	return !$s2 ?? 0 !! $s2.chars if !$s1 or !$s1.chars;
	return $s1.chars if !$s2 or !$s2.chars;

	my int $l1 = $s1.chars;
	my int $l2 = $s2.chars;

	my int ($c1, $c2, $lcss, $local_cs, $trans) = (0, 0, 0, 0, 0);
	my @offset_arr;

	while ($c1 < $l1) && ($c2 < $l2) {
		if substr($s1, $c1, 1) eq substr($s2, $c2, 1) {
			++$local_cs;
			my int $isTrans = 0;
			my int $i = 0;
			while $i < @offset_arr.elems {
				my %ofs = @offset_arr[$i];
				if $c1 <= %ofs<c1> || $c2 <= %ofs<c2> {
					$isTrans = abs($c2 - $c1) >= abs(%ofs<c2> - %ofs<c1>);
					if $isTrans {
						++$trans;
					} else {
						if !%ofs<trans> {
							%ofs<trans> = 1;
							++$trans;
						}
					}
					last;
				} else {
					if $c1 > %ofs<c2> && $c2 > %ofs<c1> {
						@offset_arr.splice($i, 1);
					} else {
						++$i;
					}
				}
			}
			@offset_arr.push({c1 => $c1, c2 => $c2, trans => $isTrans});
		} else {
			$lcss += $local_cs;
			$local_cs = 0;

			if $c1 != $c2 {
				$c1 = $c2 = min($c1, $c2);
			}

			loop (my int $i = 0; $i < $maxOffset && ($c1 + $i < $l1 || $c2 + $i < $l2); ++$i) {
				if ($c1 + $i < $l1) && (substr($s1, $c1 + $i, 1) eq substr($s2, $c2, 1)) {
					$c1 += $i - 1;
					--$c2;
					last;
				}
				if ($c2 + $i < $l2) && (substr($s1, $c1, 1) eq substr($s2, $c2 + $i, 1)) {
					$c2 += $i - 1;
					--$c1;
					last;
				}
			}
		}

		++$c1;
		++$c2;

		if $maxDistance {
			my int $tempDistance = max($c1, $c2) - $lcss + $trans;
			return round($tempDistance) if $tempDistance >= $maxDistance;
		}

		if $c1 >= $l1 || $c2 >= $l2 {
			$lcss += $local_cs;
			$local_cs = 0;
			$c1 = $c2 = min($c1, $c2);
		}
	}

	$lcss += $local_cs;

	return round(max($l1, $l2) - $lcss + $trans);
}
