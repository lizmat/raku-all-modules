use v6.d.PREVIEW;
use DRMAA;

DRMAA::Session.init;

say "DRMAA library was started successfully";

my $submission = DRMAA::Job-template.new(
                    :remote-command<./sleeper.sh>, :argv<5>
                 ).run;

say 'Your job has been submitted with id: ', $submission.job-id;

my $results = try await $submission;

given $results {
    when DRMAA::Submission::Status::Succeded {
	say 'Job ',          .id, ' ended correctly!';
	say '  exited:    ', .exited;
	say '  exit-code: ', .exit-code;
	say '  signal:    ', .signal;
	say 'Usage statistics:';
	say                  .usage;
    }
    default { # X::DRMAA::Submission::Status::Aborted is an exception
	say 'Job ',          $!.id, ' aborted!';
	say '  exited:    ', $!.exited;
	say '  exit-code: ', $!.exit-code;
	say '  signal:    ', $!.signal;
	say 'Usage statistics:';
	say                  $!.usage;
    }
}

DRMAA::Session.exit;
