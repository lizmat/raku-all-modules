use v6.d.PREVIEW;
use DRMAA;

DRMAA::Session.init;

say "DRMAA library was started successfully";

my $submission = DRMAA::Job-template.new(
                    :remote-command<./sleeper.sh>, :argv<60>
                 ).run;

say 'Your job has been submitted with id: ', $submission.job-id;

$submission.terminate;

say 'Job terminated';

DRMAA::Session.exit;
