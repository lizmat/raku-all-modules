unit module Math::Polygons:ver<0.0.1>:auth<Steve Roe (p6steve@furnival.net)>;

use Math::Polygons::Drawing;

#use Physics::Measure;
#use Physics::Measure::Lang;

#require Physics::Measure;
#require Physics::Measure::Lang;

try require Physics::Measure;       say $!;
try require Physics::Measure::Lang; say $!;


#|only doing Isosceles Triangles for now
class Triangle is Polygon is export {
    has Point $.apex is required;
    has       $.side is required;

    method points() {
        ($!apex.serial, |self.base-points.serial);
    }   

    method base-points() {
        my $y = $!apex.y + self.height;
        my \A = Point.new(:$y, x => $!apex.x - ( $!side / 2 ));
        my \C = Point.new(:$y, x => $!apex.x + ( $!side / 2 ));
        return( A, C );
    }   

    method height() { 
        sqrt($!side**2 - ($!side/2)**2)
    }   
    
    method base() { 
        $!side 
    }   

    method area( ) { 
        ( $.height * $.base ) / 2 
    }   
}

class Quadrilateral is Polygon is export {
    has Point @.points;

    multi method new( \A, \B, \C, \D ) {
        self.bless( points => ( A, B, C, D ) );
    }
    method A { @!points[0] };
    method B { @!points[1] };
    method C { @!points[2] };
    method D { @!points[3] };

    method area( ) { 
        warn "I am not smart enough to figure this out!"; 
    }   
}

class Rectangle is Quadrilateral is export {
    has Point $.origin;
    has       $.width;
    has       $.height;
    
    method area() { 
        $.height * $.width 
    }   

    #|serialize Points as Real to strip any Physics::Measure container
    method serialize( --> Pair) {
        rect => [ x => $!origin.x.Real, y => $!origin.y.Real, width => $!width.Real, height => $!height.Real, |self.styles ];
    }
}

class Square is Rectangle is export {
    has Point $.origin;
    has       $.side;

    method area() { 
        $.side ** 2 
    }   

    #|serialize Points as Real to strip any Physics::Measure container
    method serialize( --> Pair) {
        rect => [ x => $!origin.x.Real, y => $!origin.y.Real, width => $!side.Real, height => $!side.Real, |self.styles ];
    }
}
