use v6.d.PREVIEW;
unit module DRMAA::Session:ver<0.0.1>:auth<Vittore F Scolari (vittore.scolari@gmail.com)>;

use NativeCall :types;
use NativeHelpers::CBuffer;
use DRMAA::NativeCall;
use DRMAA::Native-specification;
use DRMAA::Submission::Status;
use X::DRMAA;

class DRMAA::Session {
    method new(|) { die "DRMAA::Session is a Singleton, it desn't need to be instantiated" };
    method bless(|) { die "DRMAA::Session is a Singleton, it desn't need to be instantiated" };

    my DRMAA::Native-specification $native-specification;

    method native-specification(--> DRMAA::Native-specification) {
        $native-specification;
    }

    my $events;
    my atomicint $running = 0;
    my $done-waiter;

    method events(--> Supply) {
	$events.Supply;
    }

    sub choose-native-specification($drm) {
	for @DRMAA::Native-specification::Builtin-specifications -> $module, $match {
            if ($drm ~~ $match) {
		require ::($module);
		return ::($module).new;
            }
	}
    }

    sub job-waiting-loop {
        my $error-buf       = CBuffer.new(DRMAA_ERROR_STRING_BUFFER);
	my $jobin-buf       = DRMAA_JOB_IDS_SESSION_ANY;
	my $jobout-buf      = CBuffer.new(DRMAA_JOBNAME_BUFFER);
	my $usage-buf       = CBuffer.new(DRMAA_ERROR_STRING_BUFFER);
        LEAVE { $error-buf.free; $jobin-buf.free; $jobout-buf.free; $usage-buf.free; }

        my $rusage          = Pointer[drmaa_attr_values_t].new;
	my int32 $error-num = 0;
	my int32 $status    = 0;
	my int32 $timeout   = 3;
	my Str   $usage;

        while (⚛$running) {
            $error-num = drmaa_wait($jobin-buf, $jobout-buf,
                                    DRMAA_JOBNAME_BUFFER, $status,
                                    $timeout, $rusage,
                                    $error-buf, DRMAA_ERROR_STRING_BUFFER);

            if $error-num == DRMAA_ERRNO_EXIT_TIMEOUT {
		next;
	    }
	    elsif $error-num == DRMAA_ERRNO_INVALID_JOB {
		await Promise.in($timeout);
		next;
	    }

	    my int32 $aborted   = 0;
	    my int32 $exited    = 0;
	    my int32 $exit-code = 0;
	    my int32 $signaled  = 0;
	    my Str   $signal    = Str;

            if $error-num != DRMAA_ERRNO_SUCCESS {
	        die X::DRMAA::from-code($error-num).new(:because($error-buf));
            }

            #
            # Check if aborted
            #
            $error-num = drmaa_wifaborted($aborted, $status,
                                          $error-buf, DRMAA_ERROR_STRING_BUFFER);

            if $error-num != DRMAA_ERRNO_SUCCESS {
                die X::DRMAA::from-code($error-num).new(:because($error-buf));
            }

            #
            # Check if exited
            #
            $error-num = drmaa_wifexited($exited, $status,
                                         $error-buf, DRMAA_ERROR_STRING_BUFFER);

	    
            if $error-num != DRMAA_ERRNO_SUCCESS {
		die X::DRMAA::from-code($error-num).new(:because($error-buf));
            }

            if ($exited) {
	        $error-num = drmaa_wexitstatus($exit-code, $status,
                                               $error-buf, DRMAA_ERROR_STRING_BUFFER);

	        if $error-num != DRMAA_ERRNO_SUCCESS {
                    die X::DRMAA::from-code($error-num).new(:because($error-buf));
                }
            }

            #
            # Check if signaled
            #
            $error-num = drmaa_wifsignaled($signaled, $status,
                                           $error-buf, DRMAA_ERROR_STRING_BUFFER);

            if $error-num != DRMAA_ERRNO_SUCCESS {
                die X::DRMAA::from-code($error-num).new(:because($error-buf));
            }

            if ($signaled) {
                my $termsig-buf = CBuffer.new(DRMAA_SIGNAL_BUFFER + 1);
                LEAVE { $termsig-buf.free; }

                $error-num = drmaa_wtermsig($termsig-buf, DRMAA_SIGNAL_BUFFER, $status,
                                            $error-buf, DRMAA_ERROR_STRING_BUFFER);

                if $error-num != DRMAA_ERRNO_SUCCESS {
                    die X::DRMAA::from-code($error-num).new(:because($error-buf));
                }

		$signal = $termsig-buf.Str;
	    }

	    $usage = "";
	    while (drmaa_get_next_attr_value($rusage.deref, $usage-buf, DRMAA_ERROR_STRING_BUFFER) == DRMAA_ERRNO_SUCCESS) {
                $usage ~= ($usage-buf.Str ~ "\n");
            }
	    
	    if ($aborted) {
                $events.emit(
                    Failure.new(X::DRMAA::Submission::Status::Aborted.new(
			               :id($jobout-buf.Str),
		   		       :exited($exited.Bool),
				       :$exit-code,
				       :$signal,
				       :$usage)));
	    }
	    else {
                $events.emit(
		    DRMAA::Submission::Status::Succeded.new(
                        :id($jobout-buf.Str),
                        :exited($exited.Bool),
                        :$exit-code,
                        :$signal,
		        :$usage));
	    }
        }

	$events.done;
    }

    method init(Str :$contact, DRMAA::Native-specification :native-specification(:$ns)) {
	my $contact-buf = CBuffer.new(DRMAA_CONTACT_BUFFER, :init($contact));
	my $error-buf = CBuffer.new(DRMAA_ERROR_STRING_BUFFER);
	LEAVE { $contact-buf.free; $error-buf.free; }

	my $error-num = drmaa_init($contact-buf, $error-buf, DRMAA_ERROR_STRING_BUFFER);

	fail X::DRMAA::from-code($error-num).new(:because($error-buf)) if ($error-num != DRMAA_ERRNO_SUCCESS);

	if (defined $ns) {
	    $native-specification = $ns;
	} else {
	    $native-specification = choose-native-specification self.DRM-system;
	}

        $events = Supplier.new;
	$running⚛++;
	$done-waiter = start { job-waiting-loop }

	True
    }

    method exit() is export {
	my $error-buf = CBuffer.new(DRMAA_ERROR_STRING_BUFFER);
	LEAVE { $error-buf.free; }

	$running⚛--;
	await $done-waiter;

	my $error-num = drmaa_exit($error-buf, DRMAA_ERROR_STRING_BUFFER);

	fail X::DRMAA::from-code($error-num).new(:because($error-buf)) if ($error-num != DRMAA_ERRNO_SUCCESS);
    }

    method attribute-names(--> List) {
	my $values = Pointer[drmaa_attr_names_t].new;
	my $error-buf = CBuffer.new(DRMAA_ERROR_STRING_BUFFER);
	LEAVE { drmaa_release_attr_names($values.deref); $error-buf.free; }

	my $error-num = drmaa_get_attribute_names($values, $error-buf, DRMAA_ERROR_STRING_BUFFER);

	die X::DRMAA::from-code($error-num).new(:because($error-buf)) if ($error-num != DRMAA_ERRNO_SUCCESS);
	(Seq.new($values.deref).map: { LEAVE { .free }; .Str; }).list.eager;
    }

    method vector-attribute-names(--> List) {
	my $values = Pointer[drmaa_attr_names_t].new;
	my $error-buf = CBuffer.new(DRMAA_ERROR_STRING_BUFFER);
	LEAVE { drmaa_release_attr_names($values.deref); $error-buf.free; }

	my $error-num = drmaa_get_vector_attribute_names($values, $error-buf, DRMAA_ERROR_STRING_BUFFER);

	die X::DRMAA::from-code($error-num).new(:because($error-buf)) if ($error-num != DRMAA_ERRNO_SUCCESS);
	(Seq.new($values.deref).map: { LEAVE { .free }; .Str; }).list.eager;
    }

    method contact(--> Str) {
	my $contact-buf = CBuffer.new(DRMAA_CONTACT_BUFFER);
	my $error-buf = CBuffer.new(DRMAA_ERROR_STRING_BUFFER);
	LEAVE { $contact-buf.free; $error-buf.free; }

	my $error-num = drmaa_get_contact($contact-buf, DRMAA_CONTACT_BUFFER,
					  $error-buf, DRMAA_ERROR_STRING_BUFFER);

	die X::DRMAA::from-code($error-num).new(:because($error-buf)) if ($error-num != DRMAA_ERRNO_SUCCESS);
	$contact-buf.Str;
    }

    method DRM-system(--> Str) {
	my $drm-buf = CBuffer.new(DRMAA_DRM_SYSTEM_BUFFER);
	my $error-buf = CBuffer.new(DRMAA_ERROR_STRING_BUFFER);
	LEAVE { $drm-buf.free; $error-buf.free; }

	my $error-num = drmaa_get_DRM_system($drm-buf, DRMAA_DRM_SYSTEM_BUFFER,
					     $error-buf, DRMAA_ERROR_STRING_BUFFER);

	die X::DRMAA::from-code($error-num).new(:because($error-buf)) if ($error-num != DRMAA_ERRNO_SUCCESS);
	$drm-buf.Str;
    }

    method implementation(--> Str) {
	my $drmaa-buf = CBuffer.new(DRMAA_DRM_SYSTEM_BUFFER);
	my $error-buf = CBuffer.new(DRMAA_ERROR_STRING_BUFFER);
	LEAVE { $drmaa-buf.free; $error-buf.free; }

	my $error-num = drmaa_get_DRMAA_implementation($drmaa-buf, DRMAA_DRM_SYSTEM_BUFFER,
						       $error-buf, DRMAA_ERROR_STRING_BUFFER);

	die X::DRMAA::from-code($error-num).new(:because($error-buf)) if ($error-num != DRMAA_ERRNO_SUCCESS);
	$drmaa-buf.Str;
    }

    method version(--> Version) {
	my int32 $major;
	my int32 $minor;
	my $error-buf = CBuffer.new(DRMAA_ERROR_STRING_BUFFER);
	LEAVE { $error-buf.free; }

	my $error-num = drmaa_version($major, $minor,
				      $error-buf, DRMAA_ERROR_STRING_BUFFER);

	die X::DRMAA::from-code($error-num).new(:because($error-buf)) if ($error-num != DRMAA_ERRNO_SUCCESS);
	Version.new("$major.$minor");
    }
}
