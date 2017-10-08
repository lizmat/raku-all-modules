use lib 'lib';
use NASA::MarsRovers;

my NASA::MarsRovers $rovers .= new: key => 't/key'.IO.lines[0];

use Data::Dump;
my $oppy = $rovers.opportunity;
say Dump $oppy.query:
    #:1sol,
    :earth-date<2012-08-06>,
    #:camera<FHAZ>
    #:1page;

=finish

use Data::Dump;
my $res = $rovers.curiosity.query: :0sol;
say Dump $res;


=finish

my $v = {
  photos => [
    {
      camera     => {
        full_name => "Navigation Camera".Str,
        id        => 16.Int,
        name      => "NAVCAM".Str,
        rover_id  => 6.Int,
      },
      earth_date => "2012-08-07".Str,
      id         => 2097.Int,
      img_src    => "http://mars.jpl.nasa.gov/msl-raw-images/proj/msl/redops/ods/surface/sol/00001/opgs/edr/ncam/NLA_397586928EDR_F0010008AUT_04096M_.JPG".Str,
      rover      => {
        cameras      => [
          {
            full_name => "Front Hazard Avoidance Camera".Str,
            name      => "FHAZ".Str,
          },
          {
            full_name => "Navigation Camera".Str,
            name      => "NAVCAM".Str,
          },
          {
            full_name => "Mast Camera".Str,
            name      => "MAST".Str,
          },
          {
            full_name => "Chemistry and Camera Complex".Str,
            name      => "CHEMCAM".Str,
          },
          {
            full_name => "Mars Hand Lens Imager".Str,
            name      => "MAHLI".Str,
          },
          {
            full_name => "Mars Descent Imager".Str,
            name      => "MARDI".Str,
          },
          {
            full_name => "Rear Hazard Avoidance Camera".Str,
            name      => "RHAZ".Str,
          },
        ],
        id           => 5.Int,
        landing_date => "2012-08-06".Str,
        max_date     => "2016-04-17".Str,
        max_sol      => 1314.Int,
        name         => "Curiosity".Str,
        total_photos => 250163.Int,
      },
      sol        => 1.Int,
    },
    {
      camera     => {
        full_name => "Navigation Camera".Str,
        id        => 16.Int,
        name      => "NAVCAM".Str,
        rover_id  => 6.Int,
      },
      earth_date => "2012-08-07".Str,
      id         => 32445.Int,
      img_src    => "http://mars.jpl.nasa.gov/msl-raw-images/proj/msl/redops/ods/surface/sol/00001/opgs/edr/ncam/NLA_397586934EDR_F0010008AUT_04096M_.JPG".Str,
      rover      => {
        cameras      => [
          {
            full_name => "Front Hazard Avoidance Camera".Str,
            name      => "FHAZ".Str,
          },
          {
            full_name => "Navigation Camera".Str,
            name      => "NAVCAM".Str,
          },
          {
            full_name => "Mast Camera".Str,
            name      => "MAST".Str,
          },
          {
            full_name => "Chemistry and Camera Complex".Str,
            name      => "CHEMCAM".Str,
          },
          {
            full_name => "Mars Hand Lens Imager".Str,
            name      => "MAHLI".Str,
          },
          {
            full_name => "Mars Descent Imager".Str,
            name      => "MARDI".Str,
          },
          {
            full_name => "Rear Hazard Avoidance Camera".Str,
            name      => "RHAZ".Str,
          },
        ],
        id           => 5.Int,
        landing_date => "2012-08-06".Str,
        max_date     => "2016-04-17".Str,
        max_sol      => 1314.Int,
        name         => "Curiosity".Str,
        total_photos => 250163.Int,
      },
      sol        => 1.Int,
    },
    {
      camera     => {
        full_name => "Navigation Camera".Str,
        id        => 16.Int,
        name      => "NAVCAM".Str,
        rover_id  => 6.Int,
      },
      earth_date => "2012-08-07".Str,
      id         => 2674.Int,
      img_src    => "http://mars.jpl.nasa.gov/msl-raw-images/proj/msl/redops/ods/surface/sol/00001/opgs/edr/ncam/NRA_397586928EDR_F0010008AUT_04096M_.JPG".Str,
      rover      => {
        cameras      => [
          {
            full_name => "Front Hazard Avoidance Camera".Str,
            name      => "FHAZ".Str,
          },
          {
            full_name => "Navigation Camera".Str,
            name      => "NAVCAM".Str,
          },
          {
            full_name => "Mast Camera".Str,
            name      => "MAST".Str,
          },
          {
            full_name => "Chemistry and Camera Complex".Str,
            name      => "CHEMCAM".Str,
          },
          {
            full_name => "Mars Hand Lens Imager".Str,
            name      => "MAHLI".Str,
          },
          {
            full_name => "Mars Descent Imager".Str,
            name      => "MARDI".Str,
          },
          {
            full_name => "Rear Hazard Avoidance Camera".Str,
            name      => "RHAZ".Str,
          },
        ],
        id           => 5.Int,
        landing_date => "2012-08-06".Str,
        max_date     => "2016-04-17".Str,
        max_sol      => 1314.Int,
        name         => "Curiosity".Str,
        total_photos => 250163.Int,
      },
      sol        => 1.Int,
    },
    {
      camera     => {
        full_name => "Navigation Camera".Str,
        id        => 16.Int,
        name      => "NAVCAM".Str,
        rover_id  => 6.Int,
      },
      earth_date => "2012-08-07".Str,
      id         => 49201.Int,
      img_src    => "http://mars.jpl.nasa.gov/msl-raw-images/proj/msl/redops/ods/surface/sol/00001/opgs/edr/ncam/NRA_397586934EDR_F0010008AUT_04096M_.JPG".Str,
      rover      => {
        cameras      => [
          {
            full_name => "Front Hazard Avoidance Camera".Str,
            name      => "FHAZ".Str,
          },
          {
            full_name => "Navigation Camera".Str,
            name      => "NAVCAM".Str,
          },
          {
            full_name => "Mast Camera".Str,
            name      => "MAST".Str,
          },
          {
            full_name => "Chemistry and Camera Complex".Str,
            name      => "CHEMCAM".Str,
          },
          {
            full_name => "Mars Hand Lens Imager".Str,
            name      => "MAHLI".Str,
          },
          {
            full_name => "Mars Descent Imager".Str,
            name      => "MARDI".Str,
          },
          {
            full_name => "Rear Hazard Avoidance Camera".Str,
            name      => "RHAZ".Str,
          },
        ],
        id           => 5.Int,
        landing_date => "2012-08-06".Str,
        max_date     => "2016-04-17".Str,
        max_sol      => 1314.Int,
        name         => "Curiosity".Str,
        total_photos => 250163.Int,
      },
      sol        => 1.Int,
    },
    {
      camera     => {
        full_name => "Mast Camera".Str,
        id        => 22.Int,
        name      => "MAST".Str,
        rover_id  => 5.Int,
      },
      earth_date => "2012-08-07".Str,
      id         => 509234.Int,
      img_src    => "http://mars.jpl.nasa.gov/msl-raw-images/msss/00001/mcam/0001ML0000001000C0_DXXX.jpg".Str,
      rover      => {
        cameras      => [
          {
            full_name => "Front Hazard Avoidance Camera".Str,
            name      => "FHAZ".Str,
          },
          {
            full_name => "Navigation Camera".Str,
            name      => "NAVCAM".Str,
          },
          {
            full_name => "Mast Camera".Str,
            name      => "MAST".Str,
          },
          {
            full_name => "Chemistry and Camera Complex".Str,
            name      => "CHEMCAM".Str,
          },
          {
            full_name => "Mars Hand Lens Imager".Str,
            name      => "MAHLI".Str,
          },
          {
            full_name => "Mars Descent Imager".Str,
            name      => "MARDI".Str,
          },
          {
            full_name => "Rear Hazard Avoidance Camera".Str,
            name      => "RHAZ".Str,
          },
        ],
        id           => 5.Int,
        landing_date => "2012-08-06".Str,
        max_date     => "2016-04-17".Str,
        max_sol      => 1314.Int,
        name         => "Curiosity".Str,
        total_photos => 250163.Int,
      },
      sol        => 1.Int,
    },
    {
      camera     => {
        full_name => "Mast Camera".Str,
        id        => 22.Int,
        name      => "MAST".Str,
        rover_id  => 5.Int,
      },
      earth_date => "2012-08-07".Str,
      id         => 4477.Int,
      img_src    => "http://mars.jpl.nasa.gov/msl-raw-images/msss/00001/mcam/0001ML0000001000I1_DXXX.jpg".Str,
      rover      => {
        cameras      => [
          {
            full_name => "Front Hazard Avoidance Camera".Str,
            name      => "FHAZ".Str,
          },
          {
            full_name => "Navigation Camera".Str,
            name      => "NAVCAM".Str,
          },
          {
            full_name => "Mast Camera".Str,
            name      => "MAST".Str,
          },
          {
            full_name => "Chemistry and Camera Complex".Str,
            name      => "CHEMCAM".Str,
          },
          {
            full_name => "Mars Hand Lens Imager".Str,
            name      => "MAHLI".Str,
          },
          {
            full_name => "Mars Descent Imager".Str,
            name      => "MARDI".Str,
          },
          {
            full_name => "Rear Hazard Avoidance Camera".Str,
            name      => "RHAZ".Str,
          },
        ],
        id           => 5.Int,
        landing_date => "2012-08-06".Str,
        max_date     => "2016-04-17".Str,
        max_sol      => 1314.Int,
        name         => "Curiosity".Str,
        total_photos => 250163.Int,
      },
      sol        => 1.Int,
    },
    {
      camera     => {
        full_name => "Mast Camera".Str,
        id        => 22.Int,
        name      => "MAST".Str,
        rover_id  => 5.Int,
      },
      earth_date => "2012-08-07".Str,
      id         => 509233.Int,
      img_src    => "http://mars.jpl.nasa.gov/msl-raw-images/msss/00001/mcam/0001MR0000001000C0_DXXX.jpg".Str,
      rover      => {
        cameras      => [
          {
            full_name => "Front Hazard Avoidance Camera".Str,
            name      => "FHAZ".Str,
          },
          {
            full_name => "Navigation Camera".Str,
            name      => "NAVCAM".Str,
          },
          {
            full_name => "Mast Camera".Str,
            name      => "MAST".Str,
          },
          {
            full_name => "Chemistry and Camera Complex".Str,
            name      => "CHEMCAM".Str,
          },
          {
            full_name => "Mars Hand Lens Imager".Str,
            name      => "MAHLI".Str,
          },
          {
            full_name => "Mars Descent Imager".Str,
            name      => "MARDI".Str,
          },
          {
            full_name => "Rear Hazard Avoidance Camera".Str,
            name      => "RHAZ".Str,
          },
        ],
        id           => 5.Int,
        landing_date => "2012-08-06".Str,
        max_date     => "2016-04-17".Str,
        max_sol      => 1314.Int,
        name         => "Curiosity".Str,
        total_photos => 250163.Int,
      },
      sol        => 1.Int,
    },
    {
      camera     => {
        full_name => "Mast Camera".Str,
        id        => 22.Int,
        name      => "MAST".Str,
        rover_id  => 5.Int,
      },
      earth_date => "2012-08-07".Str,
      id         => 509235.Int,
      img_src    => "http://mars.jpl.nasa.gov/msl-raw-images/msss/00001/mcam/0001MR0000001000I1_DXXX.jpg".Str,
      rover      => {
        cameras      => [
          {
            full_name => "Front Hazard Avoidance Camera".Str,
            name      => "FHAZ".Str,
          },
          {
            full_name => "Navigation Camera".Str,
            name      => "NAVCAM".Str,
          },
          {
            full_name => "Mast Camera".Str,
            name      => "MAST".Str,
          },
          {
            full_name => "Chemistry and Camera Complex".Str,
            name      => "CHEMCAM".Str,
          },
          {
            full_name => "Mars Hand Lens Imager".Str,
            name      => "MAHLI".Str,
          },
          {
            full_name => "Mars Descent Imager".Str,
            name      => "MARDI".Str,
          },
          {
            full_name => "Rear Hazard Avoidance Camera".Str,
            name      => "RHAZ".Str,
          },
        ],
        id           => 5.Int,
        landing_date => "2012-08-06".Str,
        max_date     => "2016-04-17".Str,
        max_sol      => 1314.Int,
        name         => "Curiosity".Str,
        total_photos => 250163.Int,
      },
      sol        => 1.Int,
    },
    {
      camera     => {
        full_name => "Mars Hand Lens Imager".Str,
        id        => 24.Int,
        name      => "MAHLI".Str,
        rover_id  => 5.Int,
      },
      earth_date => "2012-08-07".Str,
      id         => 86521.Int,
      img_src    => "http://mars.jpl.nasa.gov/msl-raw-images/msss/00001/mhli/0001MH0000001000E1_DXXX.jpg".Str,
      rover      => {
        cameras      => [
          {
            full_name => "Front Hazard Avoidance Camera".Str,
            name      => "FHAZ".Str,
          },
          {
            full_name => "Navigation Camera".Str,
            name      => "NAVCAM".Str,
          },
          {
            full_name => "Mast Camera".Str,
            name      => "MAST".Str,
          },
          {
            full_name => "Chemistry and Camera Complex".Str,
            name      => "CHEMCAM".Str,
          },
          {
            full_name => "Mars Hand Lens Imager".Str,
            name      => "MAHLI".Str,
          },
          {
            full_name => "Mars Descent Imager".Str,
            name      => "MARDI".Str,
          },
          {
            full_name => "Rear Hazard Avoidance Camera".Str,
            name      => "RHAZ".Str,
          },
        ],
        id           => 5.Int,
        landing_date => "2012-08-06".Str,
        max_date     => "2016-04-17".Str,
        max_sol      => 1314.Int,
        name         => "Curiosity".Str,
        total_photos => 250163.Int,
      },
      sol        => 1.Int,
    },
    {
      camera     => {
        full_name => "Mars Hand Lens Imager".Str,
        id        => 24.Int,
        name      => "MAHLI".Str,
        rover_id  => 5.Int,
      },
      earth_date => "2012-08-07".Str,
      id         => 86522.Int,
      img_src    => "http://mars.jpl.nasa.gov/msl-raw-images/msss/00001/mhli/0001MH0000001000E2_DXXX.jpg".Str,
      rover      => {
        cameras      => [
          {
            full_name => "Front Hazard Avoidance Camera".Str,
            name      => "FHAZ".Str,
          },
          {
            full_name => "Navigation Camera".Str,
            name      => "NAVCAM".Str,
          },
          {
            full_name => "Mast Camera".Str,
            name      => "MAST".Str,
          },
          {
            full_name => "Chemistry and Camera Complex".Str,
            name      => "CHEMCAM".Str,
          },
          {
            full_name => "Mars Hand Lens Imager".Str,
            name      => "MAHLI".Str,
          },
          {
            full_name => "Mars Descent Imager".Str,
            name      => "MARDI".Str,
          },
          {
            full_name => "Rear Hazard Avoidance Camera".Str,
            name      => "RHAZ".Str,
          },
        ],
        id           => 5.Int,
        landing_date => "2012-08-06".Str,
        max_date     => "2016-04-17".Str,
        max_sol      => 1314.Int,
        name         => "Curiosity".Str,
        total_photos => 250163.Int,
      },
      sol        => 1.Int,
    },
    {
      camera     => {
        full_name => "Mars Hand Lens Imager".Str,
        id        => 24.Int,
        name      => "MAHLI".Str,
        rover_id  => 5.Int,
      },
      earth_date => "2012-08-07".Str,
      id         => 86525.Int,
      img_src    => "http://mars.jpl.nasa.gov/msl-raw-images/msss/00001/mhli/0001MH0000001000I1_DXXX.jpg".Str,
      rover      => {
        cameras      => [
          {
            full_name => "Front Hazard Avoidance Camera".Str,
            name      => "FHAZ".Str,
          },
          {
            full_name => "Navigation Camera".Str,
            name      => "NAVCAM".Str,
          },
          {
            full_name => "Mast Camera".Str,
            name      => "MAST".Str,
          },
          {
            full_name => "Chemistry and Camera Complex".Str,
            name      => "CHEMCAM".Str,
          },
          {
            full_name => "Mars Hand Lens Imager".Str,
            name      => "MAHLI".Str,
          },
          {
            full_name => "Mars Descent Imager".Str,
            name      => "MARDI".Str,
          },
          {
            full_name => "Rear Hazard Avoidance Camera".Str,
            name      => "RHAZ".Str,
          },
        ],
        id           => 5.Int,
        landing_date => "2012-08-06".Str,
        max_date     => "2016-04-17".Str,
        max_sol      => 1314.Int,
        name         => "Curiosity".Str,
        total_photos => 250163.Int,
      },
      sol        => 1.Int,
    },
    {
      camera     => {
        full_name => "Mars Hand Lens Imager".Str,
        id        => 24.Int,
        name      => "MAHLI".Str,
        rover_id  => 5.Int,
      },
      earth_date => "2012-08-07".Str,
      id         => 86526.Int,
      img_src    => "http://mars.jpl.nasa.gov/msl-raw-images/msss/00001/mhli/0001MH0000001000I2_DXXX.jpg".Str,
      rover      => {
        cameras      => [
          {
            full_name => "Front Hazard Avoidance Camera".Str,
            name      => "FHAZ".Str,
          },
          {
            full_name => "Navigation Camera".Str,
            name      => "NAVCAM".Str,
          },
          {
            full_name => "Mast Camera".Str,
            name      => "MAST".Str,
          },
          {
            full_name => "Chemistry and Camera Complex".Str,
            name      => "CHEMCAM".Str,
          },
          {
            full_name => "Mars Hand Lens Imager".Str,
            name      => "MAHLI".Str,
          },
          {
            full_name => "Mars Descent Imager".Str,
            name      => "MARDI".Str,
          },
          {
            full_name => "Rear Hazard Avoidance Camera".Str,
            name      => "RHAZ".Str,
          },
        ],
        id           => 5.Int,
        landing_date => "2012-08-06".Str,
        max_date     => "2016-04-17".Str,
        max_sol      => 1314.Int,
        name         => "Curiosity".Str,
        total_photos => 250163.Int,
      },
      sol        => 1.Int,
    },
    {
      camera     => {
        full_name => "Mars Hand Lens Imager".Str,
        id        => 24.Int,
        name      => "MAHLI".Str,
        rover_id  => 5.Int,
      },
      earth_date => "2012-08-07".Str,
      id         => 3778.Int,
      img_src    => "http://mars.jpl.nasa.gov/msl-raw-images/msss/00001/mhli/0001MH0000001000I3_DXXX.jpg".Str,
      rover      => {
        cameras      => [
          {
            full_name => "Front Hazard Avoidance Camera".Str,
            name      => "FHAZ".Str,
          },
          {
            full_name => "Navigation Camera".Str,
            name      => "NAVCAM".Str,
          },
          {
            full_name => "Mast Camera".Str,
            name      => "MAST".Str,
          },
          {
            full_name => "Chemistry and Camera Complex".Str,
            name      => "CHEMCAM".Str,
          },
          {
            full_name => "Mars Hand Lens Imager".Str,
            name      => "MAHLI".Str,
          },
          {
            full_name => "Mars Descent Imager".Str,
            name      => "MARDI".Str,
          },
          {
            full_name => "Rear Hazard Avoidance Camera".Str,
            name      => "RHAZ".Str,
          },
        ],
        id           => 5.Int,
        landing_date => "2012-08-06".Str,
        max_date     => "2016-04-17".Str,
        max_sol      => 1314.Int,
        name         => "Curiosity".Str,
        total_photos => 250163.Int,
      },
      sol        => 1.Int,
    },
    {
      camera     => {
        full_name => "Mars Hand Lens Imager".Str,
        id        => 24.Int,
        name      => "MAHLI".Str,
        rover_id  => 5.Int,
      },
      earth_date => "2012-08-07".Str,
      id         => 86520.Int,
      img_src    => "http://mars.jpl.nasa.gov/msl-raw-images/msss/00001/mhli/0001MH0000002000C0_DXXX.jpg".Str,
      rover      => {
        cameras      => [
          {
            full_name => "Front Hazard Avoidance Camera".Str,
            name      => "FHAZ".Str,
          },
          {
            full_name => "Navigation Camera".Str,
            name      => "NAVCAM".Str,
          },
          {
            full_name => "Mast Camera".Str,
            name      => "MAST".Str,
          },
          {
            full_name => "Chemistry and Camera Complex".Str,
            name      => "CHEMCAM".Str,
          },
          {
            full_name => "Mars Hand Lens Imager".Str,
            name      => "MAHLI".Str,
          },
          {
            full_name => "Mars Descent Imager".Str,
            name      => "MARDI".Str,
          },
          {
            full_name => "Rear Hazard Avoidance Camera".Str,
            name      => "RHAZ".Str,
          },
        ],
        id           => 5.Int,
        landing_date => "2012-08-06".Str,
        max_date     => "2016-04-17".Str,
        max_sol      => 1314.Int,
        name         => "Curiosity".Str,
        total_photos => 250163.Int,
      },
      sol        => 1.Int,
    },
    {
      camera     => {
        full_name => "Mars Hand Lens Imager".Str,
        id        => 24.Int,
        name      => "MAHLI".Str,
        rover_id  => 5.Int,
      },
      earth_date => "2012-08-07".Str,
      id         => 86523.Int,
      img_src    => "http://mars.jpl.nasa.gov/msl-raw-images/msss/00001/mhli/0001MH0000002000I1_DXXX.jpg".Str,
      rover      => {
        cameras      => [
          {
            full_name => "Front Hazard Avoidance Camera".Str,
            name      => "FHAZ".Str,
          },
          {
            full_name => "Navigation Camera".Str,
            name      => "NAVCAM".Str,
          },
          {
            full_name => "Mast Camera".Str,
            name      => "MAST".Str,
          },
          {
            full_name => "Chemistry and Camera Complex".Str,
            name      => "CHEMCAM".Str,
          },
          {
            full_name => "Mars Hand Lens Imager".Str,
            name      => "MAHLI".Str,
          },
          {
            full_name => "Mars Descent Imager".Str,
            name      => "MARDI".Str,
          },
          {
            full_name => "Rear Hazard Avoidance Camera".Str,
            name      => "RHAZ".Str,
          },
        ],
        id           => 5.Int,
        landing_date => "2012-08-06".Str,
        max_date     => "2016-04-17".Str,
        max_sol      => 1314.Int,
        name         => "Curiosity".Str,
        total_photos => 250163.Int,
      },
      sol        => 1.Int,
    },
    {
      camera     => {
        full_name => "Mars Hand Lens Imager".Str,
        id        => 24.Int,
        name      => "MAHLI".Str,
        rover_id  => 5.Int,
      },
      earth_date => "2012-08-07".Str,
      id         => 86524.Int,
      img_src    => "http://mars.jpl.nasa.gov/msl-raw-images/msss/00001/mhli/0001MH0000002000I2_DXXX.jpg".Str,
      rover      => {
        cameras      => [
          {
            full_name => "Front Hazard Avoidance Camera".Str,
            name      => "FHAZ".Str,
          },
          {
            full_name => "Navigation Camera".Str,
            name      => "NAVCAM".Str,
          },
          {
            full_name => "Mast Camera".Str,
            name      => "MAST".Str,
          },
          {
            full_name => "Chemistry and Camera Complex".Str,
            name      => "CHEMCAM".Str,
          },
          {
            full_name => "Mars Hand Lens Imager".Str,
            name      => "MAHLI".Str,
          },
          {
            full_name => "Mars Descent Imager".Str,
            name      => "MARDI".Str,
          },
          {
            full_name => "Rear Hazard Avoidance Camera".Str,
            name      => "RHAZ".Str,
          },
        ],
        id           => 5.Int,
        landing_date => "2012-08-06".Str,
        max_date     => "2016-04-17".Str,
        max_sol      => 1314.Int,
        name         => "Curiosity".Str,
        total_photos => 250163.Int,
      },
      sol        => 1.Int,
    },
  ],
};

use Data::Dump;
say Dump $v<photos>[0];
