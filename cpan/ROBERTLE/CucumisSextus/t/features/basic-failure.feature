Feature: Basic Calculator Functions
  In order to check I've written the Calculator class correctly
  As a developer I want to check some basic operations
  So that I can have confidence in my Calculator class.

  Scenario: First Key Press on the Display
    Given a new Calculator object
    And having pressed 1
    Then the display should show 1

  Scenario: Several Key Presses on the Display
    Given a new Calculator object
    And having pressed 1 and 2 and 3 and . and 5 and 0
    Then the display should be off

  Scenario: Pressing Clear Wipes the Display
    Given a new Calculator object
    And having pressed 1 and 2 and 3
    And having pressed C
    Then the display should show 0

