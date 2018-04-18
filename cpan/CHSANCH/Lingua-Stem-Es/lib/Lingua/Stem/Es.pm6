#! /usr/bin/env false

use v6.c;

unit module Lingua::Stem::Es;

my $rvowels = rx/<[aeiouáéíóúü]>/;
my $rconsonants = rx/<[bcdfghjklmnñpqrstvwxyz]>/;

sub stem(Str $word is copy --> Str) is export {
	$word .= lc;
	$word .= subst(/<:punct>/, '', :g);

	my $RV = define-RV($word);
	my $suffix = '';

	# step 0
	if $RV {
		my $pronoun =
		rx/(selas||selos||sela||selo||las||les||los||nos||me||se||la||le||lo)$/;

		if  $RV ~~ / [ándo||iéndo||ár||ér||ír] (<$pronoun>) $/ {
			$suffix = $0;
			$word ~~ s/$suffix$//;
			$word ~~ s/á/a/;
			$word ~~ s/é/e/;
			$word ~~ s/í/i/;
			$word ~~ s/ó/o/;
			$word ~~ s/ú/u/;
			$word ~~ s/ü/u/;
			
		} 

		elsif $RV ~~ / [ando||iendo||ar||er||ir] (<$pronoun>) $/ {
			$suffix = $0;
			$word ~~ s/$suffix$//;
			
		} 

		elsif $word ~~ /uyendo (<$pronoun>) $/ and $RV ~~ /yendo <$pronoun> $/ { 
			$suffix = $0;
			$word ~~ s/$suffix$//;
			
		}

	}

	# step 1
	$RV = define-RV($word);
	my $R1 = define-R1($word);
	my $R2 = define-R2($word);

	if $R2 ~~ /(amientos||imientos||amiento||imiento||anzas||ismos||ables||ibles||istas
				||anza||icos||icas||ismo||able||ible||ista||osos||osas||ico||ica||oso||
				osa)$/ {
		$suffix = $0;
		$word ~~ s/$suffix$//;
			
	}
	elsif $R2 ~~ /(aciones||adores||adoras||adora||antes?||ancias?||ación||ador)$/ {
		$suffix = $0;
		if $R2 ~~ /ic$suffix$/ {
			$word ~~ s/ic$suffix$//;
			
		} else {
			$word ~~ s/$suffix$//;
			
		}
	}
	elsif $R2 ~~ /(logías?)$/ {
		$suffix = $0;
		$word ~~ s/$suffix/log/;
			
	}
	elsif $R2 ~~ /uci(ones||ón)$/ {
		$suffix = $0;
		$word ~~ s/uci$suffix$/u/;
			
	}
	elsif $R2 ~~ /(encias?)$/ {
		$suffix = $0;
		$word ~~ s/$suffix$/ente/;
			
	}
	elsif $R1 ~~ /amente$/ {
		if $R2 ~~ /(os||ic||ad)amente$/ {
			$suffix = $0;
			$word ~~ s/($suffix)amente$//;
			
		}
		elsif $R2 ~~ / ( [ at <?before iv> ] ? [iv] ) amente $/ {
			$suffix = $0;
			$word ~~ s/($suffix)amente$//;
			
		} 
		else {
			$word ~~ s/amente$//;
			
		}
	}
	elsif $R2 ~~ /mente$/ {
		if $R2 ~~ / ( <[ai]>ble || ante ) mente $/ {
			$suffix = $0;
			$word ~~ s/($suffix)mente$//;
			
		} else {
			$word ~~ s/mente$//;
			
		}
	}
	elsif $R2 ~~ /idad(es)?$/ {
		if $R2 ~~ /(abil || ic || iv) idad (es)? $/ {
			$suffix = $0;
			$word ~~ s/(abil||ic||iv) idad (es)? $//;
		} else {
			$word ~~ s/idad(es)?$//;
		}
		
	}

	elsif ( $R2 ~~ / (iv<[ao]>s?) $/ ) {
		$suffix = $0;
		$R2 ~~ /at$suffix$/ 
		?? $word ~~ s/at$suffix$// 
		!! $word ~~ s/$suffix$//;
			

	}
	# # Step 2a
	elsif $word ~~ /u(yeron||yendo||yamos||yais||ya<[ns]>?||ye<[ns]>?||yo||yó)$/ and 
		  $RV ~~ /(yeron||yendo||yamos||yais||ya<[ns]>?||ye<[ns]>?||yo||yó)$/ { 
			  $word ~~ s/u(yeron||yendo||yamos||yais||ya<[ns]>?||ye<[ns]>?||yo||yó)$/u/;
			
	}
	# ## Step 2b
	elsif $RV ~~ /(iésemos||iéramos||iríamos||eríamos||aríamos||ásemos||áramos||ábamos
				  ||isteis||asteis||ieseis||ierais||iremos||iríais||eremos||eríais
				  ||aremos||aríais||aseis||arais||abais||ieses||ieras||iendo||ieron
				  ||iesen||ieran||iréis||irías||irían||eréis||erías||erían||aréis||arías
				  ||arían||íamos||imos||amos||idos||ados||íais||ases||aras||idas||adas
				  ||abas||ando||aron||asen||aran||aban||iste||aste||iese||iera||iría||irás
				  ||irán||ería||erás||erán||aría||arás||arán||áis||ías||ido||ado||ían||ase
				  ||ara||ida||ada||aba||iré||irá||eré||erá||aré||ará||ís||as||ir||er||ar||ió||an
				  ||id||ed||ad||ía)$/ {
			$suffix = $0;
			$word ~~ s/$suffix$//;
			
	}
	elsif $RV ~~ /(emos||éis||en||es)$/ {
		$suffix = $0;
		$word ~~ /gu$suffix$/ 
			  ?? $word ~~ s/gu$suffix$/g/ 
			  !! $word ~~ s/$suffix$//;
			
	}
	
	# # Step 3
	$RV = define-RV($word);
	if $RV ~~ /(os || <[aoáíó]>)$/ {	
		$suffix = $0;
		$word ~~ s/$suffix$//;
			
	}
	elsif $RV ~~ /<[eé]>$/ {
		if $word ~~ /gu<[eé]>$/ and $RV ~~ /u<[eé]>$/ {
			$word ~~ s/gu<[eé]>$/g/;
			
		}
		else {
			$word ~~ s/<[eé]>$//;
			
		}
	}

	# # step 4
	$word ~~ s:g/á/a/;
    $word ~~ s:g/é/e/;
    $word ~~ s:g/í/i/;
    $word ~~ s:g/ó/o/;
    $word ~~ s:g/ú/u/;

	# 		
	return $word;
}

sub define-R1(Str $word --> Str) {
	my $R1 = '';
	$R1 = $0.Str if $word ~~ / ^ .*? <$rvowels> <$rconsonants> (.*) $/;
	return $R1;
}

sub define-R2(Str $word --> Str) {
	my $R2 = '';
	$R2 = $0.Str if $word ~~ / ^ .*? <$rvowels> <$rconsonants> .*? <$rvowels> 
	<$rconsonants> (.*) $/;
	return $R2;
}

sub define-RV(Str $word --> Str) {
	my $RV;
	given $word {
		when / ^ . <$rconsonants> .*? <$rvowels> (.*) $/ {
			$RV = $0.Str;
		}
		when / ^ <$rvowels> ** 2 <$rconsonants> (.*) $/ {
			$RV = $0.Str;
		}
		when / ^ <$rconsonants> <$rvowels> . (.*) $/ {
			$RV = $0.Str;
		}
		default {
			$RV = '';
		}
	}	
}

# vim: ft=perl6 noet
