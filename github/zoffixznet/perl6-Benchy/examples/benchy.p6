use lib <lib>;
use Benchy;

augment class IO::Spec::Win32 {
    my $slash = regex {  <[\/ \\]> }

    method join2 ($volume, $dirname is copy, $file is copy) {
        $dirname = '' if $dirname eq '.' && $file.chars;
        if $dirname.match( /^<$slash>$/ ) && $file.match( /^<$slash>$/ ) {
            $file    = '';
            $dirname = '' if $volume.chars > 2; #i.e. UNC path
        }
        self.catpath($volume, $dirname, $file);
    }

    method join3 ($volume, $dirname is copy, $file is copy) {
        $dirname = '' if $dirname eq '.' && $file.chars;
        if $dirname.match( /^<$slash>$/ ) && $file.match( /^<$slash>$/ ) {
            $file    = '';
            $dirname = '' if $volume.chars > 2; #i.e. UNC path
        }
        self.catpath($volume, $dirname, $file);
    }
}

dd b 20, { sleep .1 }, { sleep .01 }, { sleep .001 }
