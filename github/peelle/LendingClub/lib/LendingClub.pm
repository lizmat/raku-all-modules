class LendingClub {

	has Str $.token;
	has Int $.accountId is rw;
	has Str $.version = 'v1';
	has Str $.uri = "https://api.lendingclub.com/api/investor/$!version/accounts/$!accountId/";

	use JSON::Tiny;
	use Net::HTTP::GET;
	use Net::HTTP::POST;

	method !request (Str $type where { $type eq 'GET'|'POST' }, Str $api_call, %body? ) returns Hash {
		my $uri = self.uri ~ $api_call;
		my %header = ( Accept => 'application/json', Authorization => $!token );
		my $results;

		if $type eq 'GET' {
			$uri ~~ s/accounts.*/loans\/$api_call/ if $api_call ~~ /listing/; # A quick hack for dealing with the one not accounts method.
			$results = Net::HTTP::GET( $uri, :%header );
		} else {
			%header<Content-type> = 'application/json'; # Only needed for Posts
			my $body = Buf.new(  (to-json( %body ).ords) );

			$results = Net::HTTP::POST( $uri, :%header, :$body );
		}

		given $results.status-code {
			when 200 { from-json $results.content :force }
			when 400 { { error => 'Execution failed with errors. Errors will be returned as JSON payload.', message => from-json $results.content :force } }
			when 403 { { error => 'Authentication failure.' } }
			when 404 { { error => 'Resource does not exist.' } }
			when 500 { { error => 'Unsuccessful execution.' } }
			default  { { error => 'Unkown error.', status-code => $results.status-code } }
		}
	}

	### GET REQUESTS ###

	method summary {
		return self!request('GET', 'summary');
	}

	method availableCash {
		return self!request('GET', 'availablecash');
	}

	method pending {
		return self!request('GET', 'funds/pending');
	}
	
	method notes {
		return self!request('GET', 'notes');
	}

	method detailedNotes {
		return self!request('GET', 'detailednotes');
	}

	method portfolios {
		return self!request('GET', 'portfolios');
	}

	method listing (Bool $showAll = False) {
		return self!request('GET', 'listing?showAll=true') if $showAll; # Currently crashes after 4+ minutes of I'm guess is weating or downloading.

		return self!request('GET', 'listing');
	}

	### POST REQUESTS ###

	method transferFunds ( 
			Str$transferFrequency where { $transferFrequency eq  'LOAD_NOW'|'LOAD_ONCE'|'LOAD_WEEKLY'|'LOAD_BIWEEKLY'|'LOAD_ON_DAY_1_AND_16'|'LOAD_MONTHLY'},
			Rat() $amount, 
			Str $startDate?,
			Str $endDate?,
	) {
		return self!request('POST', 'funds/add', { :$transferFrequency, :$amount, :$startDate, :$endDate } );
	}

	method cancelTransfers ( @transferIds ) {
		return self!request('POST', 'funds/cancel', { :@transferIds } );
	}

	method createPortfolio ( Int $aid, Str $portfolioName, Str $portfolioDescription?) {
			return self!request('POST', 'portfolios', { :$aid, :$portfolioName, :$portfolioDescription } );
	}

	method submitOrders ( Int $aid,  @orders ) {
		return self!request('POST', 'orders', { :$aid, :@orders } );
	}
			
}
