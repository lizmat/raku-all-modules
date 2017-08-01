
use App::snippet;

class App::snippet::Compiler::Clang does Compiler is export {
    method name() {
        "clang";
    }

    method supports() {
        return [
            Support.new(lang => Language::C, bin => 'clang'),
            Support.new(lang => Language::CXX, bin => 'clang++'),
        ];
    }
}
