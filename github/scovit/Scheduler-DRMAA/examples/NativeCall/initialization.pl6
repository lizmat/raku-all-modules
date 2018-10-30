use v6.d.PREVIEW;
use DRMAA::NativeCall;
use NativeHelpers::CBuffer;

my $error  = CBuffer.new(DRMAA_ERROR_STRING_BUFFER);

# Object creation, also, create an exception (to emit it instead of dieing)
my $errnum = drmaa_init((CBuffer), $error, DRMAA_ERROR_STRING_BUFFER);

if ($errnum != DRMAA_ERRNO_SUCCESS) {
    die "Could not initialize the DRMAA library: ", $error;
}

say "DRMAA library was started successfully";

# This can stay in object distruction
$errnum = drmaa_exit($error, DRMAA_ERROR_STRING_BUFFER);
 
if ($errnum != DRMAA_ERRNO_SUCCESS) {
    die "Could not shut down the DRMAA library: ", $error;
}
