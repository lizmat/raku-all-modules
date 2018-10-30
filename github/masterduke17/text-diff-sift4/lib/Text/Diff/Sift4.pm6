use v6;
use nqp;

unit module Text::Diff::Sift4;

sub sift4(Str:D() $s1, Str:D() $s2, Int $maxOffset = 100, Int $maxDistance = 100 --> Int) is export {
	my int $l1 = nqp::chars($s1);
	my int $l2 = nqp::chars($s2);

	return $l2 unless $l1;
	return $l1 unless $l2;

	my int $c1;
	my int $c2;
	my int $lcss;
	my int $local_cs;
	my int $trans;

	my int $max_offset   = $maxOffset;
	my int $max_distance = $maxDistance;

	my $offset_arr := nqp::list_i;

	my int $isTrans;
	my int $i;

	while nqp::islt_i($c1, $l1) && nqp::islt_i($c2, $l2) {
		if nqp::iseq_i(nqp::ordat($s1, $c1), nqp::ordat($s2, $c2)) {
			nqp::stmts(
				($isTrans = 0),
				($i = 0),
				($local_cs = nqp::add_i($local_cs, 1)),

				nqp::while(nqp::islt_i($i, nqp::elems($offset_arr)),
					nqp::stmts(
						(my int $_trans = nqp::atpos_i($offset_arr, $i)),
						(my int $_c1    = nqp::atpos_i($offset_arr, nqp::add_i($i, 1))),
						(my int $_c2    = nqp::atpos_i($offset_arr, nqp::add_i($i, 2))),

						nqp::if(nqp::isle_i($c1, $_c1) || nqp::isle_i($c2, $_c2),
							nqp::stmts(
								($isTrans = nqp::isge_i(nqp::abs_i(nqp::sub_i($c2, $c1)), nqp::abs_i(nqp::sub_i($_c2, $_c1)))),
								nqp::if($isTrans,
									($trans = nqp::add_i($trans, 1)),
									nqp::unless($_trans,
										nqp::stmts(nqp::bindpos_i($offset_arr, $i, 1),
												($trans = nqp::add_i($trans, 1))))),
								($i = 2147483647)),

								nqp::if((nqp::isgt_i($c1, $_c2) && nqp::isgt_i($c2, $_c1)),
									nqp::splice($offset_arr, nqp::list, $i, 3),
									($i = nqp::add_i($i, 3)))))),
					nqp::push_i($offset_arr, $isTrans),
					nqp::push_i($offset_arr, $c1),
					nqp::push_i($offset_arr, $c2))
		} else {
			nqp::stmts(
				($lcss = nqp::add_i($lcss, $local_cs)),
				($local_cs = 0),

				nqp::if(nqp::isne_i($c1, $c2), ($c1 = $c2 = nqp::isle_i($c1, $c2) ?? $c1 !! $c2)),

				($i = 0),
				nqp::while(
					nqp::islt_i($i, $max_offset) && (nqp::islt_i(nqp::add_i($c1, $i), $l1) ||
					                                 nqp::islt_i(nqp::add_i($c2, $i), $l2)),
					nqp::stmts(
						nqp::if(nqp::islt_i(nqp::add_i($c1, $i), $l1) &&
						                    nqp::iseq_i(nqp::ordat($s1, nqp::add_i($c1, $i)),
						                                nqp::ordat($s2, $c2)),
							nqp::stmts(
								($c1 = nqp::sub_i(nqp::add_i($c1, $i), 1)),
								($c2 = nqp::sub_i($c2, 1)),
								($i = 2147483647))),
						nqp::if(nqp::islt_i(nqp::add_i($c2, $i), $l2) &&
						                    nqp::iseq_i(nqp::ordat($s1, $c1), nqp::ordat($s2, nqp::add_i($c2, $i))),
							nqp::stmts(
								($c2 = nqp::sub_i(nqp::add_i($c2, $i), 1)),
								($c1 = nqp::sub_i($c1, 1)),
								($i = 2147483647))),
						($i = nqp::add_i($i, 1)))))
		}

		$c1 = nqp::add_i($c1, 1);
		$c2 = nqp::add_i($c2, 1);

		nqp::if(nqp::isge_i(            nqp::add_i(nqp::sub_i((nqp::isge_i($c1, $c2) ?? $c1 !! $c2), $lcss), $trans), $max_distance),
		  nqp::if($max_distance, return nqp::add_i(nqp::sub_i((nqp::isge_i($c1, $c2) ?? $c1 !! $c2), $lcss), $trans)));

		nqp::if(nqp::isge_i($c1, $l1) || nqp::isge_i($c2, $l2),
			nqp::stmts(
				($lcss = nqp::add_i($lcss, $local_cs)),
				($local_cs = 0),
				($c1 = $c2 = (nqp::isle_i($c1, $c2) ?? $c1 !! $c2)))
		);
	}

	$lcss = nqp::add_i($lcss, $local_cs);

	nqp::add_i(nqp::sub_i((nqp::isge_i($l1, $l2) ?? $l1 !! $l2), $lcss), $trans)
}

# vim: ft=perl6
