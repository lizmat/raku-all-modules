use v6;

use Test;  # so we can define is-approx-vector

class Math::Vector
{
    has @.coordinates;
    
    multi method new (*@x) 
    {
        self.bless(coordinates => @x);
    }
    
    multi method new (@x) 
    {
        self.bless(coordinates => @x);
    }
    
    multi method Str() 
    {
        "(" ~ @.coordinates.join(', ') ~ ")";
    }
    
    multi method perl()
    {
        "Math::Vector.new(" ~ @.coordinates.map({.perl}).join(', ') ~ ")";        
    }
    
    multi method Num()
    {
        die "Cannot call Num on Vector!";
    }
    
    method Dim()
    {
        @.coordinates.elems;
    }

    multi sub infix:<⋅>(Math::Vector $a, Math::Vector $b where { $a.Dim == $b.Dim }) is export # is tighter(&infix:<+>) (NYI)
    {
        [+]($a.coordinates »*« $b.coordinates);
    }

    multi sub infix:<dot>(Math::Vector $a, Math::Vector $b) is export
    {
        $a ⋅ $b;
    }

    method Length()
    {
        sqrt(self ⋅ self.conj);
    }
    
    multi method abs()
    {
        self.Length;
    }

    multi method conj()
    {
        Math::Vector.new(@.coordinates>>.conj);
    }
        
    method Unitize()
    {
        my $length = self.Length;
        if $length > 1e-10
        {
            return Math::Vector.new(@.coordinates >>/>> $length);
        }
        else
        {
            return Math::Vector.new(@.coordinates);
        }
    }
    
    multi sub infix:<+> (Math::Vector $a, Math::Vector $b where { $a.Dim == $b.Dim }) is export
    {
        Math::Vector.new($a.coordinates »+« $b.coordinates);
    }
    
    multi sub infix:<->(Math::Vector $a, Math::Vector $b where { $a.Dim == $b.Dim }) is export
    {
        Math::Vector.new($a.coordinates »-« $b.coordinates);
    }

    multi sub prefix:<->(Math::Vector $a) is export
    {
        Math::Vector.new(0 <<-<< $a.coordinates);
    }

    multi sub infix:<*>(Math::Vector $a, $b) is export
    {
        Math::Vector.new($a.coordinates >>*>> $b);
    }

    multi sub infix:<*>($a, Math::Vector $b) is export
    {
        Math::Vector.new($a <<*<< $b.coordinates);
    }

    multi sub infix:</>(Math::Vector $a, $b) is export
    {
        Math::Vector.new($a.coordinates >>/>> $b);
    }

    multi sub infix:<×>(Math::Vector $a where { $a.Dim == 3 }, Math::Vector $b where { $b.Dim == 3 }) is export
    {
        Math::Vector.new($a.coordinates[1] * $b.coordinates[2] - $a.coordinates[2] * $b.coordinates[1], 
                   $a.coordinates[2] * $b.coordinates[0] - $a.coordinates[0] * $b.coordinates[2], 
                   $a.coordinates[0] * $b.coordinates[1] - $a.coordinates[1] * $b.coordinates[0]);
    }

    multi sub infix:<×>(Math::Vector $a where { $a.Dim == 7 }, Math::Vector $b where { $b.Dim == 7 }) is export
    {
        Math::Vector.new($a.coordinates[1] * $b.coordinates[3] - $a.coordinates[3] * $b.coordinates[1] 
                   + $a.coordinates[2] * $b.coordinates[6] - $a.coordinates[6] * $b.coordinates[2] 
                   + $a.coordinates[4] * $b.coordinates[5] - $a.coordinates[5] * $b.coordinates[4],
                   $a.coordinates[2] * $b.coordinates[4] - $a.coordinates[4] * $b.coordinates[2] 
                   + $a.coordinates[3] * $b.coordinates[0] - $a.coordinates[0] * $b.coordinates[3] 
                   + $a.coordinates[5] * $b.coordinates[6] - $a.coordinates[6] * $b.coordinates[5],
                   $a.coordinates[3] * $b.coordinates[5] - $a.coordinates[5] * $b.coordinates[3] 
                   + $a.coordinates[4] * $b.coordinates[1] - $a.coordinates[1] * $b.coordinates[4] 
                   + $a.coordinates[6] * $b.coordinates[0] - $a.coordinates[0] * $b.coordinates[6],
                   $a.coordinates[4] * $b.coordinates[6] - $a.coordinates[6] * $b.coordinates[4] 
                   + $a.coordinates[5] * $b.coordinates[2] - $a.coordinates[2] * $b.coordinates[5] 
                   + $a.coordinates[0] * $b.coordinates[1] - $a.coordinates[1] * $b.coordinates[0],
                   $a.coordinates[5] * $b.coordinates[0] - $a.coordinates[0] * $b.coordinates[5] 
                   + $a.coordinates[6] * $b.coordinates[3] - $a.coordinates[3] * $b.coordinates[6] 
                   + $a.coordinates[1] * $b.coordinates[2] - $a.coordinates[2] * $b.coordinates[1],
                   $a.coordinates[6] * $b.coordinates[1] - $a.coordinates[1] * $b.coordinates[6] 
                   + $a.coordinates[0] * $b.coordinates[4] - $a.coordinates[4] * $b.coordinates[0] 
                   + $a.coordinates[2] * $b.coordinates[3] - $a.coordinates[3] * $b.coordinates[2],
                   $a.coordinates[0] * $b.coordinates[2] - $a.coordinates[2] * $b.coordinates[0] 
                   + $a.coordinates[1] * $b.coordinates[5] - $a.coordinates[5] * $b.coordinates[1] 
                   + $a.coordinates[3] * $b.coordinates[4] - $a.coordinates[4] * $b.coordinates[3]);
    }

    multi sub infix:<cross>(Math::Vector $a, Math::Vector $b) is export
    {
        $a × $b;
    }

    multi sub circumfix:<⎡ ⎤>(Math::Vector $a) is export
    {
        $a.Length;
    }

    sub is-approx-vector(Math::Vector $a, Math::Vector $b, $desc) is export
    {
        ok(($a - $b).Length < 0.00001, $desc);
    }
}

subset Math::UnitVector of Math::Vector where { (1 - 1e-10) < $^v.Length < (1 + 1e-10) };
