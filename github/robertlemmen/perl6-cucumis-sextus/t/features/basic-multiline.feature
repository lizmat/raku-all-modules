Feature: Basic Calculator Functions
  In order to check I've written the Calculator class correctly
  As a developer I want to check some basic operations
  So that I can have confidence in my Calculator class.

  Scenario: Ticker Tape
    Given a new Calculator object
    And having entered the following sequence
      """
      1 + 2 + 3 + 4 + 5 + 6 -
      100
      * 13 \=\=\= + 2 =
      """
    Then the display should show -1025

