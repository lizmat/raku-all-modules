module Mofixes:ver<0.2.3>
{

# PREFIXES
	
	# Mnemonic

	# 1. Factorialize (credits to: https://perl6advent.wordpress.com/2013/12/22/day-22-a-catalogue-of-operator-types/)
	sub prefix:<mofact>(UInt $number) is export {
		[*] 2..$number;
	}

	sub prefix:<mofactadd>(UInt $number) is export {
		[+] 2..$number;
	}

	sub prefix:<mofactminus>(UInt $number) is export {
		[-] 2..$number;
	}

	sub prefix:<mofactdivide>(UInt $number) is export {
		[/] 2..$number;
	}
	
#`( #FIXME
	sub prefix:<l33t>($word, UInt $choice) is export {
		given $choice {
			when 0 { say "$word are n00b." }
			when 1 { say "$word are haxor." }
			when 2 { say "$word are suxxor." }
			when 3 { say "$word are pwned." }
			default { say "$word are haxor." }
		}
	} 
)
	# thanks to notviki aka zoffixznet for the type recommendation
	

# POSTFIXES
# 	(factorial)
	sub postfix:<!>(UInt $number) is export {
		[*] 2..$number;
	}

	sub postfix:<!+>(UInt $number) is export {
		[+] 2..$number;
	}

	sub postfix:<!->(UInt $number) is export {
		[-] 2.. $number;
	}

	sub postfix:<!!d>(UInt $number) is export {
		[/] 2.. $number;
	}



# INFIXES
# CIRCUMFIXES
# POSTCIRCUMFIXES

	
}




