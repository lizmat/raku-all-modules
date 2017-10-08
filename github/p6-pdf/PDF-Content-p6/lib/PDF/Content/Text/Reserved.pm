class PDF::Content::Text::Reserved is rw {
    has $.source handles <Str> = '';   #| object being replaced
    has Numeric $.width is required;   #| intrinsic width
    has Numeric $.height is required;  #| intrinsic height
}
