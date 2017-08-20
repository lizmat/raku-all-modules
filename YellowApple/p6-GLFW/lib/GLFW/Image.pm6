unit class GLFW::Image is repr('CStruct');

use NativeCall;

has int32 $.width;
has int32 $.height;
has CArray[uint8] $.pixels;
