require 'fileutils'
require 'ruby-debug'
Debugger.start

#########
# GIVEN
#########

Given /^the following hosts$/ do |string|
  hosts = StringIO.new(string)
  @muggle = SSHMuggle::parse hosts
end

Given /^the following keys are on the servers$/ do |table|
  @keys = {}
  table.hashes.each do |values|
    @keys[values["server"]] ||= []
    @keys[values["server"]] << values["key"]
  end
end

Given /^the following keys have been fetched$/ do |table|
  @muggle = SSHMuggle::Server.new("somehost")
  @keys = {}
  @keys["somehost"] = table.rows.flatten
end

#########
# WHEN
#########

When /^I run the fetch_keys command for the server "([^\"]*)"$/ do |hostname|
  @muggle = SSHMuggle::Server.new(hostname)
  mock_fetch_keys_for(@muggle)
  @muggle.fetch_keys
end

When /^I run the (.*) command$/ do |command|
  mock_fetch_keys_for(@muggle)
  @muggle.send(command)
end

#########
# THEN
#########

Then /^It should fetch the following keys$/ do |string|
  expected_keys = string.split("\n").map { |key| key.strip }
  actual_keys = @muggle.keys
  expected_keys.reject! {|key| actual_keys.flatten.member?(key.strip) }
  expected_keys.should == []
end

Then /^It should generate the following files$/ do |keyfiles|
  actual_keyfiles = [['name', 'key']]
  Dir['keys/*.pub'].map {|path| path.split('/').last }.each do |keyfile|
    File.open("keys/#{keyfile}") do |file|
      actual_keyfiles << [keyfile.strip, file.read.strip]
    end
  end

  keyfiles.diff!(actual_keyfiles)
end

#########
# HELPER
#########
def temp_server_ssh_path(server)
  path = File.expand_path(File.dirname(__FILE__) + "/../tmp/#{server}/")
  return path if File.directory?(path)
  FileUtils.mkdir_p path
  path
end

def mock_fetch_keys_for(server)
  if @muggle.instance_of?(SSHMuggle::ServerPool)
    @muggle.servers.each do |server|
      redefine_load_remote_file(server)
    end
  else
    redefine_load_remote_file(@muggle)
  end
end

def redefine_load_remote_file(server)
  server.instance_eval <<-EVAL
    def load_remote_file(path)
      '#{@keys[server.hostname].sort.join("\n")}'
    end
  EVAL
end