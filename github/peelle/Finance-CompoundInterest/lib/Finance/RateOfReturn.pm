unit module Finance::RateOfReturn;

sub single_period_return ( Rat() $initial_value, Rat() $final_value ) is export {
	( $final_value - $initial_value ) / $initial_value; # returns the interest rate over a single period for an investment.
}

sub annualisation ( Rat() $expected_return, Rat() $period_of_time ) is export {
	( $expected_return / $period_of_time );
}
