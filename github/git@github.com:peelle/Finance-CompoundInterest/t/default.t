use Test;

use lib 'lib';

plan 5;

use-ok 'Finance::CompoundInterest';

{
	use Finance::CompoundInterest;

	is-approx compound_interest( 5000, .005, 36, 3 ), 5075.56003652364, 'Basic compound interest.';

	is-approx compound_interest_with_payments( 150, .005, 36 ), 5900.41574470244, 'Compound interest with reocurring payments';

	is-approx ciwp_payment_period( 363377, .0083, 150 ), 368.944160846191, 'Compound interest with payments guess the number of periods to reach a certain amount.';

	is-approx ciwp_payment_size( 363377, .0083, 20 * 12 ), 481.012899065815, 'Same as above only searching for the optimal payment amount.';
}

