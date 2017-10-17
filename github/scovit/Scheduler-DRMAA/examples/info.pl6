use v6.d.PREVIEW;
use DRMAA;

say 'Supported contact strings: "',       DRMAA::Session.contact, '"';
say 'Supported DRM systems: "',           DRMAA::Session.DRM-system, '"';
say 'Supported DRMAA implementations: "', DRMAA::Session.implementation, '"';

DRMAA::Session.init;

say 'Supported contact strings: "',       DRMAA::Session.contact, '"';
say 'Supported DRM systems: "',           DRMAA::Session.DRM-system, '"';
say 'Supported DRMAA implementations: "', DRMAA::Session.implementation, '"';

say 'Using DRMAA version: ', DRMAA::Session.version;

DRMAA::Session.exit;
