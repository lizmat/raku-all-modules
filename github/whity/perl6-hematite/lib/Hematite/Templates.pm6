use X::Hematite;
use Template::Mustache;

unit class Hematite::Templates does Callable;

has Str $.directory;
has Str $.extension;
has Str %!cache = ();

submethod BUILD(Str :$directory, Str :$extension) {
    $!directory = $directory || $*CWD ~ '/templates';

    $!extension = $extension || '.mustache';
    if ( !$!extension.substr-eq(".", 0) ) {
        $!extension = ".{ $!extension }";
    }

    return self;
}

method render-string(Str $template, :%data = {}, *%args) returns Str {
    return Template::Mustache.render(
        $template,
        %data.clone,
        from      => [self.directory],
        extension => self.extension,
    );
}

method render-template(Str $name, :%data = {}, *%args) returns Str {
    # check in cache
    my Str $template = %!cache{$name};
    if (!$template) {
        # build full template file path and check if exists
        my $filepath = "{ self.directory }/{ $name }";
        if (!$filepath.IO.extension) {
            # if no extension, by default use 'html'
            $filepath ~= "{ self.extension }";
        }

        # if file doesn't exists, throw error
        $filepath = $filepath.IO;
        if (!$filepath.e) {
            X::Hematite::TemplateNotFoundException.new(
                path => $filepath.Str).throw;
        }

        $template = $filepath.slurp;
        %!cache{$name} = $template;
    }

    return self.render-string($template, data => %data, |%args);
}

# render($template-name) ; render($template-string, inline => True)
method render(Str $data, *%args) returns Str {
    if (%args{'inline'}) {
        return self.render-string($data, |%args);
    }

    return self.render-template($data, |%args);
}

method CALL-ME($data, |args) {
    return self.render($data, |%(args));
}
