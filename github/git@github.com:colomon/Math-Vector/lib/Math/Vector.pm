use v6;
no precompilation; # avoid https://github.com/rakudo/rakudo/issues/1219

use Test;  # so we can define is-approx-vector

class Math::Vector does Positional
{
    has @.coordinates handles <AT-POS>;
    
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
    
    method Dim() is DEPRECATED('dim') {
        self.dim;
    }

    method dim() {
        @.coordinates.elems;
    }

    multi sub infix:<⋅>(Math::Vector $a, Math::Vector $b where { $a.dim == $b.dim }) is export # is tighter(&infix:<+>) (NYI)
    {
        [+]($a.coordinates »*« $b.coordinates);
    }

    multi sub infix:<dot>(Math::Vector $a, Math::Vector $b) is export
    {
        $a ⋅ $b;
    }

    method Length() is DEPRECATED('length') {
        self.length;
    }

    method length() {
        sqrt(self ⋅ self.conj);
    }
    
    multi method abs()
    {
        self.length;
    }

    multi method conj()
    {
        Math::Vector.new(@.coordinates>>.conj);
    }
        
    method Unitize() is DEPRECATED('unitize') {
        self.unitize;
    }

    method unitize() {
        my $length = self.length;
        if $length > 1e-10
        {
            return Math::Vector.new(@.coordinates >>/>> $length);
        }
        else
        {
            return Math::Vector.new(@.coordinates);
        }
    }
    
    multi sub infix:<+> (Math::Vector $a, Math::Vector $b where { $a.dim == $b.dim }) is export
    {
        Math::Vector.new($a.coordinates »+« $b.coordinates);
    }
    
    multi sub infix:<->(Math::Vector $a, Math::Vector $b where { $a.dim == $b.dim }) is export
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

    multi sub infix:<×>(Math::Vector $a where { $a.dim == 3 }, Math::Vector $b where { $b.dim == 3 }) is export
    {
        Math::Vector.new($a[1] * $b[2] - $a[2] * $b[1], 
                         $a[2] * $b[0] - $a[0] * $b[2], 
                         $a[0] * $b[1] - $a[1] * $b[0]);
    }

    multi sub infix:<×>(Math::Vector $a where { $a.dim == 7 }, Math::Vector $b where { $b.dim == 7 }) is export
    {
        Math::Vector.new($a[1] * $b[3] - $a[3] * $b[1] 
                         + $a[2] * $b[6] - $a[6] * $b[2] 
                         + $a[4] * $b[5] - $a[5] * $b[4],
                         $a[2] * $b[4] - $a[4] * $b[2] 
                         + $a[3] * $b[0] - $a[0] * $b[3] 
                         + $a[5] * $b[6] - $a[6] * $b[5],
                         $a[3] * $b[5] - $a[5] * $b[3] 
                         + $a[4] * $b[1] - $a[1] * $b[4] 
                         + $a[6] * $b[0] - $a[0] * $b[6],
                         $a[4] * $b[6] - $a[6] * $b[4] 
                         + $a[5] * $b[2] - $a[2] * $b[5] 
                         + $a[0] * $b[1] - $a[1] * $b[0],
                         $a[5] * $b[0] - $a[0] * $b[5] 
                         + $a[6] * $b[3] - $a[3] * $b[6] 
                         + $a[1] * $b[2] - $a[2] * $b[1],
                         $a[6] * $b[1] - $a[1] * $b[6] 
                         + $a[0] * $b[4] - $a[4] * $b[0] 
                         + $a[2] * $b[3] - $a[3] * $b[2],
                         $a[0] * $b[2] - $a[2] * $b[0] 
                         + $a[1] * $b[5] - $a[5] * $b[1] 
                         + $a[3] * $b[4] - $a[4] * $b[3]);
    }

    multi sub infix:<cross>(Math::Vector $a, Math::Vector $b) is export
    {
        $a × $b;
    }

    multi sub circumfix:<⎡ ⎤>(Math::Vector $a) is export
    {
        $a.length;
    }

    sub is-approx-vector(Math::Vector $a, Math::Vector $b, $desc) is export
    {
        ok(($a - $b).length < 0.00001, $desc);
    }
}

subset Math::UnitVector of Math::Vector where { (1 - 1e-10) < $^v.length < (1 + 1e-10) };
