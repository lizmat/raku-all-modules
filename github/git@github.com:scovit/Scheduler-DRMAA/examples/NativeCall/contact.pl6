use v6.d.PREVIEW;
use DRMAA::NativeCall;
use NativeHelpers::CBuffer;

my $error   = CBuffer.new(DRMAA_ERROR_STRING_BUFFER);
my $errnum  = 0;
my $contact = CBuffer.new(DRMAA_CONTACT_BUFFER);

$errnum = drmaa_init((CBuffer), $error, DRMAA_ERROR_STRING_BUFFER);

if ($errnum != DRMAA_ERRNO_SUCCESS) {
    die "Could not initialize the DRMAA library: ", $error;
}

say "DRMAA library was started successfully";

$errnum = drmaa_get_contact($contact, DRMAA_CONTACT_BUFFER, $error,
			    DRMAA_ERROR_STRING_BUFFER);

if ($errnum != DRMAA_ERRNO_SUCCESS) {
    die "Could not get the contact string: ", $error;
}

$errnum = drmaa_exit($error, DRMAA_ERROR_STRING_BUFFER);
 
if ($errnum != DRMAA_ERRNO_SUCCESS) {
    die "Could not shut down the DRMAA library: ", $error;
}

$errnum = drmaa_init($contact, $error, DRMAA_ERROR_STRING_BUFFER);

if ($errnum != DRMAA_ERRNO_SUCCESS) {
    die "Could not reinitialize the DRMAA library: ", $error;
}

say "DRMAA library was restarted successfully";

$errnum = drmaa_exit($error, DRMAA_ERROR_STRING_BUFFER);
 
if ($errnum != DRMAA_ERRNO_SUCCESS) {
    die "Could not shut down the DRMAA library: ", $error;
}
