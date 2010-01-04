$:.unshift File.dirname(__FILE__)
require File.expand_path(File.dirname(__FILE__) + '/../vendor/gems/environment')
require 'treetop'
require 'py_config_parser/py_config_parser'
require 'ssh_muggle/server'
require 'ssh_muggle/server_pool'
require 'ssh_muggle/key_file_writer'
require 'ssh_muggle/configuration'

module SSHMuggle  
  DEFAULT_LOGGER = begin
    if defined?(Spec)
      # we are in test environment
      Logger.new('test.log')
    else
      Logger.new('muggle.log')
    end
  end
end