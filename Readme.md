Zool
=================
zool (which is named after Zuul, "The Gatekeeper", from the movie [Ghostbusters](http://en.wikipedia.org/wiki/Ghostbusters)) is a gem to manage authorized_keys files on a set of n servers.
It comes with a command-line client named zool which gives you access to the common tasks.

The command-line client
-----------------------

the command-line client currently supports 3 commands:

* __fetch__<br>
  fetches the authorized_keys files from a file (defaults to /etc/hosts) or a list of hosts (see zool -h for more info), splits them up, removes duplicates and saves them to a .pub file in the keys (will be configurable... later...) directory.
  It tries to generate the name of the keyfile by parsing the key for a someuser@somehost value at the end of the key. It only uses the someuser value to generate the keyfile name. That may become configurable later
  You can specify a user / password for the fetch and setup tasks. See zool -h for details.
* __setup__<br>
  this task creates the keys directory, fetches the keys and naively creates a simple version of a zool.conf. That will experience some overhaul for sure because it is only capable to create server directives for every server and isn't smart enough to group keys.
  You can specify a user / password for the fetch and setup tasks. See zool -h for details.
* __apply__<br>
  reads the zool.conf and distributes the keys to the servers specified in the configuration file. <br>

The zool.conf
---------------

The zool.conf describes which keys should be deployed to which servers. It supports group, role and server directives.

    [group devs]
      members = peter, paul, danny
    
    [group sysadmins]
      members = tony, frank
    
    [role app]
      servers = 10.12.11.1, 10.12.11.2
      keys = &devs, tony
      user : my_deploy_user
      password : mypassword

    [server 10.11.1.4]
      keys = &sysadmins
      user = adminuser

The members are specified as the name of the keyfile containing the key, without the succeeding .pub extension.
A _group_ groups several keys, a _role_ groups several _servers_. A server, well, is a single server. (__Note__: you can have servers in several groups and even in an additional server directive at once)
Roles and servers can have multiple _keys_. The keys can be supplied like in the _group_ directive or if you want to reference to a groups keys, by prepending a _&_ (if you would want to reference the group _devs_ you would use _&devs_).
You can optionally specify the user/password to use to connect to servers/roles. If those values aren't configured, it defaults to root for the user and an empty password/tries to authenticate with the current users ssh key.

__NOTE__
Currently the first appearance of a server in the key file sets its user/password. So it is not possible to have multiple key configurations with a different user for a single server. That might change soon!

Security?
----------
When zool creates a authorized_keys file on a server, it always creates a backup of the existing one (it uses `authorized_keys_timestamp` as the backups filename).
It also opens a backup connection to the server before uploading the keyfiles and tries to open another one after uploading them. If it fails to open another conncetion it uses the backup connection to restore the original keyfile.
See how it looks like if that happens:

*In the logfile*

    INFO -- : Fetching key from 13.11.2.200
    INFO -- : Trying to connect to 13.11.2.200 to see if I still have access
    WARN -- : !!!!!! Could not login to server after upload operation! Rolling back !!!!!!
    INFO -- : Trying to connect to 13.11.2.200 to see if I still have access
    INFO -- : Backup channel connection succeeded. Assuming everything went fine!

*At the command-line*
    
    NOW pray to the gods... 
    Going to deploy to 13.11.2.200
    Uploading...   [FAIL]
    Could not connect to a Server after updating the authorized_keys file. Tried to roll back!
    Error after uploading the keyfile to 13.11.2.200

Known issues
------------

__Bugs / Issues__

* numbering of "similar" keys is only done when generating the key files. when writing the config files it uses the unnumbered version all the time
* tests on the fallback mechanism are not present 

__Feature Todos__

* generating the config from a serverpool / hostfile is pretty dump at the moment. is doesn't use the groups and roles directives, instead stupidly adds server directives with the appropriate keys. That could be made smarter...
* if keys are in subfolders, the subfolders could automatically act as usable groups, with the folder name as reference

Developing
==========

Bundler
-------

To get a working development/testing setup you can use bundler to fetch all the dependencies. Just `gem install bundler` and `gem bundle` in the checkout directory afterwards. Be sure to use the executables (rake, cucumber, ...) from the bundler_bin directory instead your regular versions.

Running the tests
-----------------

To run the cucumber features you need to have an ssh server running on your machine and your own public key in your authorized_keys file.
The tests use your authorized_keys file only to login to _localhost_ and fake authorized_keys and key files for testing.

Copyright
---------
Copyright (c) 2010 Pascal Friederich. See LICENSE for details.