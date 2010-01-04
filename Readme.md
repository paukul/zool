SSH Muggle
=================
ok, i'll rethink the name, but anyway, here is what it is:

ssh_muggle is a library to manage authorized_keys files on a set of n servers.
It comes with a command-line client named muggle which gives you access to the common tasks.

When muggle creates a authorized_keys file on a server, it always creates a backup of the existing one (it uses `authorized_keys_timestamp` as the backups filename).

The command-line client
-----------------------

the command-line client currently supports 2 commands:

* fetch<br>
  fetches the authorized_keys files from every known host in the /etc/hosts file (that is configurable later, sure ;)), splits them up, removes duplicates and saves them to a .pub file in the keys (configurable... later...) directory.
  It tries to generate the name of the keyfile by parsing the key for a someuser@somehost value at the end of the key. It only uses the someuser value to generate the keyfile name. That may become configurable later
* setup<br>
  this task creates the keys directory, fetches the keys and naively creates a simple version of a muggle.conf. That will experience some overhaul for sure because it is only capable to create server directives for every server and isn't smart enough to group keys.
* apply<br>
  reads the muggle.conf and distributes the keys to the servers specified in the configuration file. <br>
  *This command isn't implemented in the client yet but in the libraries -- will come soon!*

The muggle.conf
---------------

The muggle.conf describes which keys should be deployed to which servers. It supports group, role and server directives.

    [group devs]
      members = peter, paul, danny
    
    [group sysadmins]
      members = tony, frank
    
    [role app]
      servers = 10.12.11.1, 10.12.11.2
      keys = &devs, tony
    
    [server 10.11.1.4]
      keys = &sysadmins

The members are specified as the name of the keyfile containing the key, without the succeeding .pub extension.
A _group_ groups several keys, a _role_ groups several _servers_. A server, well, is a single server. (*Note*: you can have servers in several groups and even in an additional server directive at once)
Roles and servers can have multiple _keys_. The keys can be supplied like in the _group_ directive or if you want to reference to a groups keys, by prepending a _&_ (if you would want to reference the group _devs_ you would use _&devs_).

Running the tests
=================

To run the cucumber features you need to have an ssh server running on your machine and your own public key in your authorized_keys file.
The tests use your authorized_keys file only to login to _localhost_ and fake authorized_keys and key files for testing.