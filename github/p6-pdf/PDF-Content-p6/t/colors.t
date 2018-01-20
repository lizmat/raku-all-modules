use v6;
use Test;
plan 9;
use Color;

use PDF::Content::Color :color, :ColorName;

is color(Blue), (:DeviceCMYK[1,1,0,0]), 'color name';
is color([1,1,0,0]), (:DeviceCMYK[1,1,0,0]), 'cmyk color list';
is color([255,255,0,0]), (:DeviceCMYK[1,1,0,0]), 'cmyk color list';
is color([.1,.2,.3]), (:DeviceRGB[.1,.2,.3]), 'rgb color list';
is color('#fa1'), (:DeviceRGB[1, 2/3, 17/255]), 'rgb 3 hex digits';
is color('#ffaa11'), (:DeviceRGB[1, 2/3, 17/255]), 'rgb 6 hex digits';
is color('%fa12'), (:DeviceCMYK[1, 2/3, 17/255, 34/255]), 'cmyk 3 hex digits';
is color('%ffaa1122'), (:DeviceCMYK[1, 2/3, 17/255, 34/255]), 'cmyk 6 hex digits';
is color(Color.new(0,0,255)), (:DeviceRGB[0, 0, 1]), 'color object';

