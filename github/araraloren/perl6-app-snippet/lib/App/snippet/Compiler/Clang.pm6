
use App::snippet;

unit class App::snippet::Compiler::Clang does App::snippet::Compiler is export;

method name() {
    "clang";
}

method supports() {
    return [
        App::snippet::Support.new(lang => Language::C, bin => 'clang'),
        App::snippet::Support.new(lang => Language::CXX, bin => 'clang++'),
    ];
}


