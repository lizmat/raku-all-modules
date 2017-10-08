use Hematite::App;

unit class Hematite;

method new(::?CLASS:U: |args) returns Hematite::App {
    return Hematite::App.new(|%(args));
}
