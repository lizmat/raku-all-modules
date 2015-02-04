class Pray::Scene::Object;

use Pray::Geometry::Object;
use Pray::Scene::Lighting;
use Pray::Scene::Material;

has Pray::Geometry::Object $.geometry;
has Pray::Scene::Material $.material =
    Pray::Scene::Material.new(
        ambient => Pray::Scene::Ambiance.new( :intensity(.1) ),
        diffuse => Pray::Scene::Diffusion.new
    )
;
