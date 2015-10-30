use Pod::Perl5::Grammar;
use Pod::Perl5::ToHTML;
use Pod::Perl5::ToMarkdown;

class Pod::Perl5:ver<0.18>
{
  our sub parse-file (Str:D $filepath, $actions?)
  {
    my $match;

    if $actions
    {
      $match = Pod::Perl5::Grammar.parsefile($filepath, :$actions);
    }
    else
    {
      $match = Pod::Perl5::Grammar.parsefile($filepath);
    }

    unless ($match)
    {
      die "Error parsing pod";
    }
    return $match;
  }

  our sub parse-string (Str:D $pod, $actions?)
  {
    my $match;

    if $actions
    {
      $match = Pod::Perl5::Grammar.parse($pod, :$actions);
    }
    else
    {
      $match = Pod::Perl5::Grammar.parse($pod);
    }

    unless ($match)
    {
      die "Error parsing pod";
    }
    return $match;
  }

  our sub string-to-html (Str:D $pod)
  {
    my $actions = Pod::Perl5::ToHTML.new;
    return parse-string($pod, $actions).made;
  }

  our sub file-to-html (Str:D $filepath)
  {
    my $actions = Pod::Perl5::ToHTML.new;
    return parse-file($filepath, $actions).made;
  }

  our sub string-to-markdown (Str:D $pod)
  {
    my $actions = Pod::Perl5::ToMarkdown.new;
    return parse-string($pod, $actions).made;
  }

  our sub file-to-markdown (Str:D $filepath)
  {
    my $actions = Pod::Perl5::ToMarkdown.new;
    return parse-file($filepath, $actions).made;
  }
}
