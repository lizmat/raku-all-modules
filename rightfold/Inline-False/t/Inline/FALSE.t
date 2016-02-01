use v6.c;
use Inline::FALSE;
use IO::String;
use Test;

sub test($code, $expected) {
    my &program = Inline::FALSE::compile($code);
    my $actual = do {
        my $*OUT = IO::String.new;
        &program();
        ~$*OUT;
    };
    is($actual, $expected);
}

test(q:to/EOF/, "Hello, world!\n");
{Program that greets the world.}
"Hello, world!
"
EOF

test(q:to/EOF/, '123');
1a:
2b:
3c:
a;.
b;.
c;.
EOF

test(q:to/EOF/, 'abc');
["a"]["b"]\!!["c"]!
EOF

test(q:to/EOF/, 'b');
0["a"]?
1["b"]?
EOF

test(q:to/EOF/, '10');
0a:
[10a;>][1a;+a:]#
a;.
EOF

# http://rosettacode.org/wiki/Dot_product#FALSE
test(q:to/EOF/, '3');
[[\1-$0=~][$d;2*1+\-ø\$d;2+\-ø@*@+]#]p:
3d: {Vectors' length}
1 3 5_ 4 2_ 1_ d;$1+ø@*p;!%. {Output: 3}
EOF

# http://rosettacode.org/wiki/Prime_decomposition#FALSE
test(q:to/EOF/, '2 2 2 3 3 5 7 11');
[2[\$@$$*@>~][\$@$@$@$@\/*=$[%$." "$@\/\0~]?~[1+1|]?]#%.]d:
27720d;!   {2 2 2 3 3 5 7 11}
EOF

# http://rosettacode.org/wiki/FizzBuzz/EsoLang#FALSE
test(q:to/EOF/, (1..100).map({'Fizz' x $_ %% 3 ~ 'Buzz' x $_ %% 5 || $_}).join("\n") ~ "\n");
[\$@$@\/*=]d:
[1\$3d;!["Fizz"\%0\]?$5d;!["Buzz"\%0\]?\[$.]?"
"]f:
0[$100\>][1+f;!]#%
EOF

# http://rosettacode.org/wiki/Greatest_common_divisor#FALSE
test(q:to/EOF/, '5');
10 15$ [0=~][$@$@$@\/*-$]#%.
EOF

# http://rosettacode.org/wiki/Happy_numbers#FALSE
test(q:to/EOF/, 'Happy numbers: 1 7 10 13 19 23 28 31');
[$10/$10*@\-$*\]m:             {modulo squared and division}
[$m;![$9>][m;!@@+\]#$*+]s:     {sum of squares}
[$0[1ø1>][1ø3+ø3ø=|\1-\]#\%]f: {look for duplicates}

{check happy number}
[
  $1[f;!~2ø1=~&][1+\s;!@]#     {loop over sequence until 1 or duplicate}
  1ø1=                         {return value}
  \[$0=~][@%1-]#%              {drop sequence and counter}
]h:

0 1
"Happy numbers:"
[1ø8=~][h;![" "$.\1+\]?1+]#
%%
EOF

is(Inline::FALSE::compile('1z:')(), 1);

is(Inline::FALSE::compile('')(z => 1), 1);

is(false('z;z;*z:', z => 5), 25);

done-testing;
