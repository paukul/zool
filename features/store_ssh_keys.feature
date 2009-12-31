Feature: Store ssh keys on servers
  In order to simplify uploading of keys to servers
  As a xing techie
  I want to be able to compose key lists and upload them to servers

  @fakefs
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
  
  
  
  
