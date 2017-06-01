use v6;

use Test;
use Log;

class Handle is IO::Handle {
    has Str $!message;

    method get() { return $!message; }
    method print($value) {
        $!message = $value;
        return self;
    }
}

my $log = Log.new(output => Handle.new);

# write message
my $msg = 'info test message';
$log.info($msg);
like($log.output.get, /$msg/, 'message in log');

# try to write a message in level not included in current level
$msg = 'trace test message';
$log.trace($msg);
unlike($log.output.get, /$msg/, 'message not in the log');

# try to write a invalid level
throws-like({ $log.tracerr($msg) }, X::Log::InvalidLevelException);

done-testing;
