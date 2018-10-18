unit role Dice::Roller::Rollable;

# Role for Rolling - so you can Roll while you Role.
# i.e. an "Abstract interface" for all rollable Dice::Roller objects.

# For the Role to help out with the tedious stuff, classes should implement something
# that returns all of its Rollable sub-objects. That way the default implementations
# of these methods will Just Work.
method contents returns Array[Dice::Roller::Rollable] { ... }

# Roll any dice contained in this Rollable, setting them to new random values.
method roll {
	self.contents».roll;
	return self;
}

# Set any dice to their maximum value.
method set-max {
	self.contents».set-max;
	return self;
}

# Set any dice to their minimum value.
method set-min {
	self.contents».set-min;
	return self;
}

# Is this Rollable (and all its components) showing the highest possible value?
method is-max returns Bool {
	return self.contents.all.is-max.Bool;
}

# Is this Rollable (and all its components) showing the lowest possible value?
method is-min returns Bool {
	return self.contents.all.is-min.Bool;
}

# If you had to put a number on it, what is this Rollable's total value?
method total returns Int {
	return [+] self.contents».total;
}

