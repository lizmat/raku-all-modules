use v6;

use CSS::Specification::Build;
use Panda::Builder;
use Panda::Common;

class Build is Panda::Builder {

    method build($where) {

        indir $where, {
            for ('etc/css1-properties.txt' => <CSS1>,
                 'etc/css21-properties.txt' => <CSS21>,
                 'etc/css3x-font-properties.txt' => <CSS3 Fonts>,
                 'etc/css3x-font-@fontface-properties.txt' => <CSS3 Fonts AtFontFace>,
                 'etc/css3x-paged-media.txt' => <CSS3 PagedMedia>,
                ) {
                my ($input-spec, $class-isa) = .kv;

                for interface => 'Interface',
                    actions => 'Actions' ,
                    grammar => 'Grammar' {
                    my ($type, $subclass) = .kv;
                    my $name = (<CSS Module>, @$class-isa, <Spec>, $subclass).join('::');

                    my $class-dir = (<lib CSS Module>, @$class-isa, <Spec>).join('/');
                    mkdir $class-dir;

                    my $class-path = $class-dir ~ '/' ~ $subclass ~ '.pm';

                    say "Building $input-spec => $name";
                    {
                        my $*IN = open $input-spec, :r;
                        my $*OUT = open $class-path, :w;

                        CSS::Specification::Build::generate( $type, $name );
                    }
                }
            }
        }
    }
}

# Build.pm can also be run standalone 
sub MAIN(Str $working-directory = '.' ) {
    Build.new.build($working-directory);
}
