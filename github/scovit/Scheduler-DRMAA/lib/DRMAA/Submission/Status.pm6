use v6.d.PREVIEW;
unit module DRMAA::Submission::Status:ver<0.0.1>:auth<Vittore F Scolari (vittore.scolari@gmail.com)>;

use DRMAA::NativeCall;

# The following two are emitted when a job is done
class X::DRMAA::Submission::Status::Aborted is Exception {
    has Str  $.id;
    has Bool $.exited;
    has Int  $.exit-code;
    has Str  $.signal;
    has Str  $.usage;

    method message(--> Str:D) {
	"Job $.id aborted";
    }
}

class DRMAA::Submission::Status::Succeded {
    has Str  $.id;
    has Bool $.exited;
    has Int  $.exit-code;
    has Str  $.signal;
    has Str  $.usage;
}

# The following are returned by .status method on a DRMAA::Submission instance

class DRMAA::Submission::Status::Undetermined { }
class DRMAA::Submission::Status::Queued-active { }
class DRMAA::Submission::Status::System-on-hold { }
class DRMAA::Submission::Status::User-on-hold { }
class DRMAA::Submission::Status::User-system-on-hold { }
class DRMAA::Submission::Status::Running { }
class DRMAA::Submission::Status::System-suspended { }
class DRMAA::Submission::Status::User-suspended { }
class DRMAA::Submission::Status::User-system-suspended { }
class DRMAA::Submission::Status::Done { }
class DRMAA::Submission::Status::Failed { }
class DRMAA::Submission::Status::Unimplemented { }

our sub from-code(Int:D $num) {
    given $num {
	when DRMAA_PS_UNDETERMINED { Undetermined }
	when DRMAA_PS_QUEUED_ACTIVE { Queued-active }
	when DRMAA_PS_SYSTEM_ON_HOLD { System-on-hold }
	when DRMAA_PS_USER_ON_HOLD { User-on-hold }
	when DRMAA_PS_USER_SYSTEM_ON_HOLD { User-system-on-hold }
	when DRMAA_PS_RUNNING { Running }
	when DRMAA_PS_SYSTEM_SUSPENDED { System-suspended }
	when DRMAA_PS_USER_SUSPENDED { User-suspended }
	when DRMAA_PS_USER_SYSTEM_SUSPENDED { User-system-suspended }
	when DRMAA_PS_DONE { Done }
	when DRMAA_PS_FAILED { Failed }
	default { Unimplemented }
    }
}
