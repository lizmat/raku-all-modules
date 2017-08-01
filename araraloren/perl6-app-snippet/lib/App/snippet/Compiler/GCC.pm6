
use App::snippet;

class App::snippet::Compiler::GCC does Compiler is export {
    method name() {
        "gcc";
    }

    method supports() {
        return [
            Support.new(lang => Language::C, bin => 'gcc'),
            Support.new(lang => Language::CXX, bin => 'g++'),
        ];
    }
}
