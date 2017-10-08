# Log

A simple logging class in perl6.

## Usage

```perl6
use Log;

sub MAIN() {
    my $log = Log.new;
    # by default the log level is INFO and the output is $*OUT (can be any IO::Handle)
    # Log.new(level => Log::DEBUG, output => $*ERR)

    # log a message
    $log.trace('trace message');
    $log.debug('debug message');
    $log.info('info message');
    $log.warn('warn message');
    $log.error('error message');

    # ndc
    $log.ndc.push('xxx'); # add a value to the stack
    $log.ndc.pop(); # remove the last item from the stack


    # mdc
    $log.mdc.put('key', 'value');

    # change the level
    $log.level = Log::DEBUG;
    $log.debug('debug message');

    # checking the current log level
    say $log.is-error;
    say $log.is-info;

    # log pattern placeholders
    #   %m -> message
    #   %d -> current datetime
    #   %c -> message level
    #   %n -> new line feed '\n'
    #   %p -> process id
    #   %x -> NDC
    #   %X{key-name} -> MDC

    $log.pattern = '%X{key} %x %m%n';
    $log.info('test');

    # register log object to use in other places
    Log.add('log-name', Log.new);
    #Log.add(Log.new) # register the log object as 'main'

    # get a registered log object
    my $rlog = Log.get('log-name');
    #my $rlog = Log.get; returns the log object 'main'

    $rlog.info('from "log-name"');
}
```
## Contributing

1. Fork it ( https://github.com/[your-github-name]/perl6-hematite/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- whity(https://github.com/whity) André Brás - creator, maintainer
