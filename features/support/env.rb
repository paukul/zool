$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../../lib'))
require 'spec'
require 'ssh_muggle'
require 'fakefs/safe'

Before do
  @muggle = nil
  @servers = nil
end

Before '@fakefs' do
  FakeFS.activate!
end

After '@fakefs' do
  FakeFS::FileSystem.clear
  FakeFS.deactivate!
end