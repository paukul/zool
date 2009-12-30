Feature: Managing SSH Keys
  In order to have total control over all ssh keys used
  As a xing techie
  I want to be able to manage them through sshmuggle

  Scenario: Generating a list of all used ssh keys
    Given the following hosts
      """
      10.52.1.41      ext-xelb52-1
      10.52.1.42      ext-xelb52-2
      10.53.1.41      ext-xelb53-1
      """
    And the following keys are on the servers
      | server     | key                                                   |
      | preview    | ssh-rsa key1== Adem.Deliceoglu@PC-ADELICEO            |
      | preview    | ssh-rsa key4== abel.fernandez@nb-afernandez.local     |
      | preview    | ssh-dss key2= christian.kvalheim@nb-ckvalheim.local   |
      | edge       | ssh-rsa key3== lee.hambley@xing.com                   |
      | production | ssh-rsa key4== abel.fernandez@nb-afernandez.local     |
      | production | ssh-rsa key5== pascal.friederich@nb-pfriederich.local |
    When I run the fetch command
    Then I should see the following list
      """
      ssh-rsa key1== Adem.Deliceoglu@PC-ADELICEO           
      ssh-rsa key4== abel.fernandez@nb-afernandez.local    
      ssh-dss key2= christian.kvalheim@nb-ckvalheim.local  
      ssh-rsa key3== lee.hambley@xing.com                  
      ssh-rsa key5== pascal.friederich@nb-pfriederich.local
      """
