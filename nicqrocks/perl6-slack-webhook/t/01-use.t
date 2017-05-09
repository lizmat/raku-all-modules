#!/usr/bin/env perl6

use Test;
use lib 'lib';

#Make sure we can even call it.
use-ok 'WebService::Slack::Webhook';

done-testing;
