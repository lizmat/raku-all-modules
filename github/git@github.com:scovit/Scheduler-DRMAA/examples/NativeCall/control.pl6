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
	my $args = CArray[CBuffer].new(CBuffer.new("60"), (CBuffer));

	$errnum = drmaa_set_vector_attribute($jt.deref, DRMAA_V_ARGV, $args, $error,
					     DRMAA_ERROR_STRING_BUFFER);
    }

    if ($errnum != DRMAA_ERRNO_SUCCESS) {
	warn 'Could not set attribute "', DRMAA_V_ARGV, '": ', $error;
    }
    else {
	my $jobid = CBuffer.new(DRMAA_JOBNAME_BUFFER);
 
	$errnum = drmaa_run_job($jobid, DRMAA_JOBNAME_BUFFER, $jt.deref, $error,
				DRMAA_ERROR_STRING_BUFFER);
 
	if ($errnum != DRMAA_ERRNO_SUCCESS) {
	    warn "Could not submit job: ", $error;
	}
	else {
	    say 'Your job has been submitted with id ', $jobid;

            $errnum = drmaa_control($jobid, DRMAA_CONTROL_TERMINATE, $error,
                                    DRMAA_ERROR_STRING_BUFFER);
           
            if ($errnum != DRMAA_ERRNO_SUCCESS) {
                warn "Could not delete job: ", $jobid;
            }
            else {
                say "Your job has been deleted";
            }
	}
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
