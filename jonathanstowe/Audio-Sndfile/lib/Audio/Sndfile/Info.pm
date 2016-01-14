use v6;
use NativeCall;

=begin pod

=head1 NAME

Audio::Sndfile::Info - describe an opened audio file

=head1 SYNOPSIS

=begin code

    my $info = Audio::Sndfile::Info.new(channels => 2, samplerate => 44100, format => 0x00010002);
    say $info.type;

=end code

=head1 DESCRIPTION

The objects of type L<Audio::Sndfile::Info> can be passed to the constructor of
L<Audio::Sndfile> when opening the file for writing and can be obtained from the C<info>
accessor of an L<Audio::Sndfile> that was opened for reading.  It is a representation of
the C<SF_INFO> struct used by C<libsndfile> to pass this information around.

It is unlikely that changing the values of any of the attributes in the object will make
sense after the object has been constructed.

=head2 METHODS

Where indicated some of these attributes can be passed as named arguments to 
L<Audio::Sndfile> constructor when opening for writing.

=head3 frames

This returns an Int indicating the number of the frames in a file, this only makes sense
when the file is opened for reading, it is ignored when the file is opened for writing
and it is not updated while new data is written to the file. The number of frames is
the number of sample items / channels.

=head3 channels

The number of channels in the data of this file. This is required when opening a file
for writing.

=head3 format

An Int that describes the format of the file.  This is the bitwise or of C<type>, C<sub-type>
and C<endian>.  It is required when opening a file for writing and providing a value that is
not legal will result in an exception.

=head3 samplerate

This is the sample rate of the frame data in frames / second.  This is required when opening
a file for writing.  It is important to note though that if data is being read from one file
and written to the other (i.e. copying or format converting) then setting this to any other
value than that of the incoming file will not cause an automatic sample rate conversion and will
simply have the effect of slowing down or speeding up the playback of the written data.  If you
want samplerate conversion you will either need to process the data yourself to add or remove
the required frames (inferring the values in the up-sampling case,) or use some other library
such as C<libsamplerate>.

=head3 sections

An Int that indicates the number of (format dependent) sections in the file.  This is not
required for opening a file for writing.

=head3 seekable

This is a Boolean to indicate whether the input or output file is seekable, it will be true
for most regular files and False for other special files, however as it is currently difficult
to open other than regular files this can be mostly ignored.

=head3 format-check

    method format-check() returns Bool

This returns a Bool to indicate whether the L<format|#format> in the current object makes
sense. Attempting to use a setting of L<format|#format> where this is not true will cause
an exception to be thrown.

=head3 type

    method type() returns Format

This is a value of the enum L<Audio::Sndfile::Info::Format> that indicates the major format
of the file (e.g. WAV, FLAC ..).  It is bitwise or-ed with C<sub-type> and C<endian> to
provide L<format|#format>.

=head3 sub-type

    method sub-type() returns Subformat

This is a value of the enum L<Audio::Sndfile::Info::Subformat> that indicate the minor format
or sample encoding of the data (e.g. PCM_16, FLOAT ... ). It is bitwise or-ed with C<type> and
C<endian> to provide L<format|#format>.


=head3 endian

    method endian() returns End

This is a value of the enum L<Audio::Sndfile::Info::End> which indicates the endian-ness of the
samples in the data.  It is bitwise or-ed with C<type> and C<sub-type> to make L<format|#format>.

=head3 duration

    method duration() returns Duration

=head2 enum Audio::Sndfile::Info::Format

This describes the major format of the file as described above in
L<type|#type>. The possible values are described below, it should be borne
in mind that only certain combinations of C<type> and C<sub-type> make
sense, this is detailed in L<http://www.mega-nerd.com/libsndfile/#Features>

=item WAV

 Microsoft WAV format (little endian default).

=item AIFF

 Apple/SGI AIFF format (big endian).

=item AU

 Sun/NeXT AU format (big endian).

=item RAW

 RAW PCM data.

=item PAF

 Ensoniq PARIS file format.

=item SVX

 Amiga IFF / SVX8 / SV16 format.

=item NIST

 Sphere NIST format.

=item VOC

 VOC files.

=item IRCAM

 Berkeley/IRCAM/CARL

=item W64

 Sonic Foundry's 64 bit RIFF/WAV

=item MAT4

 Matlab (tm) V4.2 / GNU Octave 2.0

=item MAT5

 Matlab (tm) V5.0 / GNU Octave 2.1

=item PVF

 Portable Voice Format

=item XI

 Fasttracker 2 Extended Instrument

=item HTK

 HMM Tool Kit format

=item SDS

 Midi Sample Dump Standard

=item AVR

 Audio Visual Research

=item WAVEX

 MS WAVE with WAVEFORMATEX

=item SD2

 Sound Designer 2

=item FLAC

 FLAC lossless file format

=item CAF

 Core Audio File format

=item WVE

 Psion WVE format

=item OGG

 Xiph OGG container

=item MPC2K

 Akai MPC 2000 sampler

=item RF64

 RF64 WAV file

=head2 enum Audio::Sndfile::Info::Subformat

These describe the minor format or sample encoding of the format.  As suggested above only
certain combnations of Format and Subformat actually make sense.

=item PCM_S8

 Signed 8 bit data

=item PCM_16

 Signed 16 bit data

=item PCM_24

 Signed 24 bit data

=item PCM_32

 Signed 32 bit data

=item PCM_U8

 Unsigned 8 bit data (WAV and RAW only)

=item FLOAT

 32 bit float data

=item DOUBLE

 64 bit float data

=item ULAW

 U-Law encoded.

=item ALAW

 A-Law encoded.

=item IMA_ADPCM

 IMA ADPCM.

=item MS_ADPCM

 Microsoft ADPCM.

=item GSM610

 GSM 6.10 encoding.

=item VOX_ADPCM

 OKI / Dialogix ADPCM

=item G721_32

 32kbs G721 ADPCM encoding.

=item G723_24

 24kbs G723 ADPCM encoding.

=item G723_40

 40kbs G723 ADPCM encoding.

=item DWVW_12

 12 bit Delta Width Variable Word encoding.

=item DWVW_16

 16 bit Delta Width Variable Word encoding.

=item DWVW_24

 24 bit Delta Width Variable Word encoding.

=item DWVW_N

 N bit Delta Width Variable Word encoding.

=item DPCM_8

 8 bit differential PCM (XI only)

=item DPCM_16

 16 bit differential PCM (XI only)

=item VORBIS

 Xiph Vorbis encoding.

=head2 Audio::Sndfile::Info::End

These describe the endian-ness of the file format. Typically a file opened for reading
will use C<File> if the format defines an endian-ness and this should also be used when
opening a file for writing unless there is some particular reason not to.

=item File

Default file endian-ness

=item Little

Force little endian-ness

=item Big

Force big endian-ness.

=item Cpu

Force CPU endian-ness.

=end pod

class Audio::Sndfile::Info:ver<v0.0.5>:auth<github:jonathanstowe> is repr('CStruct') {
    has int64     $.frames;
    has int32     $.samplerate;
    has int32     $.channels;
    has int32     $.format;
    has int32     $.sections;
    has int32     $._seekable;

    sub  sf_format_check(Audio::Sndfile::Info $info) returns int32 is native('sndfile',v1) { * }

    # Masks to get at the parts of format
    constant SUBMASK    = 0x0000FFFF;
    constant TYPEMASK   = 0x0FFF0000;
    constant ENDMASK    = 0x30000000;

    # the endian-ness of the data
    enum End( :File(0x00000000), :Little(0x10000000), :Big(0x20000000), :Cpu(0x30000000));

    # The basic format of the file
    enum Format(
        :WAV(0x010000),
        :AIFF(0x020000),
        :AU(0x030000),
        :RAW(0x040000),
        :PAF(0x050000),
        :SVX(0x060000),
        :NIST(0x070000),
        :VOC(0x080000),
        :IRCAM(0x0A0000),
        :W64(0x0B0000),
        :MAT4(0x0C0000),
        :MAT5(0x0D0000),
        :PVF(0x0E0000),
        :XI(0x0F0000),
        :HTK(0x100000),
        :SDS(0x110000),
        :AVR(0x120000),
        :WAVEX(0x130000),
        :SD2(0x160000),
        :FLAC(0x170000),
        :CAF(0x180000),
        :WVE(0x190000),
        :OGG(0x200000),
        :MPC2K(0x210000),
        :RF64(0x220000)
    );

    # the subformat or encoding of the data
    enum Subformat(
        :PCM_S8(0x0001),
        :PCM_16(0x0002),
        :PCM_24(0x0003),
        :PCM_32(0x0004),
        :PCM_U8(0x0005),
        :FLOAT(0x0006),
        :DOUBLE(0x0007),
        :ULAW(0x0010),
        :ALAW(0x0011),
        :IMA_ADPCM(0x0012),
        :MS_ADPCM(0x0013),
        :GSM610(0x0020),
        :VOX_ADPCM(0x0021),
        :G721_32(0x0030),
        :G723_24(0x0031),
        :G723_40(0x0032),
        :DWVW_12(0x0040),
        :DWVW_16(0x0041),
        :DWVW_24(0x0042),
        :DWVW_N(0x0043),
        :DPCM_8(0x0050),
        :DPCM_16(0x0051),
        :VORBIS(0x0060)
    );
    method format-check() returns Bool {
        sf_format_check(self) == 1 ?? True !! False;
    }

    method seekable() returns Bool {
        $!_seekable == 1 ?? True !! False;
    }

    method type() returns Format {
        Format($!format +& TYPEMASK);
    }

    method sub-type() returns Subformat {
        Subformat($!format +& SUBMASK);
    }

    method endian() returns End {
        End($!format +& ENDMASK);
    }

    method duration() returns Duration {
        Duration.new($!frames/$!samplerate);
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
