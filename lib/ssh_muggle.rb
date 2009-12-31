$:.unshift File.dirname(__FILE__)
require File.expand_path(File.dirname(__FILE__) + '/../vendor/gems/environment')
require 'ssh_muggle/server'
require 'ssh_muggle/server_pool'
require 'ssh_muggle/key_file_writer'

module SSHMuggle  
  IP_FORMAT = /\A(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}\z/
  
  def self.parse(hostsfile)
    hosts = hostsfile.to_a.map { |host| host.split[0] }
    hosts.uniq!
    hosts.reject! { |host| host !~ IP_FORMAT }
    pool = ServerPool.new

    hosts.each do |host|
      pool << Server.new(host)
    end

    pool
  end
  
end