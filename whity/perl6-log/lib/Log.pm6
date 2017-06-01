use Log::NDC;
use Log::MDC;
use Log::Exceptions;

unit class Log;

enum Level <ERROR WARN INFO DEBUG TRACE>;

has Level $.level is rw;
has IO::Handle $.output;
has Str $.pattern;
has Log::NDC $.ndc;
has Log::MDC $.mdc;

submethod BUILD(*%args) {
    $!level = %args{'level'} || INFO;
    $!output = %args{'output'} || $*OUT;
    $!pattern = %args{'pattern'} || '[%d][%c] %m%n';

    $!ndc = %args{'ndc'} || Log::NDC.new;
    $!mdc = %args{'mdc'} || Log::MDC.new;

    return self;
}

multi method FALLBACK(Str $name, |args) {
    return self!log($name.uc, |@(args));
}

multi method FALLBACK(Str $name where /^is\-.+$/, |args) {
    my $lvl = ($name ~~ /^is\-(.+)$/)[0].Str;
    $lvl = self!get-level($lvl);

    if ($lvl.value <= self.level.value) {
        return True;
    }

    return False;
}

method !get-level(Str $level is copy) {
    $level = $level.uc;
    my $exists = Level.enums.first({ .key eq $level });
    if ($exists) {
        return $exists;
    }

    # throw exception "InvalidLogLevel"
    X::Log::InvalidLevelException.new(level => $level).throw;
}

method !log(Str $level, Str $message) {
    my $lvl = self!get-level($level);
    if ($lvl.value > self.level.value) {
        return self;
    }

    # build log message
    my $output = self.pattern;

    my $replace_placeholder = sub ($str is copy, $placeholder, $value) {
        $str ~~ s:g/(^|\s*)(\[?)$placeholder(\]?)(\s*|$)/$0$1$value$2$3/;
        return $str;
    };

    # replace %m
    $output = $replace_placeholder($output, '%m', $message);

    # replace %d
    $output = $replace_placeholder($output, '%d', DateTime.now.Str);

    # replace %c - level
    $output = $replace_placeholder($output, '%c', $level);

    # replace %n - new line
    $output = $replace_placeholder($output, '%n', "\n");

    # replace %x - NDC
    $output = $replace_placeholder($output, '%x', self.ndc.get);

    # replace %p - process id
    $output = $replace_placeholder($output, '%p', $*PID);

    # replace %X - MDC
    while ((my $match = $output ~~ /(^|\s*)(\[?)\%X\{$<key>=\w+\}(\]?)(\s*|$)/)) {
        my $key = ~($match{'key'});
        my $value = self.mdc.get($key);
        $output = $replace_placeholder($output, sprintf('%%X{%s}', $key), $value);
    }

    # print output
    self.output.print($output);

    return self;
}
