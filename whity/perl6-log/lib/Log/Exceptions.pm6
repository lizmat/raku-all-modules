class X::Log::InvalidLevelException is Exception {
    has Str $.level;

    method message() returns Str {
        return 'invalid level: ' ~ self.level;
    }
}
