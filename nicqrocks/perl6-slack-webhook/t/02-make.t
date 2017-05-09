#!/usr/bin/env perl6

use Test;
use lib 'lib';

use WebService::Slack::Webhook;

#Make some vars
my $fake-url = "https://hooks.slack.com/services/example/integration/url";

#Make a bad object.
dies-ok {WebService::Slack::Webhook.new()},
    'Bad object fails correctly';

#Make a good object with a url.
isa-ok WebService::Slack::Webhook.new(url => "$fake-url"),
    'WebService::Slack::Webhook',
    'Good object can be made with url';


#Make a good object with a url.
isa-ok WebService::Slack::Webhook.new(
        url => "$fake-url",
        defaults => %( :username<Test> )
    ),
    'WebService::Slack::Webhook',
    'Good object can be made with defaults';

done-testing;
