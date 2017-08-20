unit class GLFW::VidMode is repr('CStruct');

has int32 $.width;
has int32 $.height;

has int32 $.red-bits;
has int32 $.green-bits;
has int32 $.blue-bits;

has int32 $.refresh-rate;
