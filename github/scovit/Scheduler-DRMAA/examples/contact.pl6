use v6.d.PREVIEW;
use DRMAA;

DRMAA::Session.init; # Error handling is automatic

say "DRMAA library was started successfully";

my $contact = DRMAA::Session.contact;

DRMAA::Session.exit;

DRMAA::Session.init(contact => $contact);

say "DRMAA library was restarted successfully";

DRMAA::Session.exit;
