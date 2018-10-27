use v6;

unit class Flower::Provider::File;

has @.include-path;
has %.templates;
has $.ext is rw = '.xml';

## TODO: Implement 'absolute', 'relative', etc. options.

submethod BUILD (:@path, *%args) 
{
  if @path 
  {
    @!include-path.splice(@!include-path.elems, 0, @path);
  }
}

method add-path ($path) 
{
  @!include-path.push: $path;
}

method fetch ($name) 
{
  if %.templates{$name}:exists 
  {
    return %.templates{$name};
  }
  for @.include-path -> $path 
  {
    my $file = "$path/$name"~$.ext;
    if $file.IO ~~ :f 
    {
      my $template = slurp $file;
      %.templates{$name} = $template;
      return $template;
    }
  }
  return;
}

method store ($name, $template) 
{
  %.templates{$name} = $template;
}
