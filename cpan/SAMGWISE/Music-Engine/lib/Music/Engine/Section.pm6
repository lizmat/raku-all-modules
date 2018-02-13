use v6;

unit role Music::Engine::Section;
use Music::Engine::Section::Context;

# Optional
method !setup(Music::Engine::Section::Context $context --> Music::Engine::Section::Context) { $context }

# Required
method !update(Music::Engine::Section::Context $context --> Music::Engine::Section::Context) { ... }

method !play(Music::Engine::Section::Context $context --> Music::Engine::Section::Context) { ... }
