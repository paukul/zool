require 'fileutils'
require 'ruby-debug'
Debugger.start

Given /^the following hosts$/ do |string|
  hosts = StringIO.new(string)
  @muggle = SSHMuggle::parse hosts
end

Given /^the following keys are on the servers$/ do |table|
  servers = {}
  table.hashes.each do |values|
    servers[values["server"]] ||= []
    servers[values["server"]] << values["key"]
  end
  
  puts "Servers: " + servers.inspect
    
  servers.each do |server, keys|
    tmp_ssh_file = File.open(temp_server_ssh_path(server) + "/authorized_keys", 'w+')
    tmp_ssh_file.puts keys.join("\n")
    tmp_ssh_file.close
  end
end

When /^I run the fetch command$/ do
  @muggle.fetch
end

Then /^I should see the following list$/ do |string|
  pending # express the regexp above with the code you wish you had
end

def temp_server_ssh_path(server)
  path = File.expand_path(File.dirname(__FILE__) + "/../tmp/#{server}/")
  return path if File.directory?(path)
  FileUtils.mkdir_p path
  path
end