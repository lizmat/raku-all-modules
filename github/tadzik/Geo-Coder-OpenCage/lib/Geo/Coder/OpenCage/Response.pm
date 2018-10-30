unit class Geo::Coder::OpenCage::Response;

my class Status {
    has Int $.code;
    has Str $.message;

    method ok { return $!code == 200 }
}

my class Result {
    my class LatLng {
        has Num $.lat;
        has Num $.lng;
    }

    my class Bounds {
        has LatLng $.southwest;
        has LatLng $.northeast;
    }

    my class Annotations {
        my class Sun {
            my class Times {
                has Int $.nautical;
                has Int $.astronomical;
                has Int $.civil;
                has Int $.apparent;
            }
            has Times $.rise;
            has Times $.set;
        }

        my class Timezone {
            has Str  $.name;
            has Str  $.short_name;
            has Int  $.offset_sec;
            has Int  $.offset_string;
            has Bool $.now_in_dst;
        }
        
        my class Mercator {
            has Num $.x;
            has Num $.y;
        }

        my class What3Words {
            has Str $.words;
        }

        my class OSM {
            has Str $.edit_url;
            has Str $.url;
        }

        my class DMS {
            has Str $.lat;
            has Str $.lng;
        }

        has Str        $.MGRS;
        has Str        $.Maidenhead;
        has Int        $.callingcode;
        has Sun        $.sun;
        has Timezone   $.timezone;
        has Mercator   $.mercator;
        has Str        $.geohash;
        has What3Words $.what3words;
        has OSM        $.osm;
        has DMS        $.dms;
    }

    has Str         $.formatted;
    has Int         $.confidence;
    has LatLng      $.geometry;
    has Bounds      $.bounds;
    has             %.components;
    has Annotations $.annotations
}

has Status $.status;
has Result @.results;
