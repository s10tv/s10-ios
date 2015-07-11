Feature: Receiving Video
  In order to deliver a good experience watching video
  1) Avoid streaming so video is never stuck while playing
  2) Let user know things are happening to provide instant feedback
  3) Not interrupt current playback and recording sessions

  Scenario: Text and badge badge
    Given I have received a new video
    And video has not yet been downloaded
    When I go to the chats screen
    Then I see a progress indicator for the conversation row with pending message
    And The status for the row says "Receiving..."
    And Conversation row uncount does not show up
    When I enter the conversation
    Then conversation title view's progress indicator is active
    And title view's status says "Receiving..."
    And title view's unread count does not show up

  Scenario: Auto play after receive
    Given that I am in the conversation screen
    And I received a new video
    When the video has been downloaded
    Then I am taken to the the message cell where the video autoplays

  Scenario: Receiving while watching
    Given I am watching a video
    When I just received a new video
    Then text and badge should change on titleview
    But my playback should not be interrupted
    When playback is finished
    And the video has finished downloading
    Then I get taken to the new video which autoplays

  Scenario: Receiving while recording
    Given that I am recording a video
    When I receive a video video
    Then text and badge should change on titleview
    But my recording should not be interrupted
    When I either cancel out of recording or presses the send button
    And the video has finished downloading
    Then I get taken to the video which autoplays

  Scenario: Receive via push notification
    Given that I received a push notification
    When I tap on the notification to open the app
    Then I see the chatlist screen rather than discovery screen

  Scenario: Unread count
    Given I have recieved 2 new videos
    And both videos have been downloaded
    And no videos are currently uploading
    Then progress indicator on chats screen should be hidden
    And unread indicator should say "2"
  
