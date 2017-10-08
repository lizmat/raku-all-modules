use v6;
use Test;

plan 5;

use Email::Valid;
my $email = Email::Valid.new();

sub validate(Str $mail!, Str $box!, Str $domain! ){
    my $p = $email.parse($mail) || return False;

    return $p<email><mailbox> eq $box && $p<email><domain> eq $domain;
}

is [
    validate( 'string', 'a', 'b' ),
    validate( 'string@', 'a', 'b' ), 
    validate( 'w asd@wt', 'a', 'b' ), 
    validate( 'wasd@wt', 'a', 'b' ), 
    validate( 'wasd@wt.', 'a', 'b' ), 
    validate( '-wasd@wt.bg', 'a', 'b' ), 
    validate( 'wasd-@wt.bg', 'a', 'b' ), 
    validate( 'wa.@wt.bg', 'a', 'b' ), 
    validate( '.wa@wt.bg', 'a', 'b' ), 
    validate( 'wa@-wt.bg', 'a', 'b' ), 
    validate( 'wa@wt-.bg', 'a', 'b' ), 
    validate( 'wa@wt.-aa.bg', 'a', 'b' ), 
    validate( 'wa@wt..bg', 'a', 'b' ), 
    validate( 'wa@wt.b', 'a', 'b' ), 
    validate( '12345678901234567890123456789012345678901234567890123456789012345@aa.tr', 'a', 'b' ), 
    validate( 'wtf@1234567890123456789012345678901234567890123456789012345678901234.tr', 'a', 'b' ), 
    validate( 'wtf@'~("1234567890." xx 4).join~'a.tr', 'a', 'b' ), 
    validate( 'wtf@'~((("a" xx 63).join~'.') xx 3).join~'a.traftagag', 'a', 'b' ), 
    ], [ False xx 18 ],
'Invalid emails';

is [
    validate( 'ta@aa.ch', 'ta', 'aa.ch' ),
    validate( 'ta@a.ch', 'ta', 'a.ch' ),
    validate( 'test@gmail.co.uk', 'test', 'gmail.co.uk' ),
    validate( 'test@wa-te.uk', 'test', 'wa-te.uk' ),
    validate( 'test+box@wa-te.uk', 'test+box', 'wa-te.uk' ),
    validate( 'кутия@xn--c1arf.xn--e1aybc.xn--90ae', 'кутия', 'xn--c1arf.xn--e1aybc.xn--90ae' ),
    validate( 'кутия@тест.ру', 'кутия', 'тест.ру' ),
    ], [ True xx 7 ],
'Simple mails';

my $ipv4   = Email::Valid.new( :allow-ip, :allow-local );
my $local  = $ipv4.parse('aa@[10.0.0.1]')<email><domain>;
my $public = $ipv4.parse('aa@[195.15.15.15]')<email><domain>;


is [ $local.Str, $local<ipv4-host>.Str, $local<ipv4-host><ipv4-local> ], [ '[10.0.0.1]', '10.0.0.1' xx 2 ], 'Parse local IPv4';
is [ $public.Str, $public<ipv4-host>.Str, $public<ipv4-host><ipv4>.Str], [ '[195.15.15.15]', '195.15.15.15' xx 2 ], 'Parse public IPv4';

my $quote = Email::Valid.new( :allow-quoted );

my $box  = $quote.parse('"test"@omg.bg')<email><mailbox><quoted>;
my $box2 = $quote.parse('" "@omg.bg')<email><mailbox><quoted>;
my $box3 = $quote.parse('" ; omg box"@omg.bg')<email><mailbox><quoted>;

is [ $box, $box2, $box3 ], ['"test"', '" "', '" ; omg box"'], 'Parse quoted email';
