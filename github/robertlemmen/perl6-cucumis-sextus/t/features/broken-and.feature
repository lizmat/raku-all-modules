Feature: Basic Calculator Functions
  In order to check I've written the Calculator class correctly
  As a developer I want to check some basic operations
  So that I can have confidence in my Calculator class.

  Scenario: First Key Press on the Display
# this is broken, and/or can't be the first step
    And having pressed 1
    Given a new Calculator object
    Then the display should show 1
