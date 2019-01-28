use v6.c;

unit class Test::Declare::Callable;

# this means "must not be an instance of something"
has $.class is required when !*.DEFINITE;
has Str $.method is required;
# not all objects require constructor args
has Capture $.construct;
has $.obj = self.construct ?? ($!class).new(|self.construct)
                           !! ($!class).new();
has $.args is rw;

method call() {
    # slip the args in, if there are any
    self.args ?? self.obj."$!method"(|self.args)
              !! self.obj."$!method"()
}
