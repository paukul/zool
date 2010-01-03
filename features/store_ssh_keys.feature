Feature: Store ssh keys on servers
  In order to simplify uploading of keys to servers
  As a xing techie
  I want to be able to compose key lists and upload them to servers

  Scenario: uploading keys to a server
    Given the server "preview" without a key file
    When I upload the keys to the server "preview"                                      
        | key                                                   |
        | ssh-rsa key1== Adem.Deliceoglu@PC-ADELICEO            |
        | ssh-rsa key4== abel.fernandez@nb-afernandez.local     |
        | ssh-dss key2== christian.kvalheim@nb-ckvalheim.local  |
        | ssh-rsa key3== lee.hambley@xing.com                   |
        | ssh-rsa key5== pascal.friederich@nb-pfriederich.local |

    Then the server "preview" should have the authorized_keys file with the content
      """
      ssh-rsa key1== Adem.Deliceoglu@PC-ADELICEO
      ssh-rsa key4== abel.fernandez@nb-afernandez.local
      ssh-dss key2== christian.kvalheim@nb-ckvalheim.local
      ssh-rsa key3== lee.hambley@xing.com
      ssh-rsa key5== pascal.friederich@nb-pfriederich.local
      """
  
  Scenario: adding a single key to a servers keyfile
    Given the server "10.52.1.41" 
    And the following keys are on the servers
      | server     | key                                                   |
      | 10.52.1.41 | ssh-rsa key1== Adem.Deliceoglu@PC-ADELICEO            |
      | 10.52.1.41 | ssh-dss key2== christian.kvalheim@nb-ckvalheim.local  |    
    When I add the key "ssh-rsa key4== abel.fernandez@nb-afernandez.local"
    And I run the upload_keys command
    Then the server "10.52.1.41" should have the authorized_keys file with the content
      """
      ssh-rsa key1== Adem.Deliceoglu@PC-ADELICEO
      ssh-dss key2== christian.kvalheim@nb-ckvalheim.local
      ssh-rsa key4== abel.fernandez@nb-afernandez.local
      """
  
  Scenario: adding a single key to a serverpools keyfiles
    Given the following hosts
      """
        10.52.1.41      preview
        10.52.1.42      edge
      """
    And the following keys are on the servers
      | server     | key                                   |
      | 10.52.1.41 | ssh-rsa key1== some.key@somehost      |
      | 10.52.1.41 | ssh-rsa key4== anotherkey@ahost.local |
      | 10.52.1.41 | ssh-dss key2== thiskey@thishost.local |
      | 10.52.1.42 | ssh-rsa key3== snafu@bar.com          |
    When I add the key "ssh-rsa key5== additionalkey@host"
    And I run the upload_keys command
    Then the following keys should be on the servers
      | server     | key                                   |
      | 10.52.1.41 | ssh-rsa key1== some.key@somehost      |
      | 10.52.1.41 | ssh-rsa key4== anotherkey@ahost.local |
      | 10.52.1.41 | ssh-dss key2== thiskey@thishost.local |
      | 10.52.1.41 | ssh-rsa key5== additionalkey@host     |
      | 10.52.1.42 | ssh-rsa key3== snafu@bar.com          |
      | 10.52.1.42 | ssh-rsa key5== additionalkey@host     |
    