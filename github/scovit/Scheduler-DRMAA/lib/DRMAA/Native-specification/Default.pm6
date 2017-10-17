use v6.d.PREVIEW;
unit module DRMAA::Native-specification::Default:ver<0.0.1>:auth<Vittore F Scolari (vittore.scolari@gmail.com)>;

use DRMAA::Native-specification;
use DRMAA::Session;
use DRMAA::Submission;
use DRMAA::Job-template;

class DRMAA::Native-specification::Default does DRMAA::Native-specification {
    submethod TWEAK {
	warn 'WARNING, DRM-system "', DRMAA::Session.DRM-system, '" unknown', "\n",
	     "Using default Native specification plugin, it is incomplete,\n",
	     "please implement one for your configuration,\n",
	     "patches are wellcome!\n";
    }

    method provides(--> List) {
	();
    }
}

