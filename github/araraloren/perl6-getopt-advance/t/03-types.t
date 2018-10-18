
use Test;
use Getopt::Advance::Types;
use Getopt::Advance::Option;
use Getopt::Advance::NonOption;

my $types = TypesManager.new;

$types.registe('b', Option::Boolean)
      .registe('i', Option::Integer)
      .registe('s', Option::String)
      .registe('a', Option::Array)
      .registe('h', Option::Hash)
      .registe('f', Option::Float)
      .registe('c', NonOption::Cmd)
      .registe('p', NonOption::Pos)
      .registe('m', NonOption::Main);

# short option
for < b i s a h f> -> $type {
    my $optname = "a";
    {
        my $opt = $types.create("$optname={$type}");

        does-ok $opt, Option:D, "create a option ok.";
        ok $opt.has-short, "short option";
        is $opt.short, "a";
        ok $opt.optional, "optional option";
    }
    {
        my $opt = $types.create("$optname|={$type}");

        does-ok $opt, Option:D, "create a option ok.";
        ok $opt.has-short, "short option";
        is $opt.short, "a";
        ok $opt.optional, "optional option";
    }
    {
        my $opt = $types.create("$optname={$type}!");

        does-ok $opt, Option:D, "create a option ok.";
        ok $opt.has-short, "short option";
        is $opt.short, "a";
        nok $opt.optional, "optional option";
    }
    {
        my $opt = $types.create("$optname|={$type}!");

        does-ok $opt, Option:D, "create a option ok.";
        ok $opt.has-short, "short option";
        is $opt.short, "a";
        nok $opt.optional, "optional option";
    }
}

{
    my $optname = "a";
    {
        my $opt = $types.create("$optname=b/");

        does-ok $opt, Option:D, "not support deactivate style except boolean option.";
        ok $opt.has-short, "short option";
        ok $opt.optional, "optional option";
        is $opt.short, "a";
        ok $opt.default-value, "default value is true";
    }
    for < i s a h f> -> $type {
        dies-ok {
            my $opt = $types.create("$optname={$type}/");
        }, "not support deactivate style except boolean option.";
    }
}
{
    my $optname = "a";
    {
        my $opt = $types.create("$optname|=b/");

        does-ok $opt, Option:D, "not support deactivate style except boolean option.";
        ok $opt.has-short, "short option";
        ok $opt.optional, "optional option";
        is $opt.short, "a";
        ok $opt.default-value, "default value is true";
    }
    for < i s a h f> -> $type {
        dies-ok {
            my $opt = $types.create("$optname|={$type}/");
        }, "not support deactivate style except boolean option.";
    }
}
{
    my $optname = "a";
    {
        my $opt = $types.create("$optname=b!/");

        does-ok $opt, Option:D, "not support deactivate style except boolean option.";
        ok $opt.has-short, "short option";
        nok $opt.optional, "optional option";
        is $opt.short, "a";
        ok $opt.default-value, "default value is true";
    }
    for < i s a h f> -> $type {
        dies-ok {
            my $opt = $types.create("$optname={$type}!/");
        }, "not support deactivate style except boolean option.";
    }
}
{
    my $optname = "a";
    {
        my $opt = $types.create("$optname|=b!/");

        does-ok $opt, Option:D, "not support deactivate style except boolean option.";
        ok $opt.has-short, "short option";
        nok $opt.optional, "optional option";
        is $opt.short, "a";
        ok $opt.default-value, "default value is true";
    }
    for < i s a h f> -> $type {
        dies-ok {
            my $opt = $types.create("$optname|={$type}!/");
        }, "not support deactivate style except boolean option.";
    }
}

# long option
for < b i s a h f> -> $type {
    my $optname = "action";
    {
        my $opt = $types.create("$optname={$type}");

        does-ok $opt, Option:D, "create a option ok.";
        ok $opt.has-long, "long option";
        is $opt.long, "action";
        ok $opt.optional, "optional option";
    }
    {
        my $opt = $types.create("|$optname={$type}");

        does-ok $opt, Option:D, "create a option ok.";
        ok $opt.has-long, "long option";
        is $opt.long, "action";
        ok $opt.optional, "optional option";
    }
    {
        my $opt = $types.create("$optname={$type}!");

        does-ok $opt, Option:D, "create a option ok.";
        ok $opt.has-long, "long option";
        is $opt.long, "action";
        nok $opt.optional, "optional option";
    }
    {
        my $opt = $types.create("|$optname={$type}!");

        does-ok $opt, Option:D, "create a option ok.";
        ok $opt.has-long, "long option";
        is $opt.long, "action";
        nok $opt.optional, "optional option";
    }
}

{
    my $optname = "action";
    {
        my $opt = $types.create("$optname=b/");

        does-ok $opt, Option:D, "not support deactivate style except boolean option.";
        ok $opt.has-long, "long option";
        ok $opt.optional, "optional option";
        is $opt.long, "action";
        ok $opt.default-value, "default value is true";
    }
    for < i s a h f> -> $type {
        dies-ok {
            my $opt = $types.create("$optname={$type}/");
        }, "not support deactivate style except boolean option.";
    }
}
{
    my $optname = "action";
    {
        my $opt = $types.create("|$optname=b/");

        does-ok $opt, Option:D, "not support deactivate style except boolean option.";
        ok $opt.has-long, "long option";
        ok $opt.optional, "optional option";
        is $opt.long, "action";
        ok $opt.default-value, "default value is true";
    }
    for < i s a h f> -> $type {
        dies-ok {
            my $opt = $types.create("|$optname={$type}/");
        }, "not support deactivate style except boolean option.";
    }
}
{
    my $optname = "action";
    {
        my $opt = $types.create("$optname=b!/");

        does-ok $opt, Option:D, "not support deactivate style except boolean option.";
        ok $opt.has-long, "long option";
        nok $opt.optional, "optional option";
        is $opt.long, "action";
        ok $opt.default-value, "default value is true";
    }
    for < i s a h f> -> $type {
        dies-ok {
            my $opt = $types.create("$optname={$type}!/");
        }, "not support deactivate style except boolean option.";
    }
}
{
    my $optname = "action";
    {
        my $opt = $types.create("|$optname=b!/");

        does-ok $opt, Option:D, "not support deactivate style except boolean option.";
        ok $opt.has-long, "long option";
        nok $opt.optional, "optional option";
        is $opt.long, "action";
        ok $opt.default-value, "default value is true";
    }
    for < i s a h f> -> $type {
        dies-ok {
            my $opt = $types.create("|$optname={$type}!/");
        }, "not support deactivate style except boolean option.";
    }
}

# short and long option
for < b i s a h f> -> $type {
    my ($shoptname, $lgoptname) = ('a', "action");
    {
        my $opt = $types.create("$shoptname|$lgoptname={$type}");

        does-ok $opt, Option:D, "create a option ok.";
        is $opt.long, "action";
        is $opt.short, "a";
        ok $opt.has-long, "long option";
        ok $opt.has-short, "short option";
        ok $opt.optional, "optional option";
    }
    {
        my $opt = $types.create("$shoptname|$lgoptname={$type}!");

        does-ok $opt, Option:D, "create a option ok.";
        is $opt.long, "action";
        is $opt.short, "a";
        ok $opt.has-long, "long option";
        ok $opt.has-short, "short option";
        nok $opt.optional, "optional option";
    }
}

{
    my ($shoptname, $lgoptname) = ('a', "action");
    {
        my $opt = $types.create("$shoptname|$lgoptname=b/");

        does-ok $opt, Option:D, "not support deactivate style except boolean option.";
        is $opt.long, "action";
        is $opt.short, "a";
        ok $opt.has-long, "long option";
        ok $opt.has-short, "short option";
        ok $opt.optional, "optional option";
        ok $opt.default-value, "default value is true";
    }
    for < i s a h f> -> $type {
        dies-ok {
            my $opt = $types.create("$shoptname|$lgoptname={$type}/");
        }, "not support deactivate style except boolean option.";
    }
}
{
    my ($shoptname, $lgoptname) = ('a', "action");
    {
        my $opt = $types.create("$shoptname|$lgoptname=b!/");

        does-ok $opt, Option:D, "not support deactivate style except boolean option.";
        is $opt.long, "action";
        is $opt.short, "a";
        ok $opt.has-long, "long option";
        ok $opt.has-short, "short option";
        nok $opt.optional, "optional option";
        ok $opt.default-value, "default value is true";
    }
    for < i s a h f> -> $type {
        dies-ok {
            my $opt = $types.create("$shoptname|$lgoptname={$type}!/");
        }, "not support deactivate style except boolean option.";
    }
}

# short and long option
for < b i s a h f> Z, (True, 42, "earth", [1, 2, 3], %{2 => 3}, 0.10) -> ($type, $value) {
    my ($shoptname, $lgoptname) = ('a', "action");
    {
        my $opt = $types.create("$shoptname|$lgoptname={$type}", :$value);

        does-ok $opt, Option:D, "create a option ok.";
        is $opt.long, "action";
        is $opt.short, "a";
        is $opt.value, $value;
        is $opt.default-value, $value;
        ok $opt.has-long, "long option";
        ok $opt.has-short, "short option";
        ok $opt.optional, "optional option";
    }
    {
        my $opt = $types.create("$shoptname|$lgoptname={$type}!", :$value);

        does-ok $opt, Option:D, "create a option ok.";
        is $opt.long, "action";
        is $opt.short, "a";
        is $opt.value, $value;
        is $opt.default-value, $value;
        ok $opt.has-long, "long option";
        ok $opt.has-short, "short option";
        nok $opt.optional, "optional option";
    }
}

{
    my ($shoptname, $lgoptname) = ('a', "action");
    {
        my $opt = $types.create("$shoptname|$lgoptname=b/", :value(True));

        does-ok $opt, Option:D, "not support deactivate style except boolean option.";
        is $opt.long, "action";
        is $opt.short, "a";
        ok $opt.has-long, "long option";
        ok $opt.has-short, "short option";
        ok $opt.optional, "optional option";
        ok $opt.default-value, "default value is true";
    }
    for < i s a h f> -> $type {
        dies-ok {
            my $opt = $types.create("$shoptname|$lgoptname={$type}/");
        }, "not support deactivate style except boolean option.";
    }
}
{
    my ($shoptname, $lgoptname) = ('a', "action");
    {
        my $opt = $types.create("$shoptname|$lgoptname=b!/", :value(True));

        does-ok $opt, Option:D, "not support deactivate style except boolean option.";
        is $opt.long, "action";
        is $opt.short, "a";
        ok $opt.has-long, "long option";
        ok $opt.has-short, "short option";
        nok $opt.optional, "optional option";
        ok $opt.default-value, "default value is true";
    }
    for < i s a h f> -> $type {
        dies-ok {
            my $opt = $types.create("$shoptname|$lgoptname={$type}!/");
        }, "not support deactivate style except boolean option.";
    }
}

{
    my $name = 'command';

    for < m p c > -> $type {
        my $no = $types.create("{$name}={$type}", callback => sub () {});

        is $no.name, $name, 'create a non-option ' ~ $no.type ~ ' named ' ~ $name;
    }
}

done-testing;
