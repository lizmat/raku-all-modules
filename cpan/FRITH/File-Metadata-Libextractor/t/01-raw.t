#!/usr/bin/env perl6

use Test;
use NativeCall;
use lib 'lib';
use File::Metadata::Libextractor::Raw;
use File::Metadata::Libextractor::Constants;

is EXTRACTOR_metatype_to_string(EXTRACTOR_METATYPE_FILENAME), 'embedded filename', 'metatype to string';
is EXTRACTOR_metatype_to_description(EXTRACTOR_METATYPE_FILENAME),
   'filename that was embedded (not necessarily the current filename)', 'metatype to description';
ok EXTRACTOR_metatype_get_max() > 200, 'Maximum metatype';
subtest {
  my $plugins;
  lives-ok { $plugins = EXTRACTOR_plugin_add_defaults(EXTRACTOR_OPTION_DEFAULT_POLICY) }, 'add default plugin list';
  ok $plugins ~~ Pointer, 'plugin list is a pointer';
  my Str $plugin-name;
  my int32 $type;
  my int32 $format;
  my Str $data-mime-type;
  my Str $fdata;
  sub extract(Pointer[void] $arg, Str $pname, int32 $ptype, int32 $pformat, Str $pmimetype, Str $pdata, size_t $len)
  {
    $plugin-name = $pname;
    $type = $ptype;
    $format = $pformat;
    $data-mime-type = $pmimetype;
    $fdata = $pdata;
    0;
  }
  lives-ok { EXTRACTOR_extract($plugins, $*PROGRAM-NAME, Pointer[void], 0, &extract, Pointer[void]) }, 'can extract information';
  is $plugin-name, 'mime', 'plugin name';
  ok $type == EXTRACTOR_METATYPE_MIMETYPE, 'plugin type';
  ok $format == EXTRACTOR_METAFORMAT_UTF8, 'plugin format';
  is $data-mime-type, 'text/plain', 'mime type';
  like $fdata, /text/, 'data type';
  lives-ok { EXTRACTOR_plugin_remove_all($plugins) }, 'remove default plugin list';
}, 'extractor';

done-testing;
