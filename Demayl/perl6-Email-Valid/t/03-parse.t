use v6;
use Test;

plan 2;

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
