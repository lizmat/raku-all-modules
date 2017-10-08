use v6;
use TCC;
use Test;

plan 4;

my $tcc = TCC.new('-Dthis=1');

$tcc.compile: '
    int c_var = 7;
    int perl_add(int a, int b);
    int c_add(int a, int b)
    {
        return a+b;
    }
    int store_c_var(int val)
    {
        return c_var = val;
    }
    int call_perl(int a, int b)
    {
        return perl_add(a, b);
    }
';

sub add(int32 $a, int32 $b --> int32)
{
    $a+$b;
}

$tcc.add-symbol(&add, name => 'perl_add');

$tcc.relocate;

my &c-add := $tcc.bind('c_add', :(int32, int32 --> int32));
my &store-c-var := $tcc.bind('store_c_var', :(int32 --> int32));
my &call-perl := $tcc.bind('call_perl', :(int32, int32 --> int32));
my $c-var := $tcc.bind('c_var', int32, &store-c-var);

is $c-var, 7, 'Read C variable';

$c-var = 12;

is $c-var, 12, 'Set C variable';

is c-add(5, 12), 17, 'Call C function';

is call-perl(22, 83), 105, 'C calls perl';
