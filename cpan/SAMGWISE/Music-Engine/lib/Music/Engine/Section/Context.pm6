use v6;

unit role Music::Engine::Section::Context;
  use ScaleVec::Scale;
  has Int   $.phrase-step;
  has       &.send-note;
  has ScaleVec::Scale $.output-space;
  has       %.stash;
