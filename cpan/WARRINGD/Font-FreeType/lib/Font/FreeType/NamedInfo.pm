use NativeCall;
use Font::FreeType::Native;

class Font::FreeType::NamedInfo {
    has FT_SfntName $.struct handles <platform-id encoding-id language-id name-id string-len>;

    method Str {
        my $len = $.string-len;
        my $buf = CArray[uint8].new;
        $buf[$len - 1] = 0
            if $len;
        Font::FreeType::Native::memcpy(nativecast(Pointer, $buf), $!struct.string, $len);
        # todo various encoding schemes
        buf8.new($buf).decode;
    }
}

=begin pod

=head1 NAME

Font::FreeType::NamedInfo - information from 'names table' in font file

=head1 SYNOPSIS

    use Font::FreeType;

    my Font::FreeType $freetype .= new;
    my $face = $freetype.face('Vera.ttf');
    my $infos = $face.named-infos;
    if $infos {
      say .Str for @$infos;
    }

=head1 DESCRIPTION

The TrueType and OpenType specifications allow the inclusion of a special
_names table_ in font files. This table contains textual (and internationalized)
information regarding the font, like family name, copyright, version, etc.

Possible values for _platform-id_, _encoding-id_, _language-id_, and
_name\_id_ are given in the file _ttnameid.h_ from FreeType distribution. For
details please refer to the TrueType or OpenType specification.

=head1 METHODS

=head3 platform-id
=head3 encoding-id
=head3 language-id
=head3 name-id
=head3 Str

The _name_ string. Note that its format differs depending on the (platform,
 encoding) pair. It can be a Pascal String, a UTF-16 one, etc.

=head1 AUTHORS

Geoff Richards <qef@laxan.com>

David Warring <david.warring@gmail.com> (Perl 6 Port)

=head1 COPYRIGHT

Copyright 2004, Geoff Richards.

Ported from Perl 5 to 6 by David Warring <david.warring@gmail.com>

=end pod
