use Image::RGBA::Text;
use Image::PNG::Inflated;

spurt "{ .info }.png", to-png |.scale.unbox
    for RGBAText.decode('examples/FEEP.txt'.IO, :all);
