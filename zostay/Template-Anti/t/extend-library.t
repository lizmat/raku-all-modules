use v6;

use Test;
use lib 't/lib';
use MyEmails;

my $ta = Template::Anti::Library.new(
    path  => <t/view>,
    views => { :email(MyEmails.new) },
);

my $expect = "t/extend.out".IO.slurp;

is $ta.process('email.hello', :name<Starkiller>, :dark-lord<Darth Vader>), $expect, "custom format works";
is $ta.process('email.hello-embedded', :name<Starkiller>, :dark-lord<Darth Vader>), $expect, "custom format with embedded code works";

done-testing;
