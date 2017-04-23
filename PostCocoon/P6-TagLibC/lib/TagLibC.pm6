use v6;
use NativeCall;
use LibraryCheck;

unit module TagLibC;

my $_lib;

sub library is export {
  return $_lib if $_lib;
  return $_lib = library_search;
}

sub library_search is export {

  # Environment variable overrides auto-detection
  return %*ENV<PERL6_TAGLIB_C_LIB> if %*ENV<PERL6_TAGLIB_C_LIB>;

  # On MacOS X using homebrew
  return "libtag_c.dylib" if $*KERNEL.name eq 'darwin';

  # Linux/UNIX
  constant LIB = 'tag_c';
  if library-exists(LIB, v0) {
      return sprintf("lib%s.so.0", LIB);
  } elsif library-exists(LIB, v1) {
      return sprintf("lib%s.so.1", LIB);
  }

  # Fallback
  return sprintf("lib%s.so", LIB);
}

## Enumerations

# == /usr/include/taglib/tag_c.h ==

enum TagLib_ID3v2_Encoding is export (
   TagLib_ID3v2_Latin1 => 0,
   TagLib_ID3v2_UTF16 => 1,
   TagLib_ID3v2_UTF16BE => 2,
   TagLib_ID3v2_UTF8 => 3
);
enum TagLib_File_Type is export (
   TagLib_File_MPEG => 0,
   TagLib_File_OggVorbis => 1,
   TagLib_File_FLAC => 2,
   TagLib_File_MPC => 3,
   TagLib_File_OggFlac => 4,
   TagLib_File_WavPack => 5,
   TagLib_File_Speex => 6,
   TagLib_File_TrueAudio => 7,
   TagLib_File_MP4 => 8,
   TagLib_File_ASF => 9
);
## Structures


# == /usr/include/taglib/tag_c.h ==

class AudioProperties is repr('CStruct') is export {
	has int32                         $.dummy; # int dummy
}

class Tag is repr('CStruct') is export {
	has int32                         $.dummy; # int dummy
}

class File is repr('CStruct') is export {
	has int32                         $.dummy; # int dummy
}

# == <builtin> ==

class __va_list_tag is repr('CStruct') is export {
	has uint32                        $.gp_offset; # unsigned int gp_offset
	has uint32                        $.fp_offset; # unsigned int fp_offset
	has Pointer                       $.overflow_arg_area; # void* overflow_arg_area
	has Pointer                       $.reg_save_area; # void* reg_save_area
}
class __NSConstantString_tag is repr('CStruct') is export {
	has Pointer[int32]                $.isa; # const int* isa
	has int32                         $.flags; # int flags
	has Str                           $.str; # const char* str
	has long                          $.length; # long int length
}
## Extras stuff

constant __NSConstantString is export := __NSConstantString_tag;
constant TagLib_AudioProperties is export := AudioProperties;
constant TagLib_Tag is export := File;
constant TagLib_File is export := Tag;
## Functions


# == /usr/include/taglib/tag_c.h ==

#-From /usr/include/taglib/tag_c.h:74
#/*!
# * By default all strings coming into or out of TagLib's C API are in UTF8.
# * However, it may be desirable for TagLib to operate on Latin1 (ISO-8859-1)
# * strings in which case this should be set to FALSE.
# */
#TAGLIB_C_EXPORT void taglib_set_strings_unicode(BOOL unicode);
sub taglib_set_strings_unicode(int32 $unicode # int
                               ) is native(&library)  is export { * }

#-From /usr/include/taglib/tag_c.h:82
#/*!
# * TagLib can keep track of strings that are created when outputting tag values
# * and clear them using taglib_tag_clear_strings().  This is enabled by default.
# * However if you wish to do more fine grained management of strings, you can do
# * so by setting \a management to FALSE.
# */
#TAGLIB_C_EXPORT void taglib_set_string_management_enabled(BOOL management);
sub taglib_set_string_management_enabled(int32 $management # int
                                         ) is native(&library)  is export { * }

#-From /usr/include/taglib/tag_c.h:87
#/*!
# * Explicitly free a string returned from TagLib
# */
#TAGLIB_C_EXPORT void taglib_free(void* pointer);
sub taglib_free(Pointer $pointer # void*
                ) is native(&library)  is export { * }

#-From /usr/include/taglib/tag_c.h:113
#/*!
# * Creates a TagLib file based on \a filename.  TagLib will try to guess the file
# * type.
# *
# * \returns NULL if the file type cannot be determined or the file cannot
# * be opened.
# */
#TAGLIB_C_EXPORT TagLib_File *taglib_file_new(const char *filename);
sub taglib_file_new(Str $filename # const char*
                    ) is native(&library) returns File is export { * }

#-From /usr/include/taglib/tag_c.h:119
#/*!
# * Creates a TagLib file based on \a filename.  Rather than attempting to guess
# * the type, it will use the one specified by \a type.
# */
#TAGLIB_C_EXPORT TagLib_File *taglib_file_new_type(const char *filename, TagLib_File_Type type);
sub taglib_file_new_type(Str                           $filename # const char*
                        ,int32                         $type # Typedef<TagLib_File_Type>->|TagLib_File_Type|
                         ) is native(&library) returns File is export { * }

#-From /usr/include/taglib/tag_c.h:124
#/*!
# * Frees and closes the file.
# */
#TAGLIB_C_EXPORT void taglib_file_free(TagLib_File *file);
sub taglib_file_free( File $file # Typedef<TagLib_File>->||*
                     ) is native(&library)  is export { * }

#-From /usr/include/taglib/tag_c.h:131
#TAGLIB_C_EXPORT BOOL taglib_file_is_valid(const TagLib_File *file);
sub taglib_file_is_valid( File $file # const Typedef<TagLib_File>->||*
                         ) is native(&library) returns int32 is export { * }

#-From /usr/include/taglib/tag_c.h:137
#/*!
# * Returns a pointer to the tag associated with this file.  This will be freed
# * automatically when the file is freed.
# */
#TAGLIB_C_EXPORT TagLib_Tag *taglib_file_tag(const TagLib_File *file);
sub taglib_file_tag( File $file # const Typedef<TagLib_File>->||*
                    ) is native(&library) returns Tag is export { * }

#-From /usr/include/taglib/tag_c.h:143
#/*!
# * Returns a pointer to the audio properties associated with this file.  This
# * will be freed automatically when the file is freed.
# */
#TAGLIB_C_EXPORT const TagLib_AudioProperties *taglib_file_audioproperties(const TagLib_File *file);
sub taglib_file_audioproperties( File $file # const Typedef<TagLib_File>->||*
                                ) is native(&library) returns AudioProperties is export { * }

#-From /usr/include/taglib/tag_c.h:148
#/*!
# * Saves the \a file to disk.
# */
#TAGLIB_C_EXPORT BOOL taglib_file_save(TagLib_File *file);
sub taglib_file_save( File $file # Typedef<TagLib_File>->||*
                     ) is native(&library) returns int32 is export { * }

#-From /usr/include/taglib/tag_c.h:160
#/*!
# * Returns a string with this tag's title.
# *
# * \note By default this string should be UTF8 encoded and its memory should be
# * freed using taglib_tag_free_strings().
# */
#TAGLIB_C_EXPORT char *taglib_tag_title(const TagLib_Tag *tag);
sub taglib_tag_title( Tag $tag # const Typedef<TagLib_Tag>->||*
                     ) is native(&library) returns Str is export { * }

#-From /usr/include/taglib/tag_c.h:168
#/*!
# * Returns a string with this tag's artist.
# *
# * \note By default this string should be UTF8 encoded and its memory should be
# * freed using taglib_tag_free_strings().
# */
#TAGLIB_C_EXPORT char *taglib_tag_artist(const TagLib_Tag *tag);
sub taglib_tag_artist( Tag $tag # const Typedef<TagLib_Tag>->||*
                      ) is native(&library) returns Str is export { * }

#-From /usr/include/taglib/tag_c.h:176
#/*!
# * Returns a string with this tag's album name.
# *
# * \note By default this string should be UTF8 encoded and its memory should be
# * freed using taglib_tag_free_strings().
# */
#TAGLIB_C_EXPORT char *taglib_tag_album(const TagLib_Tag *tag);
sub taglib_tag_album( Tag $tag # const Typedef<TagLib_Tag>->||*
                     ) is native(&library) returns Str is export { * }

#-From /usr/include/taglib/tag_c.h:184
#/*!
# * Returns a string with this tag's comment.
# *
# * \note By default this string should be UTF8 encoded and its memory should be
# * freed using taglib_tag_free_strings().
# */
#TAGLIB_C_EXPORT char *taglib_tag_comment(const TagLib_Tag *tag);
sub taglib_tag_comment( Tag $tag # const Typedef<TagLib_Tag>->||*
                       ) is native(&library) returns Str is export { * }

#-From /usr/include/taglib/tag_c.h:192
#/*!
# * Returns a string with this tag's genre.
# *
# * \note By default this string should be UTF8 encoded and its memory should be
# * freed using taglib_tag_free_strings().
# */
#TAGLIB_C_EXPORT char *taglib_tag_genre(const TagLib_Tag *tag);
sub taglib_tag_genre( Tag $tag # const Typedef<TagLib_Tag>->||*
                     ) is native(&library) returns Str is export { * }

#-From /usr/include/taglib/tag_c.h:197
#/*!
# * Returns the tag's year or 0 if year is not set.
# */
#TAGLIB_C_EXPORT unsigned int taglib_tag_year(const TagLib_Tag *tag);
sub taglib_tag_year( Tag $tag # const Typedef<TagLib_Tag>->||*
                    ) is native(&library) returns uint32 is export { * }

#-From /usr/include/taglib/tag_c.h:202
#/*!
# * Returns the tag's track number or 0 if track number is not set.
# */
#TAGLIB_C_EXPORT unsigned int taglib_tag_track(const TagLib_Tag *tag);
sub taglib_tag_track( Tag $tag # const Typedef<TagLib_Tag>->||*
                     ) is native(&library) returns uint32 is export { * }

#-From /usr/include/taglib/tag_c.h:209
#/*!
# * Sets the tag's title.
# *
# * \note By default this string should be UTF8 encoded.
# */
#TAGLIB_C_EXPORT void taglib_tag_set_title(TagLib_Tag *tag, const char *title);
sub taglib_tag_set_title(                              Tag $tag # Typedef<TagLib_Tag>->||*
                        ,Str                           $title # const char*
                         ) is native(&library)  is export { * }

#-From /usr/include/taglib/tag_c.h:216
#/*!
# * Sets the tag's artist.
# *
# * \note By default this string should be UTF8 encoded.
# */
#TAGLIB_C_EXPORT void taglib_tag_set_artist(TagLib_Tag *tag, const char *artist);
sub taglib_tag_set_artist(                              Tag $tag # Typedef<TagLib_Tag>->||*
                         ,Str                           $artist # const char*
                          ) is native(&library)  is export { * }

#-From /usr/include/taglib/tag_c.h:223
#/*!
# * Sets the tag's album.
# *
# * \note By default this string should be UTF8 encoded.
# */
#TAGLIB_C_EXPORT void taglib_tag_set_album(TagLib_Tag *tag, const char *album);
sub taglib_tag_set_album(                              Tag $tag # Typedef<TagLib_Tag>->||*
                        ,Str                           $album # const char*
                         ) is native(&library)  is export { * }

#-From /usr/include/taglib/tag_c.h:230
#/*!
# * Sets the tag's comment.
# *
# * \note By default this string should be UTF8 encoded.
# */
#TAGLIB_C_EXPORT void taglib_tag_set_comment(TagLib_Tag *tag, const char *comment);
sub taglib_tag_set_comment(                              Tag $tag # Typedef<TagLib_Tag>->||*
                          ,Str                           $comment # const char*
                           ) is native(&library)  is export { * }

#-From /usr/include/taglib/tag_c.h:237
#/*!
# * Sets the tag's genre.
# *
# * \note By default this string should be UTF8 encoded.
# */
#TAGLIB_C_EXPORT void taglib_tag_set_genre(TagLib_Tag *tag, const char *genre);
sub taglib_tag_set_genre(                              Tag $tag # Typedef<TagLib_Tag>->||*
                        ,Str                           $genre # const char*
                         ) is native(&library)  is export { * }

#-From /usr/include/taglib/tag_c.h:242
#/*!
# * Sets the tag's year.  0 indicates that this field should be cleared.
# */
#TAGLIB_C_EXPORT void taglib_tag_set_year(TagLib_Tag *tag, unsigned int year);
sub taglib_tag_set_year(                              Tag $tag # Typedef<TagLib_Tag>->||*
                       ,uint32                        $year # unsigned int
                        ) is native(&library)  is export { * }

#-From /usr/include/taglib/tag_c.h:247
#/*!
# * Sets the tag's track number.  0 indicates that this field should be cleared.
# */
#TAGLIB_C_EXPORT void taglib_tag_set_track(TagLib_Tag *tag, unsigned int track);
sub taglib_tag_set_track(                              Tag $tag # Typedef<TagLib_Tag>->||*
                        ,uint32                        $track # unsigned int
                         ) is native(&library)  is export { * }

#-From /usr/include/taglib/tag_c.h:252
#/*!
# * Frees all of the strings that have been created by the tag.
# */
#TAGLIB_C_EXPORT void taglib_tag_free_strings(void);
sub taglib_tag_free_strings(
                            ) is native(&library)  is export { * }

#-From /usr/include/taglib/tag_c.h:261
#/*!
# * Returns the length of the file in seconds.
# */
#TAGLIB_C_EXPORT int taglib_audioproperties_length(const TagLib_AudioProperties *audioProperties);
sub taglib_audioproperties_length( AudioProperties $audioProperties # const Typedef<TagLib_AudioProperties>->||*
                                  ) is native(&library) returns int32 is export { * }

#-From /usr/include/taglib/tag_c.h:266
#/*!
# * Returns the bitrate of the file in kb/s.
# */
#TAGLIB_C_EXPORT int taglib_audioproperties_bitrate(const TagLib_AudioProperties *audioProperties);
sub taglib_audioproperties_bitrate( AudioProperties $audioProperties # const Typedef<TagLib_AudioProperties>->||*
                                   ) is native(&library) returns int32 is export { * }

#-From /usr/include/taglib/tag_c.h:271
#/*!
# * Returns the sample rate of the file in Hz.
# */
#TAGLIB_C_EXPORT int taglib_audioproperties_samplerate(const TagLib_AudioProperties *audioProperties);
sub taglib_audioproperties_samplerate( AudioProperties $audioProperties # const Typedef<TagLib_AudioProperties>->||*
                                      ) is native(&library) returns int32 is export { * }

#-From /usr/include/taglib/tag_c.h:276
#/*!
# * Returns the number of channels in the audio stream.
# */
#TAGLIB_C_EXPORT int taglib_audioproperties_channels(const TagLib_AudioProperties *audioProperties);
sub taglib_audioproperties_channels( AudioProperties $audioProperties # const Typedef<TagLib_AudioProperties>->||*
                                    ) is native(&library) returns int32 is export { * }

#-From /usr/include/taglib/tag_c.h:293
#TAGLIB_C_EXPORT void taglib_id3v2_set_default_text_encoding(TagLib_ID3v2_Encoding encoding);
sub taglib_id3v2_set_default_text_encoding(int32 $encoding # Typedef<TagLib_ID3v2_Encoding>->|TagLib_ID3v2_Encoding|
                                           ) is native(&library)  is export { * }
