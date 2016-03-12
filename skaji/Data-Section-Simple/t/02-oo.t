use v6;
use Test;
need Data::Section::Simple;

my $render = Data::Section::Simple.new;

my %all = $render.get-data-section;
my $foo = $render.get-data-section(name => 'foo.html');

is %all<bar.tt>, q:to/EOF/;
[% IF true %]
Foo
[% END %]
EOF

my $foo-expect = q:to/EOF/;
<html>
<body>Hello</body>
</html>

EOF

is $foo, $foo-expect;

# get-data-section works in scopes
sub {
    is $render.get-data-section(name => 'foo.html'), $foo-expect;
}();
{{{{ is $render.get-data-section(name => 'foo.html'), $foo-expect; }}}}

done-testing;

=finish

@@ foo.html
<html>
<body>Hello</body>
</html>

@@ bar.tt
[% IF true %]
Foo
[% END %]
