use v6.d.PREVIEW;
use DRMAA::NativeCall;
use NativeCall :types;
use NativeHelpers::CBuffer;

my $error   = CBuffer.new(DRMAA_ERROR_STRING_BUFFER);
my $errnum  = 0;

my $remote-command = CBuffer.new("./sleeper.sh");

my Pointer[drmaa_job_template_t] $jt = Pointer[drmaa_job_template_t].new;

$errnum = drmaa_init((CBuffer), $error, DRMAA_ERROR_STRING_BUFFER);

if ($errnum != DRMAA_ERRNO_SUCCESS) {
    die "Could not initialize the DRMAA library: ", $error;
}

$errnum = drmaa_allocate_job_template($jt, $error, DRMAA_ERROR_STRING_BUFFER);

if ($errnum != DRMAA_ERRNO_SUCCESS) {
    warn "Could not create job template: ", $error;
}
else {
    $errnum = drmaa_set_attribute($jt.deref, DRMAA_REMOTE_COMMAND, $remote-command,
				  $error, DRMAA_ERROR_STRING_BUFFER);

    if ($errnum != DRMAA_ERRNO_SUCCESS) {
	warn 'Could not set attribute "', DRMAA_REMOTE_COMMAND, '": ', $error;
    }
    else {
	my $args = CArray[CBuffer].new(CBuffer.new("5"), (CBuffer));

	$errnum = drmaa_set_vector_attribute($jt.deref, DRMAA_V_ARGV, $args, $error,
					     DRMAA_ERROR_STRING_BUFFER);
    }

    if ($errnum != DRMAA_ERRNO_SUCCESS) {
	warn 'Could not set attribute "', DRMAA_V_ARGV, '": ', $error;
    }
    else {
	my Pointer[drmaa_job_ids_t] $ids = Pointer[drmaa_job_ids_t].new;

	$errnum = drmaa_run_bulk_jobs($ids, $jt, 1, 30, 2, $error, DRMAA_ERROR_STRING_BUFFER);

	if ($errnum != DRMAA_ERRNO_SUCCESS) {
	    warn "Could not submit job: ", $error;
	}
	else {
	    my $jobid = CBuffer.new(DRMAA_JOBNAME_BUFFER);

	    while (drmaa_get_next_job_id($ids.deref, $jobid, DRMAA_JOBNAME_BUFFER) == DRMAA_ERRNO_SUCCESS) {
		say "A job task has been submitted with id ", $jobid;
	    }
	}

	drmaa_release_job_ids($ids.deref);
    } # else
    $errnum = drmaa_delete_job_template($jt.deref, $error, DRMAA_ERROR_STRING_BUFFER);

    if ($errnum != DRMAA_ERRNO_SUCCESS) {
	warn 'Could not delete job template: ', $error;
    }
} # else

$errnum = drmaa_exit($error, DRMAA_ERROR_STRING_BUFFER);
 
if ($errnum != DRMAA_ERRNO_SUCCESS) {
    die "Could not shut down the DRMAA library: ", $error;
}
