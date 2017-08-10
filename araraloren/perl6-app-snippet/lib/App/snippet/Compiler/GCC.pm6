
use App::snippet;

unit class App::snippet::Compiler::GCC does App::snippet::Compiler is export;
method name() {
    "gcc";
}

method supports() {
    return [
        App::snippet::Support.new(lang => Language::C, bin => 'gcc'),
        App::snippet::Support.new(lang => Language::CXX, bin => 'g++'),
    ];
}

