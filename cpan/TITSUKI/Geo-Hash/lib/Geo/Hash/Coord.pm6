unit class Geo::Hash::Coord is repr('CStruct');

use NativeCall;

my constant $library = %?RESOURCES<libraries/geohash>.Str;

has num64 $.latitude;
has num64 $.longitude;
has num64 $.north;
has num64 $.east;
has num64 $.south;
has num64 $.west;

my sub free_coordinate(Geo::Hash::Coord) is native($library) { * }

submethod DESTROY {
    free_coordinate(self)
}
