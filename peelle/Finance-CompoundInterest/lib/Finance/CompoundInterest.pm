unit module Finance::CompoundInterest;

sub compound_interest ( Rat() $present_value, Rat() $interest_rate, Rat() $frequency, Rat() $time )  is export {
	$present_value * ( 1 + $interest_rate / $frequency ) ** ( $frequency * $time ); # returns future value
}

sub compound_interest_with_payments ( Rat() $payment_value, Rat $interest_rate, Rat() $total_periods ) is export {
	( ( 1 + $interest_rate ) ** $total_periods - 1 ) / $interest_rate  * $payment_value; # returns future value
}

sub ciwp_payment_period ( Rat() $final_value, Rat() $interest_rate, Rat() $payment_value ) is export {
	log($final_value * $interest_rate / $payment_value + 1 ) / log( 1 + $interest_rate )
}

sub ciwp_payment_size ( Rat() $final_value, Rat() $interest_rate, Rat() $total_periods ) is export {
	( $final_value * $interest_rate ) / ((1 + $interest_rate ) ** $total_periods - 1) # Returns mounthly payment size to reach the estimated final payment.
}
