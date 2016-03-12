use v6.c;

=begin pod

=head1 NAME

Audio::Hydrogen::Drumkit - representation of a drumkit

=head1 DESCRIPTION

This provides an abstraction of the data found in a 
C<drumkit.xml> file that describes a hydrogen drumkit.

You can load the XML file with the C<from-xml> method
provided by L<XML::Class> and export with C<to-xml>.

=head1 METHODS

=head2 attribute name

This is the string name of the drumkit, it is typically the
same as the directory name where the C<drumkit.xml> was
found.

=head2 attribute author

This is an arbitrary string describing the author, it is not
required.

=head2 attribute info

A free text description of the drumkit.  It is not required.

=head2 attribute instruments

This is a list of L<Audio::Hydrogen::Instrument> objects,
hydrogen supports 32 instruments and any more than this
may not be shown in the interface.  If the C<drumkit.xml>
was created by Hydrogen then it may have exactly 32 
items in the list, any un-used ones won't have a name.

If you are adding to the list or creating a new drumkit
you should ensure that the C<id> field of the instrument
is set to a unique value (an integer,) as this is how the
instrument is referred to in patterns and in the interface.

=head2 method make-absolute

Typically the filenames referred to in a drumkit file are
relative to the directory of the drumkit, but when the
instruments are used in a song they should be absolute
paths so the instruments can be found wherever the
song file is.  This method takes an IO::Path that should
typically represent the directory of the drumkit and
will adjust the filenames of the instruments so they
are children of this directory.  This is always done
when the drumkit is obtained from a L<DrumkitInfo>.

=end pod

use XML::Class;

use Audio::Hydrogen::Instrument;

class Audio::Hydrogen::Drumkit does XML::Class[xml-element => 'drumkit_info'] {
   has Str                         $.name        is xml-element is rw;
   has Str                         $.author      is xml-element is rw;
   has Str                         $.info        is xml-element is rw;
   has Audio::Hydrogen::Instrument @.instruments is xml-container('instrumentList');

   method make-absolute(IO::Path $path) {
       for @!instruments -> $instrument {
           $instrument.make-absolute($path);
       }
   }
}


# vim: expandtab shiftwidth=4 ft=perl6
