#!perl6

use v6;
use Test;
use lib '../lib';
use Grammar::Modelica;

plan 90; 

grammar TestString is Grammar::Modelica {
  rule TOP {^<STRING>$}
}
ok TestString.parse('"Pizza&Stuff"');
ok TestString.parse('"This should be a good string...\\r\\n"');

ok TestString.parse('"Pizza९Stuff"');
ok TestString.parse('"Pizza ९Stuff"');
ok TestString.parse('"Pizza ९Stuff"');
nok TestString.parse('"Pizza"&"Stuff"');
ok TestString.parse('"Pizza\\"&\\"Stuff"');
nok TestString.parse('"Pizza\\Stuff"');
ok TestString.parse('"Pizza\\\\Stuff"');

grammar TestQChar is Grammar::Modelica {
  rule TOP {^<Q-CHAR>$}
}
ok TestQChar.parse('P');
ok TestQChar.parse('9');
ok TestQChar.parse('&');
ok TestQChar.parse('#');
nok TestQChar.parse('९');

grammar TestSChar is Grammar::Modelica {
  rule TOP {^<S-CHAR>$}
}
ok TestSChar.parse('P');
ok TestSChar.parse('9');
ok TestSChar.parse('&');
ok TestSChar.parse('#');
ok TestSChar.parse('९');

grammar TestQIdent is Grammar::Modelica {
  rule TOP {^<Q-IDENT>$}
}
ok TestQIdent.parse("'Pizza_Stuff123'");

grammar TestBaseIdent is Grammar::Modelica {
  rule TOP {^<BASEIDENT>$}
}
ok TestBaseIdent.parse("Pizza_Stuff123");
ok TestBaseIdent.parse("ifPizza_Stuff123");
ok TestBaseIdent.parse("within");
ok TestBaseIdent.parse("encapsulated");

grammar TestKeywords is Grammar::Modelica {
  regex TOP {^<keywords>$}
}

nok TestKeywords.parse("Pizza_Stuff123");
nok TestKeywords.parse("ifPizza_Stuff123");
ok TestKeywords.parse("within");
ok TestKeywords.parse("break");

grammar TestIDENT is Grammar::Modelica {
  regex TOP {^<IDENT>$}
}

ok TestIDENT.parse("Pizza_Stuff123");
nok TestIDENT.parse(" Pizza_Stuff123");
nok TestIDENT.parse("Pizza_Stuff123 ");
ok TestIDENT.parse("ifPizza_Stuff123");
nok TestIDENT.parse("within") ,'Should disalow keywords as IDENT';
ok TestIDENT.parse("withincow");

grammar TestName is Grammar::Modelica {
  rule TOP {^<name>$}
}
ok TestName.parse('Pizza_Stuff123');
ok TestName.parse("'Pizza_Stuff123'");
ok TestName.parse("'within'");
nok TestName.parse("9wrong");
nok TestName.parse('$wrong');
nok TestName.parse('wr९ng');
ok TestName.parse("_fine");
ok TestName.parse("ThisShouldBeFine");
ok TestName.parse("ThisShouldBeFine.Too");
ok TestName.parse("AndThisShouldBeFine.Too");
ok TestName.parse("AndThisShouldBeFineif.Too");
ok TestName.parse("withincow");
nok TestName.parse("within");
nok TestName.parse(".within");
nok TestName.parse("ThisShouldBeFine.not");
nok TestName.parse("not.ThisShouldBeFine");
nok TestName.parse(".AndThisShouldBeFine.not");
nok TestName.parse(".AndThisShouldBeFine.not.Allright");

grammar TestCComment is Grammar::Modelica {
  rule TOP {^<c-comment>$}
}

ok TestCComment.parse('//this is a comment');
ok TestCComment.parse('//this is a comment ');
ok TestCComment.parse('/*this is a comment*/');

grammar TestWS is Grammar::Modelica {
  rule TOP {^<ws>$}
}

ok TestWS.parse(' //this is a comment');
ok TestWS.parse(' //this is a comment ९');
ok TestWS.parse('//this is a comment ');
ok TestWS.parse('/*this is a comment*/ ');
ok TestWS.parse('/*this is a comment९*/ ');
ok TestWS.parse(' /*this is a comment*/');
ok TestWS.parse(" /*this is a comment*/\n");
ok TestWS.parse(" /*this is\n a comment*/\n");
nok TestWS.parse(" //*this is\n a comment*/\n");
nok TestWS.parse('cow /*this is a comment*/');
nok TestWS.parse('/*this is a comment*/ cow');
nok TestWS.parse("//this is a comment\nnot this though...");

grammar TestWS2 is Grammar::Modelica {
  rule TOP {^<IDENT><ws><IDENT>$}
}

ok TestWS2.parse('cow/*this is a comment*/ cow');
ok TestWS2.parse('cow/*this is a comment*/cow');
ok TestWS2.parse('cow /*this is a comment*/cow');
ok TestWS2.parse("cow /*this is a comment*/\ncow");
ok TestWS2.parse("cow//this is a comment\ncow");

grammar TestUnsignedInteger is Grammar::Modelica {
  rule TOP {^<UNSIGNED_INTEGER>$}
}

ok TestUnsignedInteger.parse('12');
nok TestUnsignedInteger.parse('1 2');

grammar TestUnsignedNumber is Grammar::Modelica {
  rule TOP {^<UNSIGNED_NUMBER>$}
}

ok TestUnsignedNumber.parse('12');
ok TestUnsignedNumber.parse('12.');
nok TestUnsignedNumber.parse('1 2');
ok TestUnsignedNumber.parse('12.34');
nok TestUnsignedNumber.parse('12 .34');
nok TestUnsignedNumber.parse('12. 34');
ok TestUnsignedNumber.parse('12.34e-56');
ok TestUnsignedNumber.parse('12.34E-56');
ok TestUnsignedNumber.parse('12.34e+56');
ok TestUnsignedNumber.parse('1.e4');
ok TestUnsignedNumber.parse('1.0e4');
nok TestUnsignedNumber.parse('12.34 e+56');
nok TestUnsignedNumber.parse('12.34e +56');
nok TestUnsignedNumber.parse('12.34e+ 56');
nok TestUnsignedNumber.parse('12.34e+56 ');
nok TestUnsignedNumber.parse(' 12.34e+56');
