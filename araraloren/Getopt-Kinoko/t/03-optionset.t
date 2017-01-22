
use v6;
use Test;
use Getopt::Kinoko;
use Getopt::Kinoko::Option;
use Getopt::Kinoko::OptionSet;

plan 24;

#   -n|--name=[customer name] -i|--id=[customer id] -v|--vip
#   -d|--discount=[discount]
#   -l|--shopping-list=[good and price]
#   -s|--sum=[sum of goods cost]
#   -p|--print-list

my OptionSet $optset .= new();

isa-ok $optset, OptionSet, "OptionSet create ok";

lives-ok {
    $optset.insert-normal("n|name=s;v|vip=b!;");
}, "insert a normal group ok";

lives-ok {
    $optset.push-option(
        "l|shopping-list=h"
    );
}, "push a new option ok";

lives-ok {
    $optset.push-option(
        "d|discount=i",
        98,
        :normal
    );
}, "push a new option has default value ok";

lives-ok {
    $optset.push-option(
        "s|sum=s", # not support float number option
        "0",
        callback => -> $value {
            die("sum can not be negative") if +$value < 0;
        },
        :normal
    );
}, "push a new option has callback ok";

lives-ok {
    $optset.append-options("p|print-list=b;i|id=s;", :normal);
}, "append two new option ok";

# has
{
    ok $optset.has-option("p"), "check option p ok";
    ok $optset.has-option("p", :short), "check short option p ok";
    ok $optset.has-option("print-list", :long), "check long option print-list ok";
    nok $optset.has-option("w"), "check option w not ok";
}

#has-value
{
    ok $optset.has-value("d"), "option discount has value";
    nok $optset.has-value("l"), "shopping-list has no value";
}

# get
{
    my $opt-sl := $optset.get-option("l");

    does-ok $opt-sl, Option, "get option shopping-list ok";
    isa-ok $opt-sl, Option::Hash, "get option shopping-list ok";
}

# set-value set callback
{
    lives-ok {
        $optset.set-value("shopping-list", %(coffee => 1));
        $optset.set-callback("shopping-list", -> $value { });
    }, " set value, set callback ok";
}

# AT-KEY
{
    isa-ok $optset{'l'}, Hash, "get shopping-list value ok";
}

# EXISTS-KEY
{
    ok $optset{'l'}:exists, "check option exists ok";
}

# is-set-noa-callback set-noa-callback
{
    nok $optset.has-front, "check noa callback ok";

    $optset.insert-front(
        -> $arg {
            # do something
        }
    );
    ok $optset.has-front, "check noa callback ok";
}

# parser
{
    my $gnu-style-optset = $optset.deep-clone;

    ok $gnu-style-optset.WHICH ne $optset.WHICH, "deep clone ok";

    # NonOption::Front not check argument index
    my @args = [ "-n", "Jam", "--vip", "-l", ":ice-cream<1>",  "-l", "%(chips => 2)", "-d", "95", "some", "other", "noa" ];

    my @gargs = [ "front", "-n=Jam", "--vip", "-l=%('ice-cream' => 1)",  "-l=%(chips => 2)", "-d=95" ];

    lives-ok {
        getopt($optset, @args, prefix => 'get-', :generate-method);
    }, "getopt normal style parse ok";

    lives-ok {
        getopt($gnu-style-optset, @gargs, :gnu-style);
    }, "getopt gnu-style parse ok";

    can-ok $optset, 'get-p';
    can-ok $optset, "get-shopping-list";
}

done-testing();
