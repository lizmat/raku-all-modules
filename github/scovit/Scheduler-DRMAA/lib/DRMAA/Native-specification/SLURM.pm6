use v6.d.PREVIEW;
unit module DRMAA::Native-specification::SLURM:ver<0.0.1>:auth<Vittore F Scolari (vittore.scolari@gmail.com)>;

use DRMAA::Native-specification;
#use DRMAA::Session;
use DRMAA::Submission;
use DRMAA::Job-template;

class DRMAA::Native-specification::SLURM does DRMAA::Native-specification {
    method provides(--> List) {
	(Dependencies,);
    }

    # Dependencies
    method job-template-after(DRMAA::Job-template:D $what, $after) {
	$what.native-specification ~= ' --dependency=after:' ~ join(':', $after.map: { $_.job-id });
    };
    method job-template-afterany(DRMAA::Job-template:D $what, $after) {
	$what.native-specification ~= ' --dependency=afterany:' ~ join(':', $after.map: { $_.job-id });
    };
    method job-template-afterok(DRMAA::Job-template:D $what, $after) {
	$what.native-specification ~= ' --dependency=afterok:' ~ join(':', $after.map: { $_.job-id });
    };
    method job-template-afternotok(DRMAA::Job-template:D $what, $after) {
	$what.native-specification ~= ' --dependency=afternotok:' ~ join(':', $after.map: { $_.job-id });
    };
    method submission-then(DRMAA::Submission:D $after, DRMAA::Job-template:D $what --> DRMAA::Submission) {
	self.job-template-afterany($what, $after);

	$what.run;
    }
}
