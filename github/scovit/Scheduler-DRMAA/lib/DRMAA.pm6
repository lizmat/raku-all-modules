use v6.d.PREVIEW;
unit module DRMAA:ver<0.0.1>:auth<Vittore F Scolari (vittore.scolari@gmail.com)>;

# see Scheduler::DRMAA for the documentation

use DRMAA::Session;
use DRMAA::NativeCall;
use X::DRMAA;
use DRMAA::Job-template;
use DRMAA::Submission;
use DRMAA::Submission::Status;

# multi sub await (DRMAA::Submission:D $s) is export {
#     $s.result;
# }

# multi sub await(*@awaitables) is export { @awaitables.eager.map({await $_}) }
