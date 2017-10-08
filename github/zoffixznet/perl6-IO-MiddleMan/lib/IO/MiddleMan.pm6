unit class IO::MiddleMan:ver<1.001001> is IO::Handle;

subset ValidMode     of Str where any <hijack  capture  mute  normal>;
subset OutputMethods of Str where any <print  say  put>;

has            @.data;
has IO::Handle $.handle;
has ValidMode  $.mode is required is rw;

method new (*@, *%) {
    fail 'Cannot instantiate with .new. Please use one of .hijack, '
        ~ '.capture, .mute, or .normal methods.';
}

method hijack  (IO::Handle $handle is rw) {
    $handle = self.bless: :$handle :mode<hijack>;
}
method capture (IO::Handle $handle is rw) {
    $handle = self.bless: :$handle :mode<capture>;
}
method mute    (IO::Handle $handle is rw) {
    $handle = self.bless: :$handle :mode<mute>;
}
method normal  (IO::Handle $handle is rw) {
    $handle = self.bless: :$handle :mode<normal>;
}

method !process (OutputMethods $meth , *@what is copy) returns Bool {
    @what       = @what».gist if $meth eq 'say';
    @what[*-1] ~= $.nl-out    if $meth eq any <put say>;
    given $.mode {
        when 'normal'  { $.handle.print: |@what; }
        when 'mute'    { return True;            }
        when 'capture' | 'hijack' {
            $.handle.print: |@what unless $_ eq 'hijack';
            @.data.push: @what.join: '';
            return True;
        }
    }
}

method print    (*@what) returns Bool { self!process: 'print', |@what }
method print-nl          returns Bool { self!process: 'put',   ''     }
method put      (*@what) returns Bool { self!process: 'put',   |@what }
method say      (*@what) returns Bool { self!process: 'say',   |@what }
method Str               returns Str  { @.data.join: ''           }

