use v6;

constant $more_than_percent is export = 120000;
constant $more_than_promile is export = 10000;
constant $pennies is export = 100;
constant $percent is export = 100;

class AnnualCost{
    has Int $.from;
    has Int $.to;
}

class AnnualCostPercentage is AnnualCost {
    has $.interest;
    method get( $toPay,  $mortage) { 
        return $toPay*$!interest;
    }
}


class AnnualCostMort is AnnualCost {
    has $.interest;
    method get( $toPay,  $mortage) {
        return $mortage*$!interest;
    }
}
class AnnualCostConst is AnnualCost {
    has  $.value;
    method get( $toPay,  $mortage)   {
        return $!value;
    }

}

class Mortage {
    has Str $.currency;
    has Str $.bank;
    has $.to_pay = Rat.new(297000,1);
    has $.interest;
    has Int $.mortages = 360;
    has $.mortage;
    has $.total_interest = Rat.new(0,1);
    has $.total_cost = Rat.new(0,1);
    has AnnualCost @.costs;

    method calc {
        for 1 .. $!mortages -> $mort {            
           
            for @!costs -> $cost {
                if $mort >= $cost.from && $mort <= $cost.to {
                    $!total_cost += $cost.get($.to_pay, $.mortage); 
                }                
            }
           
            my $intests =  $!interest*$!to_pay;

            #say $mort, "  ",$intests.round(0.001), " ", $!to_pay.round(0.001);
            
            $!to_pay -= $!mortage;
            $!total_interest += $intests;
            $!to_pay +=  $intests;
            
            # Uncomment if want infltation
            #$!total_interest *= 1-Rat.new(200,$more_than_percent);
            
            
        }
    }

    method gist {
        return join "$!currency\n", $.bank,
        "Mortage " ~ $.mortage.round(0.01),
        "Balance: " ~ $.to_pay.round(0.01),
        "Basic interests: " ~ $.total_interest.round(0.01),
        "Other costs: " ~ $.total_cost.round(0.01),
        "Total cost: " ~ ($.total_cost+$.total_interest).round(0.01);
        # if correctly calculated $.to_pay should be close to 0
    }

    method calc_mortage {

            my $c = $.interest;
            my $n = $.mortages;
            my $L = $.to_pay;
            my $my_mortage = ($L*($c*(1 + $c)**$n))/((1 + $c)**$n - 1);
            return $my_mortage.round(0.01);

            
    }

    method add(AnnualCost $cost){
        @!costs.push($cost);
    }

    method cash($cash){
        $!to_pay -= $cash;
    }
}
