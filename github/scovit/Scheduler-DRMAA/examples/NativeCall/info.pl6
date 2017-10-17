use v6.d.PREVIEW;
use DRMAA::NativeCall;
use NativeCall :types;
use NativeHelpers::CBuffer;

my $error        = CBuffer.new(DRMAA_ERROR_STRING_BUFFER);
my int32 $errnum = 0;
my $contact      = CBuffer.new(DRMAA_CONTACT_BUFFER);
my $drm_system   = CBuffer.new(DRMAA_DRM_SYSTEM_BUFFER);
my $drmaa_impl   = CBuffer.new(DRMAA_DRM_SYSTEM_BUFFER);
my int32 $major  = 0;
my int32 $minor  = 0;

$errnum = drmaa_get_contact($contact, DRMAA_CONTACT_BUFFER,
			    $error, DRMAA_ERROR_STRING_BUFFER);

if ($errnum != DRMAA_ERRNO_SUCCESS) {
    warn "Could not get the contact string list: ", $error;
}
else {
    say 'Supported contact strings: "', $contact, '"';
}

$errnum = drmaa_get_DRM_system($drm_system, DRMAA_DRM_SYSTEM_BUFFER,
			       $error, DRMAA_ERROR_STRING_BUFFER);

if ($errnum != DRMAA_ERRNO_SUCCESS) {
    warn "Could not get the DRM system list: ", $error;
}
else {
    say 'Supported DRM systems: "', $drm_system, '"';
}

$errnum = drmaa_get_DRMAA_implementation($drmaa_impl, DRMAA_DRM_SYSTEM_BUFFER,
                                         $error, DRMAA_ERROR_STRING_BUFFER);

if ($errnum != DRMAA_ERRNO_SUCCESS) {
    warn "Could not get the DRMAA implementation list: ", $error;
}
else {
    say 'Supported DRMAA implementations: "', $drmaa_impl, '"';
}

$errnum = drmaa_init((CBuffer), $error, DRMAA_ERROR_STRING_BUFFER);

if ($errnum != DRMAA_ERRNO_SUCCESS) {
    die "Could not initialize the DRMAA library: ", $error;
}

$errnum = drmaa_get_contact($contact, DRMAA_CONTACT_BUFFER,
			    $error, DRMAA_ERROR_STRING_BUFFER);

if ($errnum != DRMAA_ERRNO_SUCCESS) {
    die "Could not get the contact string: ", $error;
}
else {
    say 'Connected contact string: "', $contact, '"';
}

$errnum = drmaa_get_DRM_system($drm_system, DRMAA_CONTACT_BUFFER,
			       $error, DRMAA_ERROR_STRING_BUFFER);

if ($errnum != DRMAA_ERRNO_SUCCESS) {
    warn 'Could not get the DRM system: ', $error;
}
else {
    say 'Connected DRM system: "', $drm_system, '"';
}

$errnum = drmaa_get_DRMAA_implementation($drmaa_impl, DRMAA_DRM_SYSTEM_BUFFER,
                                         $error, DRMAA_ERROR_STRING_BUFFER);

if ($errnum != DRMAA_ERRNO_SUCCESS) {
    warn "Could not get the DRMAA implementation list: ", $error;
}
else {
    say 'Supported DRMAA implementations: "', $drmaa_impl, '"';
}
 
$errnum = drmaa_version($major, $minor,
			$error, DRMAA_ERROR_STRING_BUFFER);

if ($errnum != DRMAA_ERRNO_SUCCESS) {
    warn "Could not get the DRMAA version: ", $error;
}
else {
    say "Using DRMAA version $major.$minor";
}
    
$errnum = drmaa_exit($error, DRMAA_ERROR_STRING_BUFFER);
 
if ($errnum != DRMAA_ERRNO_SUCCESS) {
    die "Could not shut down the DRMAA library: ", $error;
}
