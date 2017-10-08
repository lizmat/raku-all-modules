use IoC::Service;

class IoC::Literal does IoC::Service {
    has $.value;

    method get { return self.value }
};
