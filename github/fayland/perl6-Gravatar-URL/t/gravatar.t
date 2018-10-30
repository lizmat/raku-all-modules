use Test;
use Gravatar::URL;

is gravatar_id('whatever@wherever.whichever'), 'a60fc0828e808b9a6a9d50f1792240c8', 'gravatar_id';

throws-like { gravatar_url() }, X::AdHoc, 'throw gravatar_url without email';

# is gravatar_url('whatever@wherever.whichever'),
#     'http://www.gravatar.com/avatar/a60fc0828e808b9a6a9d50f1792240c8', 'email 1 ok';

is gravatar_url(
    :email<whatever@wherever.whichever>
), 'http://www.gravatar.com/avatar/a60fc0828e808b9a6a9d50f1792240c8', 'email ok';

is gravatar_url(
    :email<a60fc0828e808b9a6a9d50f1792240c8>
), 'http://www.gravatar.com/avatar/a60fc0828e808b9a6a9d50f1792240c8', 'id ok';

is gravatar_url(
    :email<whatever@wherever.whichever>,
    :https<true>
), 'https://secure.gravatar.com/avatar/a60fc0828e808b9a6a9d50f1792240c8', 'https';

is gravatar_url(
    :email<whatever@wherever.whichever>,
    default => '/local.png',
), 'http://www.gravatar.com/avatar/a60fc0828e808b9a6a9d50f1792240c8?d=%2Flocal.png', 'default';

is gravatar_url(
    :email<whatever@wherever.whichever>,
    default => '/local.png',
    :rating<X>
), 'http://www.gravatar.com/avatar/a60fc0828e808b9a6a9d50f1792240c8?r=x&d=%2Flocal.png', 'rating';

is gravatar_url(
    :email<whatever@wherever.whichever>,
    default => '/local.png',
    :rating<R>,
    :size<80>
), 'http://www.gravatar.com/avatar/a60fc0828e808b9a6a9d50f1792240c8?r=r&s=80&d=%2Flocal.png', 'size';

is gravatar_url(
    :email<whatever@wherever.whichever>,
    default => '/local.png',
    :rating<R>,
    :size<80>,
    :short_keys<0>
), 'http://www.gravatar.com/avatar/a60fc0828e808b9a6a9d50f1792240c8?rating=r&size=80&default=%2Flocal.png', 'short_key';

done-testing();