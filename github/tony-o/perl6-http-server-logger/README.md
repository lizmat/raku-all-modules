# HTTP::Server::Logger

Uses apache log format for logging, you can specify custom formats also.

By default this module uses the common log format specified by Apache.

## usage

```perl6
use HTTP::Server::Logger;
use HTTP::Server::Threaded;

qw<... set up server stuff ...>;

my HTTP::Server::Logger $log .= new;

$server.after($log.logger); #the logger now logs when the server is closed

$log.format('[%s] %t %U'); #set the format for the log

$log.pretty-log; #use a pretty format '[%s] %{%Y/%m/%d %H:%m}t %U'

$server.listen;
```

## custom logger

you can use this logger for custom logging as long as you're okay with the apache log format

```perl6
use HTTP::Server::Logger;

my HTTP::Server::Logger $log .= new(fmt => '%t %Z');

$log.log({
  t => 'something t',
  Z => 'something Z',
});

# output: 'something t something Z'
```

need some custom formatting for Z?

```perl6
my HTTP::Server::Logger $log .= new(fmt => '%t %Z');

$log.custom<Z> = sub ($data) { return $data.UC; };

$log.log({
  t => 'something t',
  Z => 'lowercase',
});

# output: 'something t LOWERCASE'
```
