use Test;
plan 17;
use CompUnit::Util :find-loaded,:load,:all-loaded,:at-unit,:unit-to-hash;
use MONKEY-SEE-NO-EVAL;

ok my $native-call = load('NativeCall'),'load';
ok $native-call === load('NativeCall'), 'load again returns same thing';

ok find-loaded('Test') ~~ CompUnit:D, 'found Test';
ok find-loaded('CompUnit::Util') ~~ CompUnit:D, 'found CompUnit::Util';
nok find-loaded('Foo'),'find-loaded on non-existent module returns false';
ok find-loaded('Foo') ~~ Failure:D,'returns Failure';

ok all-loaded()».short-name.pick(*) ~~ set('CompUnit::Util','NativeCall','Test'),
"all-loaded finds the correct units";

my $cu = load('CompUnit::Util');
my $pod = at-unit('CompUnit::Util','$=pod')[0];
ok  $pod ~~ Pod::Block:D, 'at-unit finds $=pod';
ok at-unit($cu,'$=pod')[0] === $pod,'at-units works with CompUnit';
ok at-unit($cu.handle,'$=pod')[0] === $pod,'at-units works with CompUnit::Handle';

# EVAL because of strange warning about failure
EVAL q|ok at-unit($cu,'EXPORT::at-unit::&at-unit') === &at-unit|;


ok unit-to-hash($cu)<$=pod>[0] === $pod, 'unit-to-hash returns same thing';


{
    EVAL q|
        use CompUnit::Util :set-in-WHO,:descend-WHO;
        my package tmp {};
        BEGIN set-in-WHO(tmp.WHO,'Foo','foo');
        is tmp::Foo,'foo','set-in-WHO 1 name';
        is descend-WHO(tmp.WHO,'Foo'),'foo';
    |;
}

{
    EVAL q|
        use CompUnit::Util :set-in-WHO,:descend-WHO;
        my package tmp {};
        BEGIN set-in-WHO(tmp.WHO,'Foo::Bar::$Baz','bar');
        is tmp::Foo::Bar::<$Baz>,'bar','set-in-WHO multiple';
        is descend-WHO(tmp.WHO,'Foo::Bar::$Baz'),'bar','descend-WHO finds $Baz';
        is descend-WHO(tmp.WHO,'Baz::Foo::$Bar'),Nil,<doesn't find non existent>;
    |;

}
