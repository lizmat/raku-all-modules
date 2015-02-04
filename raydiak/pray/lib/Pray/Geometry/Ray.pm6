class Pray::Geometry::Ray;

use Pray::Geometry::Vector3D;

has Pray::Geometry::Vector3D $.position;
has Pray::Geometry::Vector3D $.direction;

method normalize () {
    $?CLASS.bless(
        :$!position,
        direction => $!direction.normalize
    )
}

#`[[[
method scale ($argument, :$center) {
    $?CLASS.bless(
        :position($center ??
            $!position.scale($argument, :$center)
        !!
            $!position.scale($argument)
        ),
        :direction($!direction.scale($argument))
    )
}

method rotate (*@arguments, :$center) {
    $?CLASS.bless(
        :position($center ??
            $!position.rotate(|@arguments, :$center) !!
            $!position.rotate(|@arguments)
        ),
        :direction($!direction.rotate(|@arguments))
    )
}
]]]

