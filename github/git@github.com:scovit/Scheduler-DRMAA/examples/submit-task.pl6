use v6.d.PREVIEW;
use DRMAA;

DRMAA::Session.init;

say "DRMAA library was started successfully";

my @submission = DRMAA::Job-template.new(
                    :remote-command<./sleeper.sh>, :argv<5>
                 ).run-bulk(1, 30, :by(2));

say 'The following job tasks have been sumbitted: ', @submission.map: *.job-id;

DRMAA::Session.exit;
