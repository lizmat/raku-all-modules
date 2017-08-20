use YAMLish;
use DBIish;
use Time::Crontab;
use Data::Dump;

state $DIR;
state $MAKE-REPORT;

state %CONFIG;
state $BUILD_STATE;

sub MAIN (
  Str  :$dir = "$*CWD",
  Bool :$make-report = False,
  Str  :$marker
)
{

  $DIR = $dir;

  $MAKE-REPORT = $make-report;

  my $project = $dir.IO.basename;

  my $reports-dir = "$dir/../.reports/$project".IO.absolute;

  my %config = Hash.new;

  if "$dir/sparky.yaml".IO ~~ :f {

    %config = load-yaml(slurp "$dir/sparky.yaml");
    %CONFIG = %config;

  }

  mkdir $dir;

  my $build_id;

  my $dbh;


  if $make-report {

    mkdir $reports-dir;
  
    $dbh = DBIish.connect("SQLite", database => "$dir/../db.sqlite3".IO.absolute );
  
    my $sth = $dbh.prepare(q:to/STATEMENT/);
      INSERT INTO builds (project, state)
      VALUES ( ?,?)
    STATEMENT
  
    $sth.execute($project, 0);
  
    $sth = $dbh.prepare(q:to/STATEMENT/);
        SELECT max(ID) AS build_id
        FROM builds
        STATEMENT
  
    $sth.execute();
  
    my @rows = $sth.allrows();
    $build_id = @rows[0][0];
  
    $sth.finish;
  
    say "RUN BUILD $project" ~ '@' ~ $build_id;

  } else {

    say "RUN BUILD <$project>";

  }

  my $sparrowdo-run = "sparrowdo --sparrow_root=/opt/sparky-sparrowdo/$project";

  $sparrowdo-run ~= ' --no_color' unless ! $make-report;

  my %sparrowdo-config = %config<sparrowdo> || Hash.new;

  if %sparrowdo-config<host> {
    $sparrowdo-run ~= " --host=" ~ %sparrowdo-config<host>;
  } else {
    $sparrowdo-run ~= " --local_mode";
  }

  if %sparrowdo-config<no_sudo> {
    $sparrowdo-run ~= " --no_sudo";
  }

  if %sparrowdo-config<no_index_update> {
    $sparrowdo-run ~= " --no_index_update";
  }


  if %sparrowdo-config<ssh_user> {
    $sparrowdo-run ~= " --ssh_user=" ~ %sparrowdo-config<ssh_user>;
  }

  if  %config<ssh_private_key> {
    $sparrowdo-run ~= " --ssh_private_key=" ~ %config<ssh_private_key>;
  }

  if %sparrowdo-config<ssh_port> {
    $sparrowdo-run ~= " --ssh_port=" ~ %sparrowdo-config<ssh_port>;
  }

  if %sparrowdo-config<http_proxy> {
    $sparrowdo-run ~= " --http_proxy=" ~ %sparrowdo-config<http_proxy>;
  }

  if %sparrowdo-config<https_proxy> {
    $sparrowdo-run ~= " --https_proxy=" ~ %sparrowdo-config<https_proxy>;
  }

  if  %sparrowdo-config<verbose> {
    $sparrowdo-run ~= " --verbose";
  }

  if $make-report {
    my $report-file = "$reports-dir/build-$build_id.txt";
    shell("$sparrowdo-run --task_run=directory" ~ '@path=' ~  "/var/data/sparky/$project --bootstrap 1>$report-file" ~ ' 2>&1');
    shell("echo >> $report-file && cd $dir && $sparrowdo-run --cwd=/var/data/sparky/$project 1>>$report-file" ~ ' 2>&1');
  } else{
    shell("$sparrowdo-run --task_run=directory" ~ '@path=' ~  "/var/data/sparky/$project --bootstrap"  ~ ' 2>&1');
    shell("echo && cd $dir && $sparrowdo-run --cwd=/var/data/sparky/$project" ~ ' 2>&1');
  }

  if $make-report {
    $dbh.do("UPDATE builds SET state = 1 WHERE ID = $build_id");
    say "BUILD SUCCEED $project" ~ '@' ~ $build_id;
    $BUILD_STATE="OK";
  } else {
    $BUILD_STATE="OK";
    say "BUILD SUCCEED <$project>";

  }


  CATCH {

      # will definitely catch all the exception 
      default { 
        warn .say;
        if $make-report {
          say "BUILD FAILED $project" ~ '@' ~ $build_id;
          $dbh.do("UPDATE builds SET state = -1 WHERE ID = $build_id");
          $BUILD_STATE="FAILED";

        } else {
          say "BUILD FAILED <$project>";
          $BUILD_STATE="FAILED";
        }
      }

  }


  # remove old builds

  if %config<keep_builds> and $make-report {

    say "keep builds: " ~ %config<keep_builds>;

    my $sth = $dbh.prepare(q:to/STATEMENT/);
        SELECT ID from builds where project = ? order by id asc
    STATEMENT
    
    $sth.execute($project);
    
    my @rows = $sth.allrows();
  
    my $all-builds = @rows.elems;

    $sth.finish;

    my $remove-builds = $all-builds - %config<keep_builds>;

    if $remove-builds > 0 {
      my $i=0;
      for @rows -> @r {
        $i++;
        my $bid = @r[0];
        if $i <= $remove-builds {
          if $dbh.do("delete from builds WHERE ID = $bid") {
            say "remove build $project" ~ '@' ~ $bid;
          } else {
            say "!!! can't remove build <$project>" ~ '@' ~ $bid;
          }
          if unlink "$reports-dir/build-$bid.txt".IO {
            say "remove $reports-dir/build-$bid.txt";
          } else {
            say "!!! can't remove $reports-dir/build-$bid.txt";
          }
        }

      }

    }

  } 


}

LEAVE {

  my $project = $DIR.IO.basename;

  say ">>>>>>>>>>>>>>>>>>>>>>>>>>>";
  say "BUILD SUMMARY";
  say "STATE: $BUILD_STATE";
  say "PROJECT: $project";
  say "CONFIG: " ~ Dump(%CONFIG, :color(!$MAKE-REPORT));
  say ">>>>>>>>>>>>>>>>>>>>>>>>>>>";


  # run downstream project
  if %CONFIG<downstream> {
  
    say "SCHEDULE BUILD for DOWNSTREAM project <" ~ %CONFIG<downstream> ~ "> ... \n";

    my $downstream_dir = ("$DIR/../" ~ %CONFIG<downstream>).IO.absolute;

    if $MAKE-REPORT {
      shell(
        'sparky-runner.pl6' ~ 
        " --marker=$project" ~ 
        " --dir=" ~ $downstream_dir ~
        " --make-report" ~ 
        ' &'
      ); 
    } else {
      shell(
        'sparky-runner.pl6' ~ 
        " --marker=$project" ~ 
        " --dir=" ~ $downstream_dir ~
        ' &'
      ); 
    }

  }

}
