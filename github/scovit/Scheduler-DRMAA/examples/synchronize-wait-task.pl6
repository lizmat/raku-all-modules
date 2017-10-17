use v6.d.PREVIEW;
use DRMAA;

DRMAA::Session.init;

my @submission = DRMAA::Job-template.new(
                    :remote-command<./sleeper.sh>, :argv<5>
                 ).run-bulk(1, 30, :by(2));

say 'The following job tasks have been sumbitted: ', @submission.map: *.job-id;

say 'Waiting for jobs to finish';

my atomicint ($succs, $fails);
DRMAA::Session.events.tap: {
    when Failure  { $fails⚛++; proceed; }
    when !Failure { $succs⚛++; proceed; }
    default { say $succs + $fails, "/15 finished"; }
};

my @results = try await @submission;

say "$succs submissions succeded, $fails aborted";
say '   succeded: ', @results.grep({ !Failure }).map: *.id;
say '   aborted:  ', @results.grep({ Failure  }).map: *.id;

DRMAA::Session.exit;
