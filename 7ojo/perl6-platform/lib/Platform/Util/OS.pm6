use v6.c;

class Platform::Util::OS {

    has Str $.kernel;

    my Platform::Util::OS $instance;

    method new(*%named) {
        return $instance //= self.bless(|%named);
    }

    method detect {
        my Str $v = self.new.kernel ?? self.new.kernel !! $*KERNEL.name;
        given $v {
            when /:i ^ darwin / { return 'macos' }
            when /:i ^ linux / { return 'linux' }
            when /:i ^ win / { return 'windows' }
            default {
              return 'unknown'
            }
        }
    }

    submethod clear {
        $instance = Nil;
    }
}
