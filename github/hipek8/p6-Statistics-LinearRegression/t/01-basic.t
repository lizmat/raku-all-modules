use v6;
use Test;
use Statistics::LinearRegression :ALL;

my @x = 1,2,3;
my @y = 2,4,6;
my ($slope, $intercept) = get-parameters(@x,@y);
is $slope, 2;
is $intercept, 0;
is value-at(5, $slope, $intercept), 10;
@y = 1,1,1;
($slope, $intercept) = get-parameters(@x,@y);
is $slope, 0;
is $intercept, 1;
is value-at(134.5, $slope, $intercept), 1;

@y= 3,2,1;
my LR $model .= new: @x, @y;
($slope, $intercept) = $model.get-parameters;
is $slope, -1;
is $intercept, 4;
is $model.at(5), -1;
done-testing;
