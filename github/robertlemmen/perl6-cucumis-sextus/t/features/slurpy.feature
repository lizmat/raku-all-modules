Feature: Basic Calculator Functions
  In order to check I've written the Calculator class correctly
  As a developer I want to check some basic operations
  So that I can have confidence in my Calculator class.

  Scenario: Add as you go
    Given a new Calculator object
    And having pressed 1 and 2 and 3 and + and 4 and 5 and 6 and +
    Then the display should show 579

