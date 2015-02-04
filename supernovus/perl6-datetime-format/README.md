# DateTime::Format

## Description

Provides strftime(), strptime() (coming soon), and a few predetermined 
formats for use with both. 

It also comes with some localizations for month and day names.

## Convenience subroutines

These are exported by ```use DateTime::Format```

## strftime (Str $format, DateTime $dt, :$lang)

Format the DateTime object using the format as specified in the string.

If you don't specify the language, it uses the currently set default.

## strptime (Str $timestamp, Str $format, :$lang)

Parse the string using the format as specified in the second string.

If you don't specify the language, it uses the currently set default.

## set-datetime-format-lang (Str $code)

Set the default language to use. This can be 'en' (the default language),
or any language you have added using one of the Localization libraries.

## Formats

### DateTime::Format::RFC2822

Parse or Stringify a DateTime in the RFC 2822 format.

```perl

  my $ts = 'Tue, 30 Apr 2013 13:02:10 -0700';
  my $rfc = DateTime::Format::RFC2822.new();
  my $dt  = $rfc.parse($ts);
  my $dt2 = $dt.utc();
  say ~$dt2;                   ## Tue, 30 Apr 2013 20:02:10 Z

```

## Localizations

The default localization is English, using the code 'en'.
There is no loadable module for English, since it's strings are included
by default in the DateTime::Format module.

The following are additional libraries that can add localizations to the
DateTime::Format library. The languages will then be immediately usable.

 * DateTime::Format::Lang::FR -- French

```perl

  use DateTime::Format::Lang::FR;
  set-datetime-lang('fr');

  ## You can also specify the :lang<fr> parameter to the
  ## strftime(), strptime() subroutines, or the parse() and format()
  ## methods within a DateTime::Format::* subclass such as RFC2822.
  ## This overrides the language for a single call, rather than setting
  ## a default value.

```

## TODO

 * Add strptime().
 * More bundled formats.
 * More localizations, and tests for them.

## Authors

 * [Timothy Totten](https://github.com/supernovus/)
 * [Carl Mäsak](https://github.com/masak/)
 * [Kodi Arfer](https://github.com/Kodiologist/)

Anyone I'm missing that may have contributed, feel free to contact supernovus,
and I'll add you to the credits.

## License

[Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0)

