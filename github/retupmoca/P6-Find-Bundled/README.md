# Find::Bundled

This is a simple replacement for %?RESOURCE, until such a thing exists.

# Example usage

    use Find::Bundled;

    my $filename = Find::Bundled.find('lib.dll', 'MyModule/libs', :keep-filename);

### method find($file, $basepath, :$keep-filename, :$return-original, :$throw)
