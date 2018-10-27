use v6;
use Mortgage;

#########
## PKO ##
#########
my $pko = Mortgage.new(currency=>"PLN",bank=>"PKO", interest_rate => rate-monthly(3.53), mortage=>1338.64,mortages=>360, loan-left=>297000);
# Obnizone oprocentowanie
$pko.add(AnnualCostPercentage.new(from=>1, to=>12, interest_rate=>rate-monthly(-0.43)));
# Oplata za konto
$pko.add(AnnualCostConst.new(from=>1, to=>360, value=>0*5/3));
# Pseudo polisa
$pko.add(AnnualCostConst.new(from=>1, to=>1, value=> basis-point(325)*$pko.loan-left));
#Podwyzszenie marzy
$pko.add(AnnualCostMort.new(from=>1, to=>64, interest_rate => rate-monthly(0.25)));
#Wycena
$pko.add(AnnualCostConst.new(from=>1, to=>1, value=>400));

$pko.calc;

say "Done";
say $pko;


