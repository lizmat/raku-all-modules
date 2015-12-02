use v6;
use Test;

plan 30;
use Email::Valid;
my Email::Valid $validator .= new();

nok $validator.validate('taaach'), 'taaach';
nok $validator.validate('ta@aach'), 'ta@aach';
nok $validator.validate('taaach@'), 'taaach@';
ok $validator.validate('ta@aa.ch'), 'ta@aa.ch';
nok $validator.validate('t@aa.ch'), 'ta@aa.ch';
ok $validator.validate('test@gmail.com'), 'test@gmail.com OK';
ok $validator.validate('t.123+asd@aa.tr'), 't.123+asd@aa.tr OK' ;
nok $validator.validate('-t.123+asd@aa.tr'), '-t.123+asd@aa.tr OK' ;
nok $validator.validate('t.123+asd-@aa.tr'), 't.123-@aa.tr OK' ;
nok $validator.validate('.ta@aa.tr'), '.ta@aa.tr OK' ;
nok $validator.validate('ta.@aa.tr'), 'ta.@aa.tr OK' ;
nok $validator.validate('ta@-aa.tr'), 'ta.@-aa.tr OK' ;
nok $validator.validate('ta@aa.-aa.tr'), 'ta.@aa.-aa.tr OK' ;
nok $validator.validate('test@aa-.tr'), 'test@aa-.tr OK' ;
nok $validator.validate('test@aa-.wt.tr'), 'test@aa-.wt.tr OK' ;
ok $validator.validate('ta@aa-wt.tr'), 'ta.@aa-wt.tr OK' ;
ok $validator.validate('ta@a.ch'), 'ta@a.ch OK' ;
nok $validator.validate('ta@a.c'), 'ta@a.c OK' ;
nok $validator.validate('12345678901234567890123456789012345678901234567890123456789012345@aa.tr'), 'Test long mailbox' ;
nok $validator.validate('wtf@1234567890123456789012345678901234567890123456789012345678901234.tr'), 'Test long host part 1' ;
ok $validator.validate('wtf@123456789012345678901234567890123456789012345678901234567890123.tr'), 'Test long host part 2' ;
ok $validator.validate('wtf@'~("1234567890." xx 3).join~'a.tr'), 'Subdomain number limit 1' ;
nok $validator.validate('wtf@'~("1234567890." xx 4).join~'a.tr'), 'Subdomain number limit 2' ;
nok $validator.validate('wtf@'~((("a" xx 63).join~'.') xx 3).join~'a.traftagag'), 'Domain length limit with 207 chars' ;
ok $validator.validate('wtf@'~((("a" xx 58).join~'.') xx 3).join~'a.tr'), 'Domain length limit with 185 chars' ;
ok $validator.validate('wtf@dom.trfgttrfgttrfgt'), 'Test long tld part 1' ;
ok $validator.validate('wtf@dom.trfgttrfgttrfg'), 'Test long tld part 2' ;
ok $validator.validate('box@xn--c1arf.xn--e1aybc.xn--90ae' ), 'IDN domain with idn TLD';
ok $validator.validate('кутия@xn--c1arf.xn--e1aybc.xn--90ae' ), 'IDN domain with idn TLD & cyrillic mailbox';
ok $validator.validate('кутия@тест.ру' ), 'Cyrillic mailbox & domain';

