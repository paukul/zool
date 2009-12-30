$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../../lib'))
require 'spec'
require 'ssh_muggle'

Before do
  @muggle = nil
  @servers = nil
end
