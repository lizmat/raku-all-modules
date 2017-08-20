use Bailador;
use DBIish;
use Text::Markdown;
use YAMLish;

my $root = %*ENV<SPARKY_ROOT> || '/home/' ~ %*ENV<USER> ~ '/.sparky/projects';
my $reports-dir = "$root/.reports";

get '/' => sub {

  my $dbh = DBIish.connect("SQLite", database => "$root/db.sqlite3".IO.absolute );

  my $sth = $dbh.prepare(q:to/STATEMENT/);
      SELECT * FROM builds order by dt desc
  STATEMENT

  $sth.execute();

  my @rows = $sth.allrows(:array-of-hash);

  $sth.finish;

  $dbh.dispose;
  
  template 'builds.tt', css(), @rows;   

}

get '/report/(\S+)/(\d+)' => sub ($project, $build_id) {
  if "$reports-dir/$project/build-$build_id.txt".IO ~~ :f {
    template 'report.tt', css(), $project, $build_id, "$reports-dir/$project/build-$build_id.txt";
  } else {
    status(404);
  }
}

get '/project/(\S+)' => sub ($project) {
  if "$root/$project/sparrowfile".IO ~~ :f {
    my $project-conf;
    my $err;
      if "$root/$project/sparky.yaml".IO ~~ :f {
      $project-conf = slurp "$root/$project/sparky.yaml"; 
      load-yaml($project-conf);
      CATCH {
        default {
          $err = .Str;
        }
      }
    }
    template 'project.tt', css(), $project, $project-conf, "$root/$project/sparrowfile", $err;
  } else {
    status(404);
  }
}

get '/about' => sub {

  my $raw-md = slurp "README.md";
  my $md = parse-markdown($raw-md);
  template 'about.tt', css(), $md.to_html;
}

static-dir / (.*) / => '/public';

sub css {

  q:to /CSS/;

  <!-- Latest compiled and minified CSS -->
  <link rel="stylesheet" href="/css/bootstrap.min.css" crossorigin="anonymous">

  <!-- Optional theme -->
  <link rel="stylesheet" href="/css/bootstrap-theme.min.css" crossorigin="anonymous">

  <!-- Latest compiled and minified JavaScript -->
  <script src="/js/bootstrap.min.js" crossorigin="anonymous"></script>

  CSS
}

baile;

