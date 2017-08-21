
[![Build Status](https://travis-ci.org/supernovus/perl6-htto-status.png)](https://travis-ci.org/supernovus/perl6-http-status)

HTTP::Status -- Get the text message representing an HTTP status code.

This is a module that exports a single subroutine:
```perl6
  get_http_status_msg()
```
It's usage is simple:
```perl6
  get_http_status_msg($code);
```
Where $code is the numeric HTTP status code, such as 200 or 404.
It will return the text message that the code represents.

Author: Timothy Totten
License: Artistic License 2.0

