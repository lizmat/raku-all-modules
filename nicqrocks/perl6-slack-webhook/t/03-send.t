#!/usr/bin/env perl6

use Test;
use lib 'lib';

use WebService::Slack::Webhook;

#Make some vars
my $fake-url = "https://hooks.slack.com/services/example/integration/url";

my $slack = WebService::Slack::Webhook.new(url => $fake-url, :debug);
my %info = (
    text => "This is a test message",
    username => "test-bot"
);

is-deeply $slack.send(%info<text>), %( text => %info<text> ),
    'Send works with string arg';
is-deeply $slack.send(%info), %info, 'Send works with hash arg';


#Check that deafults work properly.
$slack.defaults = %( icon_emoji => ":robot_face:" );
is-deeply $slack.send(%info), %( |%info, icon_emoji => ":robot_face:" ),
    "Send works with default arguments";


done-testing;
