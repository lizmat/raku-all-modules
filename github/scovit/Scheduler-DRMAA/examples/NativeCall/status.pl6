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
	    my int32 $status = 0;
	    
	    say 'Your job has been submitted with id ', $jobid;

            sleep(20);

            $errnum = drmaa_job_ps($jobid, $status, $error,
				   DRMAA_ERROR_STRING_BUFFER);

            if ($errnum != DRMAA_ERRNO_SUCCESS) {
		warn "Could not get job status: ", $error;
	    }
            else {
		given ($status) {
		    when DRMAA_PS_UNDETERMINED { say "Job status cannot be determined" }
                    when DRMAA_PS_QUEUED_ACTIVE { say "Job is queued and active" }
                    when DRMAA_PS_SYSTEM_ON_HOLD { say "Job is queued and in system hold" }
                    when DRMAA_PS_USER_ON_HOLD { say "Job is queued and in user hold" }
                    when DRMAA_PS_USER_SYSTEM_ON_HOLD { say "Job is queued and in user and system hold" }
                    when DRMAA_PS_RUNNING { say "Job is running" }
                    when DRMAA_PS_SYSTEM_SUSPENDED { say "Job is system suspended" }
                    when DRMAA_PS_USER_SUSPENDED { say "Job is user suspended" }
                    when DRMAA_PS_USER_SYSTEM_SUSPENDED { say "Job is user and system suspended" }
                    when DRMAA_PS_DONE { say "Job finished normally" }
                    when DRMAA_PS_FAILED { say "Job finished, but failed" }
		    default { say "Dunno!" }
		} # given
	    } # else
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
