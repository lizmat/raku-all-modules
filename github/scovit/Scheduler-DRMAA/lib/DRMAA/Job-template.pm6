use v6.d.PREVIEW;
unit module DRMAA::Job-template:ver<0.0.1>:auth<Vittore F Scolari (vittore.scolari@gmail.com)>;

use NativeCall :types;
use File::Temp;
use NativeHelpers::CBuffer;
use DRMAA::NativeCall;
use X::DRMAA;
use DRMAA::Submission;
use DRMAA::Session;
use DRMAA::Native-specification;


class DRMAA::Job-template {
    has drmaa_job_template_t $.jt;

    method attribute-fetch(Str:D $name --> Str) {
        my $attri-buf = CBuffer.new($name);
        my $value-buf = CBuffer.new(DRMAA_ATTR_BUFFER);
        my $error-buf = CBuffer.new(DRMAA_ERROR_STRING_BUFFER);
        LEAVE { $attri-buf.free; $value-buf.free; $error-buf.free; };

        my $error-num = drmaa_get_attribute($!jt, $attri-buf, $value-buf, DRMAA_ATTR_BUFFER, $error-buf, DRMAA_ERROR_STRING_BUFFER);
        die X::DRMAA::from-code($error-num).new(:because($error-buf)) if ($error-num != DRMAA_ERRNO_SUCCESS);

        $value-buf.Str;
    }
    
    method attribute-store(Str:D $name, Str:D $value --> Str) {
	my $attri-buf = CBuffer.new($name);
        my $value-buf = CBuffer.new($value);
        my $error-buf = CBuffer.new(DRMAA_ERROR_STRING_BUFFER);
        LEAVE { $attri-buf.free; $value-buf.free; $error-buf.free; };

        my $error-num = drmaa_set_attribute($!jt, $attri-buf, $value-buf, $error-buf, DRMAA_ERROR_STRING_BUFFER);
        die X::DRMAA::from-code($error-num).new(:because($error-buf)) if ($error-num != DRMAA_ERRNO_SUCCESS);

        $value
    }
    
    method attribute(Str:D $name) is rw {
	my $cached;
	my $template = self;

        Proxy.new(
            FETCH => method (--> Str) {
		$cached = $template.attribute-fetch($name) unless defined $cached;
		$cached;
	    },
            STORE => method ($value) {
		$cached = Any;
		$template.attribute-store($name, $value.Str);
	    }
        )
    }

    method vector-attribute-fetch(Str:D $name --> List) {
	my $attri-buf = CBuffer.new($name);
        my $values = Pointer[drmaa_attr_values_t].new;
        my $error-buf = CBuffer.new(DRMAA_ERROR_STRING_BUFFER);
        LEAVE { $attri-buf.free; drmaa_release_attr_values($values.deref);
                $error-buf.free; };

        my $error-num = drmaa_get_vector_attribute($!jt, $attri-buf, $values, $error-buf, DRMAA_ERROR_STRING_BUFFER);
        die X::DRMAA::from-code($error-num).new(:because($error-buf)) if ($error-num != DRMAA_ERRNO_SUCCESS);

        (Seq.new($values.deref).map: { LEAVE { .free }; .Str; }).list.eager;
    }

    method vector-attribute-store(Str:D $name, $value) {
	my $attri-buf = CBuffer.new($name);
        my $value-arr = CArray[CBuffer].new(|($value.map: { CBuffer.new($_.Str) }), CBuffer);
        my $error-buf = CBuffer.new(DRMAA_ERROR_STRING_BUFFER);
        LEAVE { $attri-buf.free; .free for $value-arr.Seq; $error-buf.free; };

        my $error-num = drmaa_set_vector_attribute($!jt, $attri-buf, $value-arr, $error-buf, DRMAA_ERROR_STRING_BUFFER);
        die X::DRMAA::from-code($error-num).new(:because($error-buf)) if ($error-num != DRMAA_ERRNO_SUCCESS);

        $value
    }
    
    method vector-attribute(Str:D $name) is rw {
	my $cached;
	my $template = self;
	
        Proxy.new(
            FETCH => method (--> List) {
		$cached = $template.vector-attribute-fetch($name) unless defined $cached;
                $cached;
	    },
            STORE => method ($value) {
		$cached = Any;
		$template.vector-attribute-store($name, $value);
	    }
        )
    };

    multi method block-email()          is rw { given (DRMAA_BLOCK_EMAIL) { LEAVE { .free }; self.attribute($_.Str) } }
    multi method block-email($value)          { given (DRMAA_BLOCK_EMAIL) { LEAVE { .free }; self.attribute-store($_.Str, $value.Str) } }
    
    multi method deadline-time()        is rw { given (DRMAA_DEADLINE_TIME) { LEAVE { .free }; self.attribute($_.Str) } }
    multi method deadline-time($value)        { given (DRMAA_DEADLINE_TIME) { LEAVE { .free }; self.attribute-store($_.Str, $value.Str) } }
    
    multi method duration-hlimit()      is rw { given (DRMAA_DURATION_HLIMIT) { LEAVE { .free }; self.attribute($_.Str) } }
    multi method duration-hlimit($value)      { given (DRMAA_DURATION_HLIMIT) { LEAVE { .free }; self.attribute-store($_.Str, $value.Str) } }
    
    multi method duration-slimit()      is rw { given (DRMAA_DURATION_SLIMIT) { LEAVE { .free }; self.attribute($_.Str) } }
    multi method duration-slimit($value)      { given (DRMAA_DURATION_SLIMIT) { LEAVE { .free }; self.attribute-store($_.Str, $value.Str) } }
    
    multi method error-path()           is rw { given (DRMAA_ERROR_PATH) { LEAVE { .free }; self.attribute($_.Str) } }
    multi method error-path($value)           { given (DRMAA_ERROR_PATH) { LEAVE { .free }; self.attribute-store($_.Str, $value.Str) } }
    
    multi method input-path()           is rw { given (DRMAA_INPUT_PATH) { LEAVE { .free }; self.attribute($_.Str) } }
    multi method input-path($value)           { given (DRMAA_INPUT_PATH) { LEAVE { .free }; self.attribute-store($_.Str, $value.Str) } }
    
    multi method job-category()         is rw { given (DRMAA_JOB_CATEGORY) { LEAVE { .free }; self.attribute($_.Str) } }
    multi method job-category($value)         { given (DRMAA_JOB_CATEGORY) { LEAVE { .free }; self.attribute-store($_.Str, $value.Str) } }
    
    multi method job-name()             is rw { given (DRMAA_JOB_NAME) { LEAVE { .free }; self.attribute($_.Str) } }
    multi method job-name($value)             { given (DRMAA_JOB_NAME) { LEAVE { .free }; self.attribute-store($_.Str, $value.Str) } }

    multi method join-files()           is rw { given (DRMAA_JOIN_FILES) { LEAVE { .free }; self.attribute($_.Str) } }
    multi method join-files($value)           { given (DRMAA_JOIN_FILES) { LEAVE { .free }; self.attribute-store($_.Str, $value.Str) } }
    
    multi method js-state()             is rw { given (DRMAA_JS_STATE) { LEAVE { .free }; self.attribute($_.Str) } }
    multi method js-state($value)             { given (DRMAA_JS_STATE) { LEAVE { .free }; self.attribute-store($_.Str, $value.Str) } }
    
    multi method native-specification() is rw { given (DRMAA_NATIVE_SPECIFICATION) { LEAVE { .free }; self.attribute($_.Str) } }
    multi method native-specification($value) { given (DRMAA_NATIVE_SPECIFICATION) { LEAVE { .free }; self.attribute-store($_.Str, $value.Str) } }
    
    multi method output-path()          is rw { given (DRMAA_OUTPUT_PATH) { LEAVE { .free }; self.attribute($_.Str) } }
    multi method output-path($value)          { given (DRMAA_OUTPUT_PATH) { LEAVE { .free }; self.attribute-store($_.Str, $value.Str) } }

    multi method remote-command()       is rw { given (DRMAA_REMOTE_COMMAND) { LEAVE { .free }; self.attribute($_.Str) } }
    multi method remote-command($value)       { given (DRMAA_REMOTE_COMMAND) { LEAVE { .free }; self.attribute-store($_.Str, $value.Str) } }
    
    multi method start-time()           is rw { given (DRMAA_START_TIME) { LEAVE { .free }; self.attribute($_.Str) } }
    multi method start-time($value)           { given (DRMAA_START_TIME) { LEAVE { .free }; self.attribute-store($_.Str, $value.Str) } }
    
    multi method transfer-files()       is rw { given (DRMAA_TRANSFER_FILES) { LEAVE { .free }; self.attribute($_.Str) } }
    multi method transfer-files($value)       { given (DRMAA_TRANSFER_FILES) { LEAVE { .free }; self.attribute-store($_.Str, $value.Str) } }
    
    multi method argv()                 is rw { given (DRMAA_V_ARGV) { LEAVE { .free }; self.vector-attribute($_.Str) } }
    multi method argv($value)                 { given (DRMAA_V_ARGV) { LEAVE { .free }; self.vector-attribute-store($_.Str, $value) } }

    multi method email()                is rw { given (DRMAA_V_EMAIL) { LEAVE { .free }; self.vector-attribute($_.Str) } }
    multi method email($value)                { given (DRMAA_V_EMAIL) { LEAVE { .free }; self.vector-attribute-store($_.Str, $value) } }
    
    multi method env()                  is rw { given (DRMAA_V_ENV) { LEAVE { .free }; self.vector-attribute($_.Str) } }
    multi method env($value)                  { given (DRMAA_V_ENV) { LEAVE { .free }; self.vector-attribute-store($_.Str, $value) } }
    
    multi method wct-hlimit()           is rw { given (DRMAA_WCT_HLIMIT) { LEAVE { .free }; self.attribute($_.Str) } }
    multi method wct-hlimit($value)           { given (DRMAA_WCT_HLIMIT) { LEAVE { .free }; self.attribute-store($_.Str, $value.Str) } }
    
    multi method wct-slimit()           is rw { given (DRMAA_WCT_SLIMIT) { LEAVE { .free }; self.attribute($_.Str) } }
    multi method wct-slimit($value)           { given (DRMAA_WCT_SLIMIT) { LEAVE { .free }; self.attribute-store($_.Str, $value.Str) } }
    
    multi method wd()                   is rw { given (DRMAA_WD) { LEAVE { .free }; self.attribute($_.Str) } }
    multi method wd($value)                   { given (DRMAA_WD) { LEAVE { .free }; self.attribute-store($_.Str, $value.Str) } }

    method after($after) {
	die X::NYI.new(:feature('Dependencies in ' ~ DRMAA::Session.native-specification.^name))
	unless Dependencies ∈ DRMAA::Session.native-specification.provides;
	
	for @$after -> $job { die X::TypeCheck.new(:got($job), :expected(DRMAA::Submission), :operation("binding"))
			      unless $job ~~ DRMAA::Submission };
	DRMAA::Session.native-specification.job-template-after(self, $after);
    }
    method afterend($after) {
        die X::NYI.new(:feature('Dependencies in ' ~ DRMAA::Session.native-specification.^name))
	unless Dependencies ∈ DRMAA::Session.native-specification.provides;

	for @$after -> $job { die X::TypeCheck.new(:got($job), :expected(DRMAA::Submission), :operation("binding"))
			      unless $job ~~ DRMAA::Submission };
	DRMAA::Session.native-specification.job-template-afterany(self, $after);
    }
    method afternotok($after) {
        die X::NYI.new(:feature('Dependencies in ' ~ DRMAA::Session.native-specification.^name))
	unless Dependencies ∈ DRMAA::Session.native-specification.provides;

	for @$after -> $job { die X::TypeCheck.new(:got($job), :expected(DRMAA::Submission), :operation("binding"))
			      unless $job ~~ DRMAA::Submission };
	DRMAA::Session.native-specification.job-template-aftenotok(self, $after);
    }
    method afterok($after) {
        die X::NYI.new(:feature('Dependencies in ' ~ DRMAA::Session.native-specification.^name))
	unless Dependencies ∈ DRMAA::Session.native-specification.provides;
	
	for @$after -> $job { die X::TypeCheck.new(:got($job), :expected(DRMAA::Submission), :operation("binding"))
			      unless $job ~~ DRMAA::Submission };
	DRMAA::Session.native-specification.job-template-afterok(self, $after);
    }
    
    method script(Str:D $script, :$tempdir = './.drmaa_scripts' --> Str) {
	use nqp;

	mkdir $tempdir unless $tempdir.IO.d;

	my $filename = nqp::sha1($script);
	my $fullname = "$tempdir/$filename";

	unless $fullname.IO.f && (nqp::sha1(slurp($fullname)) eq $filename) {
	    spurt $fullname, $script;
	    $fullname.IO.chmod: 0o700;

	    $*ERR.say("File $filename created and stored", 
		      " in $tempdir directory");
	}

	self.remote-command($*EXECUTABLE);
	self.argv(($fullname, |@*ARGS));
	self.env(%*ENV.kv.rotor(2).map: { .join("=") });

	$fullname
    };
    
    submethod BUILD(*%all) {
	if defined(%all<jt>) {
	    $!jt = %all<jt>;
	} else {
	    my $temp = Pointer[drmaa_job_template_t].new;
	    $!jt = drmaa_job_template_t.new;

	    my $error-buf = CBuffer.new(DRMAA_ERROR_STRING_BUFFER);
	    LEAVE { $error-buf.free; }

	    my $error-num = drmaa_allocate_job_template($temp, $error-buf, DRMAA_ERROR_STRING_BUFFER);

	    die X::DRMAA::from-code($error-num).new(:because($error-buf)) if ($error-num != DRMAA_ERRNO_SUCCESS);

	    $!jt = $temp.deref;
	}

	for %all.kv -> $name, $value {
	    next if $name eq "jt";
	    self."$name"($value);
	}

	True;
    }

    submethod DESTROY {
	my $error-buf = CBuffer.new(DRMAA_ERROR_STRING_BUFFER);
	LEAVE { $error-buf.free; }

	my $error-num = drmaa_delete_job_template($!jt, $error-buf, DRMAA_ERROR_STRING_BUFFER);

	die X::DRMAA::from-code($error-num).new(:because($error-buf)) if ($error-num != DRMAA_ERRNO_SUCCESS);
	True
    }

    method run(--> DRMAA::Submission) {
	my $error-buf = CBuffer.new(DRMAA_ERROR_STRING_BUFFER);
	my $jobid-buf = CBuffer.new(DRMAA_JOBNAME_BUFFER);
	LEAVE { $error-buf.free; $jobid-buf.free; }

	my $error-num = drmaa_run_job($jobid-buf, DRMAA_JOBNAME_BUFFER, $.jt,
				      $error-buf, DRMAA_ERROR_STRING_BUFFER);

	die X::DRMAA::from-code($error-num).new(:because($error-buf)) if ($error-num != DRMAA_ERRNO_SUCCESS);

	DRMAA::Submission.new(job-id => $jobid-buf.Str)
    };

    multi method run-bulk(Int:D $start, Int:D $end, Int :$by --> List) {
	my $error-buf = CBuffer.new(DRMAA_ERROR_STRING_BUFFER);
	my $jobid-ptr = Pointer[drmaa_job_ids_t].new;
	LEAVE { $error-buf.free; drmaa_release_job_ids($jobid-ptr.deref) }

	my $error-num = drmaa_run_bulk_jobs($jobid-ptr, $.jt, $start, $end, defined($by) ?? $by !! 1,
					    $error-buf, DRMAA_ERROR_STRING_BUFFER);

	die X::DRMAA::from-code($error-num).new(:because($error-buf)) if ($error-num != DRMAA_ERRNO_SUCCESS);

	(Seq.new($jobid-ptr.deref).map: { LEAVE { .free }; DRMAA::Submission.new(job-id => .Str) }).list.eager
    };

    multi method run-bulk(Range:D $range, Int :$by --> List) {
	die "Not going to submit an infinite number of jobs" if $range.inifinte;
	my ($start, $end) = $range.minmax;
        self.run-bulk($start, $end, :$by);
    }

    multi method run-bulk(Int:D $size --> List) {
	self.run-bulk(1, $size, 1);
    }
}
