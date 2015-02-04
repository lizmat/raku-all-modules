class Pray::Scene::Material;

use Pray::Scene::Color;
use Pray::Scene::Lighting;

has Pray::Scene::Ambiance $.ambient;
has Pray::Scene::Diffusion $.diffuse;
has Pray::Scene::Specularity $.specular;
has Pray::Scene::Reflection $.reflective;
has Pray::Scene::Transparency $.transparent;

method intersection_color (
    $int,
    $recurse,
) {
    my $color = black;
    
    unless $int.exiting {
        $color = $.ambient.color_shaded if $.ambient;
        
        for $int.scene.lights[] -> $light {
            my $light_dir = $light.position.subtract($int.position);
            my $light_dir_norm = $light_dir.normalize;
            my $cos_to_light = $int.direction.dot($light_dir_norm);

            # Horizon check
            next unless $cos_to_light > 0;

            # Incoming light from this source after shadow and falloff
            my $light_color = $light.intersection_color($int);
            next if $light_color.is_black;
            
            # Diffusion
            $color .= add( $.diffuse.color_shaded(
                    $light_color,
                    cos => $cos_to_light
            ) ) if $.diffuse;

            # Specularity
            $color .= add( $.specular.color_shaded(
                    $light_color,
                    $int,
                    $light_dir_norm,
            ) ) if $.specular;
        }

        # Reflection
        $color .= add( $.reflective.color_shaded(
            $int,
            :recurse($recurse-1),
        ) ) if $.reflective && $recurse;
    }

    # Transparency and Refraction
    if $.transparent {
        my $trans_color = black;
        $trans_color = $.transparent.color_shaded(
            $int,
            :recurse($recurse-1),
        ) if $recurse;
            
        if $int.exiting {
            $color = $trans_color;
        } else {
            $color = $color\
                .scale(1-$.transparent.intensity)\
                .add($trans_color);
        }
    }

    return $color;
}
