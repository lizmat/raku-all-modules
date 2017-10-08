unit class GLFW::GammaRamp is repr('CStruct');

use NativeCall;

has CArray[uint8] $.red;
has CArray[uint8] $.green;
has CArray[uint8] $.blue;
has uint32 $.size;
