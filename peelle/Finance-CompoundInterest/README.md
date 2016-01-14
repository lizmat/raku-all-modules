Finance::CompoundInterest
==========

Subroutines for calculating compound interest.

SYNOPSIS
===========
I started a Lending Club account. While waiting on it to open I thought, What if I put in $5000, and assume I will make the minimum 6%? I can leave it alone and just come back after those three year notes done. What will that look like?

```
	use Finance::CompoundInterest;

	say compound_interest 
			5000, 	# My initial payment, or principal
			.005, 	# Since it compounds monthly and that 6% really means yearly, it should be .06 / 12
			36, 	# Number of months we expect it to compound.
			3;	# At year 3 how will this look.
		
```

>5075.56003652364

Well that's kinda cruddy. I can't retire to the Bahamas on that. I can't own a luxury yacht with a butler. Oh wait, for that matter I don't actually have $5K lying around. I live paycheck to paycheck like most everyone else I know.

What if I throw $150 a month into it, every month, for the next three years. How is it gonna look then?

```
	say compound_interest_with_payments
			150, 	# $150 every month.
			.005, 	# I wish that was .06 monthly
			36; 	# Number of months we expect it to compound.
		
```

>5900.41574470244

Woohoo! I already out performed the first one! Using some multiplication and subtraction, I can see that I put in a little more money $5400, but I got way more interest out. $500 in interest. ChaChing!

What is this gonna look like if I can keep it up until I am 75? Lets see I'm 32 now, so I got another 43 years.

```
	say compound_interest_with_payments
			150, 		# $150 every month.
			.005, 		# .06 / 12
			43 * 12; 	# Number of months we expect it to compound.
		
```

>363377.142315735

Now that is a chunk of change, and I only put in $1,800 a year.

But wait, I am a programmer. I am totally smarter than all those other guys that use their gut to choose stocks, loans, ponies, etc. I can use ~~spread sheets~~ databases, to comb through the data and make better choices.

Lending Club says their returns are between 6% and 10%. Lets assume I can hit that 10% mark. How many payment periods will it take me to get to the same dollar amount? 

```
	say ciwp_payment_period
			363377, 	# Final amount.
			.0083, 		# We gotz skillz. 10% anually.
			150; 		# Monthly payments.
```

>368.944160846191

Sweet, so I went from 516(43x12) contributions to 369(30.75x12). Sweet, almost 13 years saved! I knew learning  ~~spread sheets~~ databases would pay off someday.

Hold on, not only am I a programmer, but I am a proper lazy Perl programmer. I don't wanna be working until I am 75, or 63! I wanna go live on that island, programming Perl, and sipping Mojitos sooner rather than later.

How much $$ do I need to put in to get this done in 20 years at age 52? Just over the hill, and out the door.

```
	say ciwp_payment_size
			363377, 	# Final amount.
			.0083, 		# Interest.
			20 * 12; 	# Number of months we want it to compound.
```

>481.012899065815

About $481 a month? That's a bit rough, but doable. Island life is the life for me!

DESCRIPTION
===========

* **I am not a certified financial anything. Use at your own ruination.**

These modules were created to scratch my own itch. They do some simple financial calculations related to compound interest, so I can count my imaginary money.

CAVEATS
====
* I am **not** a certified financial anything. Use at your own financial risk.
* My example calculations do not take into account any of that real world stuff, like taxes, fees, risk, giant spiders, or economic collapse.


BUGS
====

* Did I mention that I am not a certified financial person? Double check me and submit patches. :).
* This uses the built in Rat data type. The Perl 6 tutorial said limited precision. 

TODO/HELP PLEASE
====
* To return the interest rate, given a final amount, payments, and periods.
* Add a formula where starting amount and periodic payments differ.
* Add a formula where payments more or less frequently added than the interest compounds. 
* Add in other types of compound interest formulas.
* Make it more Perl6-ey

AUTHOR
======

James (Jeremy) Carman <developer@peelle.org>

ACKNOWLEDGEMENTS
================

This README is shamelessly based on other Perl6 modules. So is my module layout, tests, and other not code files. Thank you for figuring this out first so I didn't have to.
