use v6.c;
use NativeCall;

unit module Graphics::TinyTIFF:ver<0.0.6>:auth<github:ryn1x>;

#| open tiff file for reading, returns tiff pointer
sub TinyTIFFReader_open( str $filename )
    returns Pointer is native('tinytiff') is export { * }

#| read data from current frame into supplied buffer
sub TinyTIFFReader_getSampleData( Pointer $tiff, CArray $sample-data is rw, uint16 $sample )
    returns int32 is native('tinytiff') is export { * }

#| close the tiff file
sub TinyTIFFReader_close( Pointer $tiff )
    is native('tinytiff') is export { * }

#| return bits per sample of current frame
sub TinyTIFFReader_getBitsPerSample( Pointer $tiff, int32 $sample )
    returns uint16 is native('tinytiff') is export { * }

#| return width of current frame
sub TinyTIFFReader_getWidth( Pointer $tiff )
    returns uint32 is native('tinytiff') is export { * }

#| return height of current frame
sub TinyTIFFReader_getHeight( Pointer $tiff )
    returns uint32 is native('tinytiff') is export { * }

#| return number of frames
sub TinyTIFFReader_countFrames( Pointer $tiff )
    returns uint32 is native('tinytiff') is export { * }

#| return sample format of current frame
sub TinyTIFFReader_getSampleFormat( Pointer $tiff )
    returns uint16 is native('tinytiff') is export { * }

#| return samples per pixel of current frame
sub TinyTIFFReader_getSamplesPerPixel( Pointer $tiff )
    returns uint16 is native('tinytiff') is export { * }

#| return image descrition of current frame
sub TinyTIFFReader_getImageDescription( Pointer $tiff )
    returns str is native('tinytiff') is export { * }

#| retun non-zero if another frame exists
sub TinyTIFFReader_hasNext( Pointer $tiff )
    returns int32 is native('tinytiff') is export { * }

#| read the next frame from a multi-frame tiff
sub TinyTIFFReader_readNext( Pointer $tiff )
    returns int32 is native('tinytiff') is export { * }

#| return non-zero if no error in last function call
sub TinyTIFFReader_success( Pointer $tiff )
    returns int32 is native('tinytiff') is export { * }

#| return non-zero if error in last function call
sub TinyTIFFReader_wasError( Pointer $tiff )
    returns int32 is native('tinytiff') is export { * }

#| return last error message
sub TinyTIFFReader_getLastError( Pointer $tiff )
    returns str is native('tinytiff') is export { * }

#| create a new tiff file, returns tiff-file pointer
sub TinyTIFFWriter_open( str $filename, uint16 $bits-per-sample, uint32 $width, uint32 $height )
    returns Pointer is native('tinytiff') is export { * }

#| get max size for image descrition
sub TinyTIFFWriter_getMaxDescriptionTextSize()
    returns int32 is native('tinytiff') is export { * }

#| writes row-major image data to a tiff file
sub TinyTIFFWriter_writeImageDouble( Pointer $tiff-file, CArray $sample-data is rw )
    is native('tinytiff') is export { * }

#| writes row-major image data to a tiff file
sub TinyTIFFWriter_writeImageFloat( Pointer $tiff-file, CArray $sample-data is rw )
    is native('tinytiff') is export { * }

#| writes row-major image data to a tiff file
sub TinyTIFFWriter_writeImageVoid( Pointer $tiff-file, CArray $sample-data is rw )
    is native('tinytiff') is export { * }

#| close the tiff and write image description to first frame
sub TinyTIFFWriter_close( Pointer $tiff-file, str $image-description )
    is native('tinytiff') is export { * }
