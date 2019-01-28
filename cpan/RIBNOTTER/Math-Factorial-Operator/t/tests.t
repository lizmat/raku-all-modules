use v6.c;
use Test;      # a Standard module included with Rakudo 
use lib 'lib';
use Factorial;

plan(6);

lives-ok {15!};
dies-ok {15.5!};
dies-ok {(1/5)!};
subtest(q[test results], {

		is 5! , 120;
		is 0! , 1;
		is 1! , 1;
});
subtest(q[factorial binds tighter than the exponent], {
	ok(5**2! == 5**2);
	ok(5**2! != 25!);
});
subtest(q[make sure we don't mess up normal not], 
		{
		plan(4);
		is !!True, True;
		nok !(1==1);
		ok !0;
		nok !1; 
})

