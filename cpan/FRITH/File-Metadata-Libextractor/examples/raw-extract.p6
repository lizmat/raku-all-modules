#!/usr/bin/env perl6

use lib 'lib';
use NativeCall;
use File::Metadata::Libextractor::Raw;
use File::Metadata::Libextractor::Constants;

#| This program extracts the information about a file
sub MAIN($file! where { .IO.f // die "file '$file' not found" })
{
  my $plugins = EXTRACTOR_plugin_add_defaults(EXTRACTOR_OPTION_DEFAULT_POLICY);
  EXTRACTOR_extract(
    $plugins,
    $file,
    Pointer[void],
    0,
    # callback function that handles the metadata (begin)
    -> $, *@args {
      («'Plugin name' 'Plugin type' 'Plugin format' 'Mime type' 'Data type' 'Data length'»
       »~» ': '
       »~» @args)».say;
      0;
    },
    # callback function that handles the metadata (end)
    Pointer[void]);
  EXTRACTOR_plugin_remove_all($plugins);
}
