use NASA::UA;
use Subset::Helper;
use URI::Escape;
unit role NASA::MarsRovers::Rover does NASA::UA;

my constant $rovers = set <curiosity opportunity spirit>;
my constant $cams = set <FHAZ RHAZ MAST CHEMCAM MAHLI MARDI NAVCAM PANCAM MINITES>;

my subset RoverName of Str where subset-is
    * ∈ $rovers,
    "Rover name must be one of $rovers";

my subset RoverCam of Str where subset-is
    * ∈ $cams, "Camera name must be one of $cams";

my subset EarthDate of Str where subset-is
    { $_ ~~ m/^ \d**4 '-' \d**2 '-' \d**2 $/ },
    'Date format is YYYY-MM-DD';

my subset Page of Int where subset-is * >= 1, 'Page must be >= 1';
my subset Sol  of Int where subset-is * >= 0, 'Sol must be >= 0';

has RoverName $.name is required;
has Str       $!api-url = 'https://api.nasa.gov/mars-photos/api/v1/rovers/';

method query (
    Sol       :$sol,
    EarthDate :$earth-date,
    RoverCam  :$camera,
    Int       :$page,
) {
    $sol.defined and $earth-date
        and fail 'You must provide either Sol or Earth Date, not both';

    $sol.defined or $earth-date
        or fail 'You must provide either Sol or Earth Date';

    my %valid-cams =
        curiosity   => set(<FHAZ RHAZ MAST CHEMCAM MAHLI MARDI NAVCAM>),
        opportunity => set(<FHAZ RHAZ NAVCAM PANCAM MINITES>),
        spirit      => set(<FHAZ RHAZ NAVCAM PANCAM MINITES>);

    if ( $camera ) {
        %valid-cams{ $!name }{ $camera } or
            fail "Rover $!name does not have $camera camera";
    }

    my $res = self!request: 'GET', $!api-url
        ~ uri-escape($!name) ~ '/photos',
        |(sol        => $sol        if $sol.defined),
        |(earth_date => $earth-date if $earth-date ),
        |(camera     => $camera     if $camera     ),
        |(page       => $page       if $page       );

    my $rover = $res.hash.<photos>[0]<rover>;
    my %rover-cams;
    %rover-cams{ .<name> } = .<full_name> for |($rover<cameras> || []);
    $rover<cameras> = %rover-cams;
    $rover<id>:delete;

    my %cameras;
    for |$res<photos> {
        %cameras{ .<camera><name> }.push: %(
            id      => .<id>,
            img_src => .<img_src>,
        );
#        %cameras{ .<camera><name> }<full_name  id  name>
#        = .<camera><full_name  id  name>;
    }

    return { rover => $rover, cameras => %cameras };
}
