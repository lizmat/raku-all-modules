#Linux::Process::SignalInfo

#Description

Show process signal information in Linux

#Installation

```
panda install Linux::Process::SignalInfo
```

#Usage

```perl
use v6;
use Linux::Process::SignalInfo;

# Create new signal info instance for PID 1
my $signal_info = Linux::Process::SignalInfo.new(pid => 1);

# Read process signal information
$signal_info.read;

# Parse signal info to make it human readable
$signal_info.parse;

# Pretty print
$signal_info.pprint;

```
Output:
```
Blocked: [SIGHUP SIGINT SIGUSR1 SIGUSR2 SIGTERM SIGCHLD SIGWINCH SIGPWR]
Ignored: [SIGPIPE]
Catched: [SIGQUIT SIGILL SIGABRT SIGBUS SIGFPE SIGSEGV]
```

#Author

Cuong Manh Le <cuong.manhle.vn@gmail.com>

#License

See [LICENSE](https://github.com/Gnouc/p6-linux-process-signalinfo/blob/master/LICENSE)
