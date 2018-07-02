LendingClub
==========

[Lending Club API](https://www.lendingclub.com/developers/lc-api.action).  

SYNOPSIS
===========

A wrapper for the Lending Club API. It wraps all of the functions they currently provide. In the below examples, I modified the return #'s for my example query. 

EXAMPLE
=======
```p6
use LendingClub;
use Data::Dump;

my $lc = LendingClub.new(token => 'somesecrettoken', accountId => 12345 ); 

say Dump $lc.summary;'

=begin output
{
  accountTotal         => 1000000000.00.Rat,
  accruedInterest      => 1.00.Rat,
  availableCash        => 100.00.Rat,
  infundingBalance     => 100.Int,
  investorId           => 12345.Int,
  outstandingPrincipal => 100000000.Rat,
  receivedInterest     => 1.00.Rat,
  receivedLateFees     => 0.Int,
  receivedPrincipal    => 10.00.Rat,
  totalNotes           => 111.Int,
  totalPortfolios      => 5.Int,
}
=end output

my $dt = DateTime.new( year => 2016, month => 3, day => 3); 
my $transfer = $lc.transferFunds( "LOAD_ONCE", 50.00, $dt.Str );

$lc.cancelTransfers( [ $transfer<transfers>[0]<transferId> ] );

my $avail_notes = $lc.listing;

# .... Some code to decide what notes to invest in from the list.....

$lc.submitOrders( 12345, @some_notes_i_want );


```

INSTALLATION
============
     > panda install LendingClub

DEPENDENCIES
============
* [JSON::Tiny](https://github.com/moritz/json)
* [Net::HTTP](https://github.com/ugexe/Perl6-Net--HTTP)

METHODS
=======
> Queries for info.

* summary
* availableCash
* pending
* notes
* detailedNotes
* portfolios
* listing( Bool $showAll = False )

> Actions that affect your account.

* transerFunds( Str $transferFrequency, Rat() $amount, Str $startDate?, Str $endDate?, )
* cancelTransfers( @transferIds )
* createPortfolio( Int $aid, Str $portfolioName, Str $portfolioDescription? )
* submitOrders( Int $aid, @orders )
** aid is your account number. 

BUGS
====

* I haven't tested it as thoroughly as I wanted. Specifically I don't have multiple account types(investing, and retirement) so  I don't know if it works right for people with both.
* Setting listing to true attempts to get ALL notes on the Lending Club platform. Using a true value for the listing method crashes on my system. I haven't looked into why.


TODO/HELP PLEASE
====
* More/better tests.

AUTHOR
======

James (Jeremy) Carman <developer@peelle.org>

ACKNOWLEDGEMENTS
================

* Mad thanks to [ugexe](https://github.com/ugexe) for accepting my pull request. Without his awesome [Net::HTTP::*](https://github.com/ugexe/Perl6-Net--HTTP) modules, I would have given up on this module. It was the third module of this type I tried.

