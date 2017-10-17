use v6.d.PREVIEW;
use DRMAA;

DRMAA::Session.init;

say "DRMAA library was started successfully";

DRMAA::Session.events.tap: { .say };

my $submission = DRMAA::Job-template.new(
                    :remote-command<./sleeper.sh>, :argv<20>
                 ).run.then(DRMAA::Job-template.new(
		    :remote-command<./sleeper.sh>, :argv<10>
                 ));

say $submission;

await Promise.in(100);

DRMAA::Session.exit;
