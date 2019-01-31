#!perl6

use v6;

use Test;
use Template6;
use Lumberjack::Template::Provider;

# This exercises the template provider in much the same way
# as the Lumberjack::Application::Index does

my $template = Template6.new;

my $provider;

lives-ok { $provider = Lumberjack::Template::Provider.new }, "create new provider";
does-ok $provider, Template6::Provider, "and it is a provider";

lives-ok { $provider.add-path('templates') }, "add-path";

lives-ok { $template.add-provider('resources', $provider) }, "add the provider";

$template.add-path('templates');

my $str;

lives-ok { $str = $template.process('index', ws-url => 'http://localhost/foo') }, "process";
ok $str.defined, "and we got something back";
like $str, /'http://localhost/foo'/, "and it has our string";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
