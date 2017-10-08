module Haikunator {
  my @ADJECTIVES = [
  "autumn", "hidden", "bitter", "misty", "silent", "empty", "dry", "dark",
  "summer", "icy", "delicate", "quiet", "white", "cool", "spring", "winter",
  "patient", "twilight", "dawn", "crimson", "wispy", "weathered", "blue",
  "billowing", "broken", "cold", "damp", "falling", "frosty", "green",
  "long", "late", "lingering", "bold", "little", "morning", "muddy", "old",
  "red", "rough", "still", "small", "sparkling", "throbbing", "shy",
  "wandering", "withered", "wild", "black", "young", "holy", "solitary",
  "fragrant", "aged", "snowy", "proud", "floral", "restless", "divine",
  "polished", "ancient", "purple", "lively", "nameless", "lucky", "odd", "tiny",
  "free", "dry", "yellow", "orange", "gentle", "tight", "super", "royal", "broad",
  "steep", "flat", "square", "round", "mute", "noisy", "hushy", "raspy", "soft",
  "shrill", "rapid", "sweet", "curly", "calm", "jolly", "fancy", "plain", "shinny"
];

my @NOUNS = [
  "waterfall", "river", "breeze", "moon", "rain", "wind", "sea", "morning",
  "snow", "lake", "sunset", "pine", "shadow", "leaf", "dawn", "glitter",
  "forest", "hill", "cloud", "meadow", "sun", "glade", "bird", "brook",
  "butterfly", "bush", "dew", "dust", "field", "fire", "flower", "firefly",
  "feather", "grass", "haze", "mountain", "night", "pond", "darkness",
  "snowflake", "silence", "sound", "sky", "shape", "surf", "thunder",
  "violet", "water", "wildflower", "wave", "water", "resonance", "sun",
  "wood", "dream", "cherry", "tree", "fog", "frost", "voice", "paper",
  "frog", "smoke", "star", "atom", "band", "bar", "base", "block", "boat",
  "term", "credit", "art", "fashion", "truth", "disk", "math", "unit", "cell",
  "scene", "heart", "recipe", "union", "limit", "bread", "toast", "bonus",
  "lab", "mud", "mode", "poetry", "tooth", "hall", "king", "queen", "lion", "tiger",
  "penguin", "kiwi", "cake", "mouse", "rice", "coke", "hola", "salad", "hat"
];

sub haikunate(:$delimiter = "-", :$tokenLength = 4, :$tokenHex = False, :$tokenChars is copy = "0123456789") is export {
    if ($tokenHex) {
      $tokenChars = "0123456789abcdef";
    }

    my $adjective = @ADJECTIVES.pick;
    my $noun = @NOUNS.pick;
    my $token = "";

    loop (my $i = 0; $i < $tokenLength; $i++) {
      $token ~= substr($tokenChars, rand * chars($tokenChars), 1)
    }

    my @sections = [$adjective, $noun, $token].grep(?*);
    return @sections.join($delimiter);
  }

}
