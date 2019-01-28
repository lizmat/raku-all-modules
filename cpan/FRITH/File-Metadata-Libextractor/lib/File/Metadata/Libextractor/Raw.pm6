use v6.c;

unit module File::Metadata::Libextractor::Raw:ver<0.0.1>:auth<cpan:FRITH>;

use NativeCall;
use File::Metadata::Libextractor::Constants;

constant LIB = ('extractor', v3);

sub EXTRACTOR_metatype_to_string(int32 $type --> Str) is native(LIB) is export { * }
sub EXTRACTOR_metatype_to_description(int32 $type --> Str) is native(LIB) is export { * }
sub EXTRACTOR_metatype_get_max(--> int32) is native(LIB) is export { * }
sub EXTRACTOR_plugin_add_defaults(int32 $flags --> Pointer) is native(LIB) is export { * }
sub EXTRACTOR_plugin_add(Pointer $prev, Str $library, Str $options, int32 $flags --> Pointer)
    is native(LIB) is export { * }
sub EXTRACTOR_plugin_add_config(Pointer $prev, Str $config, int32 $flags --> Pointer) is native(LIB) is export { * }
sub EXTRACTOR_plugin_remove(Pointer $prev, Str $library --> Pointer) is native(LIB) is export { * }
sub EXTRACTOR_plugin_remove_all(Pointer $plugins) is native(LIB) is export { * }
sub EXTRACTOR_extract(Pointer $plugins, Str $filename, Pointer $data, size_t $size,
                      &proc (Pointer[void] $cls, Str $plugin-name, int32 $type, int32 $format,
                             Str $data-mime-type, Str $data1, size_t $data-len --> int32),
                      Pointer[void] $proc_cls) is native(LIB) is export { * }

=begin pod

=head1 NAME

File::Metadata::Libextractor::Raw - A simple interface to libextractor

=head1 SYNOPSIS
=begin code

use v6;

use File::Metadata::Libextractor::Raw;
use File::Metadata::Libextractor::Constants;
use NativeCall;

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

=end code

=head1 DESCRIPTION

For more details on libextractor see L<https://www.gnu.org/software/libextractor/manual/libextractor.html>.

=head1 Prerequisites

This module requires the libextractor library to be installed. Please follow the instructions below based on your platform:

=head2 Debian Linux

=begin code
sudo apt-get install libextractor3
=end code

The module looks for a library called libextractor.so.3 .

=head1 Installation

To install it using zef (a module management tool):

=begin code
$ zef install File::Metadata::Libextractor
=end code

=head1 Testing

To run the tests:

=begin code
$ prove -e "perl6 -Ilib"
=end code

=head1 Author

Fernando Santagata

=head1 License

The Artistic License 2.0

=end pod
