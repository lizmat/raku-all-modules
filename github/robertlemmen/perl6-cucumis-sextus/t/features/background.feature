Feature: Basic Calculator Functions
  In order to check I've written the Calculator class correctly
  As a developer I want to check some basic operations
  So that I can have confidence in my Calculator class.

  Background: Unboxing a new Calculator
    Given a freshly unboxed Calculator
    And having it switched on

  Scenario: First Key Press on the Display
    Given a new Calculator object
    And having pressed 1
    Then the display should show 1
  
  Scenario: Second Key Press on the Display
    Given a new Calculator object
    And having pressed 1
    And having pressed 2
    Then the display should show 12
