class App::Platform::Util::YAML {
    submethod merge(@files) {
        for @files {
            $_.print;
        }
    }
}
