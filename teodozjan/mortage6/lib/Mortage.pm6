use v6;

=begin pod

=head1 Mortage
C<Mortage> is a module that reads simulates mortage with emphasis on additional costs. 

=head1 Synopsis

    =begin code

     use Mortage;
     my $bank = Mortage.new(bank=>"BANK",interest_rate => rate-monthly(324), mortage => 1290.93, mortages => 360, loan-left=> 297000); 
     $bank.add(AnnualCostConst.new(from=>1, to=>1, value=>$bank2.loan-left * basis-point(164))); # paid only once
     $bank.calc; # all the stuff goes here
     say $bank;

    =end code

=head1 Precision

Type used for calculation is based on data put by user. So if C<FatRat> is
provided it gets infinite precision. If Rat is provided, that is most common
perl6 type for non-integer, probalby rakudo will implicitly change it to C<Num>.
Don't worry for most mortages there is no difference.

=head1 Rounding

For now it uses arithmetic rounding. In future it should use bank rounding.
   
=end pod

=cut     
# formulas base on http://www.mtgprofessor.com/formulas.htm

#| Calculate monthly payment
#| $c = interest rate;
#| $n = mortages;
#| $L = loan value;
sub calculate-payment($c,$n,$L) is export {
    ($L*($c*(1 + $c)**$n))/((1 + $c)**$n - 1)
}

#| calculate-balance at any moment of loan
#| $c = interest rate;
#| $n = mortages;
#| $p = payment
#| $L = loan value;
# TODO tests
sub calculate-balance($c,$n,$L, $p) is export {
    $L*((1 + $c)**$n - (1 + $c)**$p)/((1 + $c)**$n - 1)
}

#TODO APR
# L - F = P1/(1 + i) + P2/(1 + i)2 +… (Pn + Bn)/(1 + i)n

#| Future Values
#| calculate-balance at any moment of loan
#| S single sum now
#| c interest rate
#| n length of the period
# TODO tests
sub calculate-fvalue($S,$c,$n) is export {$S*(1+$c)**$n}

#| calculate-balance at any moment of loan

#| c interest rate
#| n length of the period
#| p periodic payment
# TODO tests
sub calculate-fvalue-series($P,$n,$c){ $P*[(1+$c)**$n - 1]/$c}
    
#| Converts percent to number
sub percent(Numeric $rate) is export {
    #= 4 becomes 0.04
   $rate/100;
}

#| Converts interest rate that is yearly
sub rate-monthly(Numeric $rate) is export {
    #= $rate / percent / months om year
    $rate/1200;
}

#| Converts fractions of percents 
sub basis-point(Numeric $rate) is export {    
    $rate/10000;
}

#| Mother interface for all costs
class AnnualCost{
    has Int $.from;
    has Int $.to;
    method get( $loan-left,  $mortage) {!!!} 
}

#| Cost based on debt left
class AnnualCostPercentage is AnnualCost {
    has $.interest_rate;
    method get( $loan-left,  $mortage) { 
        return $loan-left*$!interest_rate;
    }
}

#| Cost based on monthly mortage installment
class AnnualCostMort is AnnualCost {
    has $.interest_rate;
    method get( $loan-left,  $mortage) {
        return $mortage*$!interest_rate;
    }
}

#| Annual cost not basing on anything just constant value
class AnnualCostConst is AnnualCost {
    has  $.value;
    method get( $loan-left,  $mortage)   {
        return $!value;
    }

}

#| Methods int this class don't round values unless specified.#|
#| Interest rates are stored in absolute value so 4% is 4/100
class Mortage {
    #TODO sparate input data from output data
    has Str $.currency; #= Currency, for gist 
    has Str $.bank; #= Bank name for gist
    has Numeric $.loan-left; #= how much debt left
    has Numeric $.interest_rate; #= Basic value for calculation of interest TODO rename to interest rate        
    has Int $.mortages; #= It is adjustable to comapare it with your bank calculations
    has Numeric $.mortage; #= The money you pay monthly without other costs 
    has Numeric $.total_interest; #= total interest paid
    has Numeric $.total_cost; #total cost, including interest
    has AnnualCost @.costs; #= Costs list included in calculation

    #| Simulation runs here. Calculates all months. 
    method calc {
        #= Results are visible in B<gist> and $.total_cost, $.loan-left
        for 1 .. $!mortages -> $mort {            
           
            for @!costs -> $cost {
                if $mort >= $cost.from && $mort <= $cost.to {
                    $!total_cost += $cost.get($.loan-left, $.mortage); 
                }                
            }
           
            #TODO rename
            my $intests =  $!interest_rate*$!loan-left;

            #say $mort, "  ",$intests.round(0.001), " ", $!loan-left.round(0.001);
            
            $!loan-left -= $!mortage;
            $!total_interest += $intests;
            $!loan-left +=  $intests;
            
        }
        
    }
    
    #| Provides summary with value round
    method gist {
        return $!bank ~ "\n" ~ join(" $!currency\n",
        "Mortage " ~ $!mortage.round(0.01),
        "Balance: " ~ $!loan-left.round(0.01),
        "Basic interests: " ~ $!total_interest.round(0.01),
        "Other costs: " ~ $!total_cost.round(0.01),
        "Total cost: " ~ ($!total_cost+$!total_interest).round(0.01)) ~
        "\nType used for cost " ~ $!total_cost.WHAT.gist ~
        "\nType used for calculation " ~ $!loan-left.WHAT.gist;
        # if correctly calculated $!loan-left should be close to 0
    }
    
    #| Will calculate mortage only pay. Without other costs.
    #| Value is rounded!
    method calc_mortage {
            my $c = $.interest_rate;
            my $n = $.mortages;
            my $L = $.loan-left;
            my $my_mortage = calculate-payment($c,$n,$L);
            return $my_mortage.round(0.01);
    }

    #| Every cost is counted annualy so if you want to
    #| add one time cost just place it in correct month
    method add(AnnualCost $cost){
        @!costs.push($cost);
    }
    
    #| pay off debt
    method cash($cash){
        $!loan-left -= $cash;
    }
}

