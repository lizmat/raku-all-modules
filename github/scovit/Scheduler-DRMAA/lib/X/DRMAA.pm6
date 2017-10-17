use v6.d.PREVIEW;
unit module X::DRMAA:ver<0.0.1>:auth<Vittore F Scolari (vittore.scolari@gmail.com)>;

use NativeHelpers::CBuffer;

role X::DRMAA is Exception {
    has Str $.because;

    submethod BUILD(:because(:$reason)) {
	if ($reason ~~ Str) {
	    $!because := $reason;
	} else {
	    $!because = $reason.Str;
	}
    }
}

class X::DRMAA::Success does X::DRMAA {
    method message() {
	"No error happened, you told me to fail xD";
    }
}

class X::DRMAA::Internal does X::DRMAA {
    method message() {
        "Internal error: $.because";
    }
}

class X::DRMAA::DRM-communication does X::DRMAA {
    method message() {
        "DRM communication: $.because"
    }
}

class X::DRMAA::Auth does X::DRMAA {
    method message() {
        "Authorization error: $.because"
    }
}

class X::DRMAA::Invalid-argument does X::DRMAA {
    method message() {
        "Invalid argument: $.because"
    }
}

class X::DRMAA::No-active-session does X::DRMAA {
    method message() {
        "No active session: $.because"
    }
}

class X::DRMAA::No-memory does X::DRMAA {
    method message() {
        "Out of memory: $.because"
    }
}

class X::DRMAA::Invalid-contact-string does X::DRMAA {
    method message() {
        "Invalid contact string: $.because"
    }
}

class X::DRMAA::Default-contact-string does X::DRMAA {
    method message() {
        "Default contact string: $.because"
    }
}

class X::DRMAA::No-default-contact-string-selected does X::DRMAA {
    method message() {
        "No default contact string selected: $.because"
    }
}

class X::DRMAA::DRMS-init-failed does X::DRMAA {
    method message() {
        "DRMS init failed: $.because"
    }
}

class X::DRMAA::Already-active-session does X::DRMAA {
    method message() {
        "Already active session: $.because"
    }
}

class X::DRMAA::DRMS-exit-error does X::DRMAA {
    method message() {
        "DRMS exit error: $.because"
    }
}

class X::DRMAA::Invalid-attribute-format does X::DRMAA {
    method message() {
        "Invalid attribute format: $.because"
    }
}

class X::DRMAA::Invalid-attribute-value does X::DRMAA {
    method message() {
        "Invalid attribute value: $.because"
    }
}

class X::DRMAA::Conflicting-attribute-values does X::DRMAA {
    method message() {
        "Conflicting attribute values: $.because"
    }
}

class X::DRMAA::Try-later does X::DRMAA {
    method message() {
        "Try later: $.because"
    }
}

class X::DRMAA::Denied-by-DRM does X::DRMAA {
    method message() {
        "Denied by DRM: $.because"
    }
}

class X::DRMAA::Invalid-job does X::DRMAA {
    method message() {
        "Invalid job: $.because"
    }
}

class X::DRMAA::Resume-inconsistent-state does X::DRMAA {
    method message() {
        "Resume in an inconsistent state: $.because"
    }
}

class X::DRMAA::Suspend-inconsistent-state does X::DRMAA {
    method message() {
        "Suspend in an inconsistent state: $.because"
    }
}

class X::DRMAA::Hold-inconsistent-state does X::DRMAA {
    method message() {
        "Hold in an inconsistent state: $.because"
    }
}

class X::DRMAA::Release-inconsistent-state does X::DRMAA {
    method message() {
        "Release in an inconsistent state: $.because"
    }
}

class X::DRMAA::Exit-timeout does X::DRMAA {
    method message() {
        "Exit timeout expired: $.because"
    }
}

class X::DRMAA::No-rusage does X::DRMAA {
    method message() {
        "No rusage: $.because"
    }
}

class X::DRMAA::No-more-elements does X::DRMAA {
    method message() {
        "No more elements: $.because"
    }
}

class X::DRMAA::Unknown does X::DRMAA {
    method message() {
        "Exceptional error: $.because"
    }
}

my $codes = (
    X::DRMAA::Success,
    X::DRMAA::Internal,
    X::DRMAA::DRM-communication,
    X::DRMAA::Auth,
    X::DRMAA::Invalid-argument,
    X::DRMAA::No-active-session,
    X::DRMAA::No-memory,
    X::DRMAA::Invalid-contact-string,
    X::DRMAA::Default-contact-string,
    X::DRMAA::No-default-contact-string-selected,
    X::DRMAA::DRMS-init-failed,
    X::DRMAA::Already-active-session,
    X::DRMAA::DRMS-exit-error,
    X::DRMAA::Invalid-attribute-format,
    X::DRMAA::Invalid-attribute-value,
    X::DRMAA::Conflicting-attribute-values,
    X::DRMAA::Try-later,
    X::DRMAA::Denied-by-DRM,
    X::DRMAA::Invalid-job,
    X::DRMAA::Resume-inconsistent-state,
    X::DRMAA::Suspend-inconsistent-state,
    X::DRMAA::Hold-inconsistent-state,
    X::DRMAA::Release-inconsistent-state,
    X::DRMAA::Exit-timeout,
    X::DRMAA::No-rusage,
    X::DRMAA::No-more-elements,
    X::DRMAA::Unknown
);

our sub from-code(Int:D $num --> X::DRMAA) {
    return $codes[$num];
}
