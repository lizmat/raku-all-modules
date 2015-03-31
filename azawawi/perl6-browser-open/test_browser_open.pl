use v6;

BEGIN { @*INC.push('lib') };

use Browser::Open;

open_browser("http://github.com");
