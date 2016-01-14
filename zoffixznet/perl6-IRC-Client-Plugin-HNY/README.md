[![Build Status](https://travis-ci.org/zoffixznet/perl6-IRC-Client-Plugin-HNY.svg)](https://travis-ci.org/zoffixznet/perl6-IRC-Client-Plugin-HNY)

# NAME

IRC::Client::Plugin::HNY - plugin for New Year's IRC parties

# SYNOPSIS

```perl6
    use IRC::Client;
    use IRC::Client::Plugin::HNY;

    IRC::Client.new(
        :host('irc.freenode.net'),
        :channels('#freenode-newyears'),
        plugins => [ IRC::Client::Plugin::HNY.new ]
    ).run;
```

```irc
<Zoffix> hny Toronto
<HNYBot> New year in Toronto, Canada will happen in 5 minutes and 11 seconds
...
<HNYBot> Happy New Year to Toronto, Canada; New York, USA (UTC-4)
...
<Zoffix> hny
<HNYBot> the next new year is 30 minutes and 6 seconds in Chicago, USA (UTC-5)
...
<Zoffix> hny Toronto
<HNYBot> New Year in Toronto already happened 40 minutes and 36 seconds ago
```

# DESCRIPTION

`::HNY` stands for `Happy New Year`. This bot announces New Years in most (all?)
timezones around the globe, including the major countries/cities in those
timezones. Directly addressing the bot with `hny` command makes it say when
and where the next New Year is expected to happen. Providing an arbitrary
location as an argument to the `hny` command will make the bot look up the
timezone of that location and calculate when the New Year will happen there.

# REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-IRC-Client-Plugin-HNY

# BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-IRC-Client-Plugin-HNY/issues

# AUTHOR

Zoffix Znet (http://zoffix.com/)

# LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.
