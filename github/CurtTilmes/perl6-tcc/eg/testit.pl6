use v6;
use TCC;

# Make a new Tiny C Compiler
my $tcc = TCC.new('-I/usr/local/include -L/usr/local/lib -DDEBUG=0');

# Compile a C program into memory
$tcc.compile:
'
    #include <stdio.h>
    int add(int a, int b);  /* declare perl functions to quiet warnings */
    void print_something(char *my_string);

    int x = 7;

    int fib(int n)
    {
        if (n <= 2)
            return 1;
        else
            return fib(n-1) + fib(n-2);
    }

    int foo(int n)
    {
        printf("Hello World!\n");
        printf("fib(%d) = %d\n", n, fib(n));
        printf("add(%d, %d) = %d\n", n, 2 * n, add(n, 2 * n));

        print_something("this is just a test");

        if (DEBUG) { print_something("debug is on"); }

        return 0;
    }

    int set_x(int n)
    {
        x = n;
    }
';

# These are just perl subs for C to call
sub add(int32 $a, int32 $b --> int32)
{
    return $a + $b;
}

# This one gets renamed to 'print_something' for C
sub print-something(Str $my-string)
{
    say $my-string;
}

# Add some perl subs for C to call
$tcc.add-symbol(&add);
$tcc.add-symbol(&print-something, name => 'print_something');

# You just have to do this, so do it.
$tcc.relocate;

# Bind C functions to perl callable variables, must pass in signature
my &fib   := $tcc.bind('fib', :(int32 --> int32));
my &foo   := $tcc.bind('foo', :(int32 --> int32));
my &set_x := $tcc.bind('set_x', :(int32 --> int32));

# Bind Perl variable to C symbol, pass in type and an optional function
# to set the variable if you want to go both ways
my $x     := $tcc.bind('x', int32, &set_x);

# Once everything is compiled and bound, just work in Perl land like normal:

say fib(12);

foo(17);

say $x;

set_x(12345);

say $x;

$x = 752;

say $x;
