use NASA::MarsRovers::Rover;
unit role NASA::MarsRovers;

has Str $.key;

method curiosity   { NASA::MarsRovers::Rover.new: :$!key, :name<curiosity>;   }
method spirit      { NASA::MarsRovers::Rover.new: :$!key, :name<spirit>;      }
method opportunity { NASA::MarsRovers::Rover.new: :$!key, :name<opportunity>; }
