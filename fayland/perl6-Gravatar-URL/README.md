# perl6-Gravatar-URL - Make URLs for Gravatars from an email address

[![Build Status](https://travis-ci.org/fayland/perl6-Gravatar-URL.svg?branch=master)](https://travis-ci.org/fayland/perl6-Gravatar-URL)

## SYNOPSIS

```
use Gravatar::URL;

my $gravatar_id = gravatar_id('whatever@wherever.whichever'); # 'a60fc0828e808b9a6a9d50f1792240c8'

my $gravator_url = gravatar_url(
    :email<whatever@wherever.whichever>,
    :size<32>
);

my $gravator_url = gravatar_url(
    :email<whatever@wherever.whichever>,
    default => '/local.png',
    :rating<R>,
    :size<80>,
    :short_keys<0>,
    :https<1>
);
```

## DESCRIPTION

 * email - required, if Str.chars=32 passed, we'll treat it as id
 * default - default image
 * rating - G, PG, R, X
 * size - Int 1 to 512
 * short_keys - use r instead of rating, d instead of default in url
 * https - use https://secure.gravatar.com/avatar/ instead of http://www.gravatar.com/avatar/ as the base
