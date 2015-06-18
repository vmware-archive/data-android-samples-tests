Feature: Running a sample app
  As an Android developer
  I want to have a sample app
  So I can begin developing quickly

Scenario: Fetching for the first time
  Given I am on the Welcome Screen
  Then I press the "Fetch Object" button
  And I wait for "Password Flow" to appear
  And I press the "Password Flow" button
  Then I clear input field number 1
  Then I enter my username into input field number 1
  Then I clear input field number 2
  Then I enter my password into input field number 2
  And I press the "Submit" button
  # And I wait for "ERROR: Not Found" to appear 
  Then take picture

Scenario: Save, Fetch, Delete with a token already retrieved
  Given I am on the Welcome Screen
  Then I enter "some testing string" into input field number 1
  Then I go back
  Then I press the "Save Object" button
  Then I clear input field number 1
  Then I press the "Fetch Object" button
  Then I go back
  And I wait for "some testing string" to appear
  Then I press the "Delete Object" button
  Then I press the "Fetch Object" button
  # And I wait for "ERROR: Not Found" to appear
  Then take picture

Scenario: Logout button
  Given I am on the Welcome Screen
  Then I press the menu key
  Then I touch the "Logout" text
  Then I press the "Fetch Object" button
  And I wait for "Password Flow" to appear
  Then take picture
