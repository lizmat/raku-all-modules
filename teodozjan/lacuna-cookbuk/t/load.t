use v6;
use Test;

use LacunaCookbuk::Client;
use IO::Capture::Simple;
 

plan 8;

unless %*ENV<TRAVIS> {
skip-rest 'Cannot perform all test without game login data'; 
exit;
}


my $client;
lives-ok {$client = LacunaCookbuk::Client.new}, 'Construction'; 

lives-ok {create_session}, 'Login';
lives-ok {
    capture_stdout {LacunaCookbuk::Logic::BodyBuilder.process_all_bodies}
}, 'Update';

lives-ok {
    capture_stdout {$client.cleanbox}
}, 'Remove mail';

lives-ok {
    capture_stdout {$client.defend}
}, 'Show attackers';

lives-ok {
    capture_stdout {$client.ordinary}
}, 'Make halls  and transport them';

lives-ok {
    capture_stdout {$client.chairman}
}, 'Upgrade buildings';

lives-ok {close_session}, "Logout";

