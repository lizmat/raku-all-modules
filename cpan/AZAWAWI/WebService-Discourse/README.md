# WebService::Discourse

 [![Build Status](https://travis-ci.org/azawawi/p6-webservice-discourse.svg?branch=master)](https://travis-ci.org/azawawi/p6-webservice-discourse) [![Build status](https://ci.appveyor.com/api/projects/status/github/azawawi/p6-webservice-discourse?svg=true)](https://ci.appveyor.com/project/azawawi/p6-webservice-discourse/branch/master)

Use [Discourse](https://discourse.org) [REST API](https://docs.discourse.org/)
in Perl 6.

**Note: This is currently experimental and API may change. Please DO NOT use in
a production environment.**

## Example

```perl6
use v6;
use WebService::Discourse;

#TODO complete example
```

For more examples, please see [examples](examples).

## Installation

- Install this module using [zef](https://github.com/ugexe/zef):

```
$ zef install WebService::Discourse
```

## Testing

- To run tests:
```
$ AUTHOR_TESTING=1 zef test --verbose .
```

- To run all tests including author tests (Please make sure
[Test::Meta](https://github.com/jonathanstowe/Test-META) is installed):
```
$ zef install Test::META
$ AUTHOR_TESTING=1 prove -e "perl6 -Ilib"
```

## See Also
- [Ruby API for Discourse](https://github.com/discourse/discourse_api)
- [Discourse API Documentation (latest)](https://docs.discourse.org/)

## Author

Ahmad M. Zawawi, [azawawi](https://github.com/azawawi/) on #perl6.

## License

[MIT License](LICENSE)
