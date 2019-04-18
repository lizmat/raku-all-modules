[![Build Status](https://travis-ci.org/atroxaper/p6-LogP6-Writer-Journald.svg?branch=master)](https://travis-ci.org/atroxaper/p6-LogP6-Writer-Journald)

# NAME

**LogP6::Writer::Journald** - writer implementation for `journald` - a system
service for collecting and storing log data, introduced with `systemd`.

# TABLE OF CONTENTS

- [NAME](#name)
- [SYNOPSIS](#synopsis)
- [CONFIGURATION](#configuration)
- [EXAMPLES](#examples)
- [REQUIREMENTS](#requirements)
- [AUTHOR](#author)
- [COPYRIGHT AND LICENSE](#copyright-and-license)

# SYNOPSIS

`LogP6` can be adopted for your any logging need. This module provides
possibility to write your logs in `journald`;

# CONFIGURATION

You can configure the writer from code by instantiating object of
`LogP6::WriterConf::Journald` class. It takes the following parameters:

- `name` - name of the writer configuration;
- `pattern` - string with special placeholders for values like `ndc`, current
`Thread` name, log message and so. The same as in standard LogP6 writer;
- `auto-exception` - boolean property. If it is `True` then placeholder for
exception will be concatenated to the `pattern` automatically. The same as in
standard LogP6 writer;
- `systemd` - implementation of `LogP6::Writer::Journald::Systemd`, object which
sends logs to `journald` service. You can specify your own implementation.
Default `LogP6::Writer::Journald::Systemd::Native` which uses native calls to
`systemd` library;
- `use-priority` - boolean property. If it is `True`, then `journald`'s
`PRIORITY=` field will be written automatically based on log level (`trace=7`,
`debug=6`, `info=5`, `warn=4`, `error=3`);
- `use-mdc` - boolean property. If it is `True`, then all content of LogP6 `MDC`
will be passed to `journald` as `key=value` fields. You can use up to 30 `MDC`
values. Note, that `journald`'s field name must be in uppercase and consist only
of characters, numbers and underscores, and may not begin with an underscore.
All assignments that do not follow this syntax will be ignored. Default `False`;
- `use-code-file` - boolean property. If it is `True`, then `journald`'s
`CODE_FILE=` field will be written automatically based on `callframe`. Default
`False`;
- `use-code-line` - boolean property. If it is `True`, then `journald`'s
`CODE_LINE=` field will be written automatically based on `callframe`. Default
`False`;
- `use-code-func` - boolean property. If it is `True`, then `journald`'s
`CODE_FUNC=` field will be written automatically based on `callframe`. Default
`False`;

Note that using `use-code-file`, `use-code-line` or `use-code-func` properties
will slow your program because it requires several `callframe` calls on each
resultative log call;

Also you can configure the writer in configuration file uses `custom` type
writer and `"fqn-class": "LogP6::WriterConf::Journald"` as any other
configurations in LogP6.

# EXAMPLES

You can see example of using LogP6 in its README. Here are examples of
`journald` writer configuration.

In `Perl 6`:

```perl6
use LogP6 :configure;
use LogP6::WriterConf::Journald;

writer(LogP6::WriterConf::Journald.new(
  # name, pattern and auto-exceptions as in standard writer
  :name<to-journald>, :pattern('%msg'), :auto-exeptions
  # which additional information must be written
  :use-priority,
  :use-code-line,
  :use-code-file,
  :use-code-func,
  :use-mdc
  # if you want to use custom systemd connector
  # :systemd(CustomSystemd.new)
));
```

Or in configuration file:

```json
{"writers": [{
  "type": "custom",
  "require": "LogP6::WriterConf::Journald",
  "fqn-class": "LogP6::WriterConf::Journald",
  "args": {
    "name": "to-journald",
    "pattern": "%msg",
    "auto-exceptions": true,
    "use-priority": true,
    "use-code-file": true,
    "use-code-line": true,
    "use-code-func": true,
    "use-mdc": true
  }
}]}
```

# REQUIREMENTS

By default the writer uses native call to `systemd` library. If you do not want
to provide your own `LogP6::Writer::Journald::Systemd` implementation then you
need to have `systemd` library on host you run a program. On Ubuntu machine you
can install it like:

```bash
sudo apt-get install libsystemd-dev
```

# AUTHOR

Mikhail Khorkov <atroxaper@cpan.org>

Source can be located at: https://github.com/atroxaper/p6-LogP6-Writer-Journald.
Comments and Pull Requests are welcome.

# COPYRIGHT AND LICENSE

Copyright 2019 Mikhail Khorkov

This library is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.