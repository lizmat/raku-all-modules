# mortgage6

Mortgage6 is little but usable library that allows to calculate all costs of mortage. Since banks give a lot of discounts if buying their products it is harder see the costs

## install
    zef install Mortgage

## doc
    p6doc Mortgage
or [POD](https://github.com/teodozjan/mortage6/blob/master/lib/Mortgage.pm6)

## QuickStart

```perl6
my $bank = Mortgage.new(bank=>"BANK2",interest_rate => rate-monthly(3.30), mortage=> 1300.73, mortages => 360, loan-left=> 297000.FatRat);

# Arrangement fee
$bank.add(Mortgage::AnnualCostConst.new(from=>1, to=>1, value=>$bank.loan-left * percent 1));

# Should give the same amount you have from bank
my $mortgage =  $bank.calc_mortage;

# Do the sim
$bank.calc;

my $loanleft = $bank.loan-left.round(0.01);
my $total_cost = $bank.total_cost.round(0.01);
my $total_interest= $bank.total_interest.round(0.01);
```
