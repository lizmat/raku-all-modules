use v6;

constant $more_than_percent = 120000;
constant $more_than_promile = 10000;
constant $PLN_GR = 100;
constant $percent = 100;
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
 
class DBIWP is AnnualCostConst {
    has $.cumulation;
    has $.antiinterest;
    method get($toPay,$mortage){
        $!cumulation += 290;
        $!cumulation -= $!cumulation*$!antiinterest;
        #say "$!cumulation ({$!cumulation*$!antiinterest})";
        return 10+$!cumulation*$!antiinterest;

    }

}   
class Mortage {
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

            #say $mort, "  ",$intests.round(0.01), " ", $!to_pay.round(0.01);
            
            $!to_pay -= $!mortage;
            $!total_interest += $intests;
            $!to_pay +=  $intests;
            
            # Uncomment if want infltation
            #$!total_interest *= 1-Rat.new(200,$more_than_percent);
            
            
        }
    }

    method gist {
        return join " PLN\n", $.bank,
        "Rata " ~ $.mortage.round(0.01),
        "Kapital(kontrolnie): " ~ $.to_pay.round(0.01),
        "Koszty odsetki: " ~ $.total_interest.round(0.01),
        "Koszty inne: " ~ $.total_cost.round(0.01),
        "Razem: " ~ ($.total_cost+$.total_interest).round(0.01);
        # if correctly calculated $.to_pay should be close to 0
    }

    method calc_mortage {

            my $c = $.interest;
            my $n = $.mortages;
            my $L = $.to_pay;
            my $my_mortage = ($L*($c*(1 + $c)**$n))/((1 + $c)**$n - 1);
            return $my_mortage;

            
    }

    method add(AnnualCost $cost){
        @!costs.push($cost);
    }

    method cash($cash){
        $!to_pay -= $cash;
    }
}

my $mbank2 = Mortage.new(bank=>"MBANK2",interest => Rat.new(324,$more_than_percent), mortage=>Rat.new(129093,$PLN_GR));
# polisa
$mbank2.add(AnnualCostConst.new(from=>1, to=>1, value=>$mbank2.to_pay* Rat.new(164,$more_than_promile)));
# Prowizja
$mbank2.add(AnnualCostConst.new(from=>1, to=>1, value=>$mbank2.to_pay * Rat.new(1,$percent)));
# ubezp
$mbank2.add(AnnualCostMort.new(from=>25, to=>60, interest => Rat.new(4,$percent)));
$mbank2.add(AnnualCostConst.new(from=>1, to=>360, value => Rat.new(2145,$PLN_GR)));

my $mbank = Mortage.new(bank=>"MBANK",interest => Rat.new(330,$more_than_percent), mortage=>Rat.new(130073,$PLN_GR));
# polisa
$mbank.add(AnnualCostConst.new(from=>1, to=>1, value=>$mbank.to_pay * Rat.new(164,$more_than_promile)));
# Prowizja
$mbank.add(AnnualCostConst.new(from=>1, to=>1, value=>$mbank.to_pay * Rat.new(1,$percent)));
# ubezp
$mbank.add(AnnualCostMort.new(from=>25, to=>60, interest => Rat.new(4,$percent)));
$mbank.add(AnnualCostConst.new(from=>1, to=>360, value => Rat.new(2145,$PLN_GR)));



my $db = Mortage.new(bank=>"DB",interest => Rat.new(324,$more_than_percent), mortage=>Rat.new(129093,$PLN_GR));
#POlisa DBIWP
$db.add(DBIWP.new(from=>1, to=>120,
                            cumulation=>$db.to_pay * Rat.new(108,$more_than_promile),
                            antiinterest => Rat.new(2,$percent)));
$db.add(AnnualCostPercentage.new(from=>1, to=>12, interest=>Rat.new(-39,$more_than_percent)));
$db.add(AnnualCostPercentage.new(from=>25, to=>66, interest => Rat.new(20,$more_than_percent)));
$db.add(AnnualCostConst.new(from=>1, to=>360, value=>20));
#$db.add(AnnualCostConst.new(from=>1, to=>360, value=>3));


say $mbank.calc_mortage.round(0.01);
say $mbank2.calc_mortage.round(0.01);
say $db.calc_mortage.round(0.01);



$mbank.calc;
$mbank2.calc;
$db.calc;

say "Done";
say $mbank;
say $mbank2;
say $db;

