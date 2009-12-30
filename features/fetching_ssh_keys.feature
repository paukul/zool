Feature: Fetching SSH Keys
  In order to see a list of all used ssh servers
  As a xing techie
  I want to be able to fetch all authorized keys from remote servers

  Scenario: Fetching all keys from a server
    Given the following keys are on the servers
      | server     | key                                        |
      | preview    | ssh-rsa key1== Adem.Deliceoglu@PC-ADELICEO |
    When I run the fetch_keys command for the server "preview"
    Then I should see the following keys
      """
      ssh-rsa key1== Adem.Deliceoglu@PC-ADELICEO
      """

  Scenario: Fetching all keys from all servers
    Given the following hosts
      """
      10.52.1.41      preview
      10.52.1.42      edge
      10.53.1.41      production
      """
    And the following keys are on the servers
      | server     | key                                                   |
      | 10.52.1.41 | ssh-rsa key1== Adem.Deliceoglu@PC-ADELICEO            |
      | 10.52.1.41 | ssh-rsa key4== abel.fernandez@nb-afernandez.local     |
      | 10.52.1.41 | ssh-dss key2== christian.kvalheim@nb-ckvalheim.local  |
      | 10.52.1.42 | ssh-rsa key3== lee.hambley@xing.com                   |
      | 10.53.1.41 | ssh-rsa key4== abel.fernandez@nb-afernandez.local     |
      | 10.53.1.41 | ssh-rsa key5== pascal.friederich@nb-pfriederich.local |
    When I run the fetch_keys command
    Then I should see the following keys
      """
      ssh-rsa key1== Adem.Deliceoglu@PC-ADELICEO           
      ssh-rsa key4== abel.fernandez@nb-afernandez.local    
      ssh-dss key2== christian.kvalheim@nb-ckvalheim.local  
      ssh-rsa key3== lee.hambley@xing.com                  
      ssh-rsa key5== pascal.friederich@nb-pfriederich.local
      """
