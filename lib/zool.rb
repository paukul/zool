$:.unshift File.dirname(__FILE__)
begin
  require File.expand_path(File.dirname(__FILE__) + '/../vendor/gems/environment')
rescue LoadError
  # seems to be the gem version
end

require 'treetop'
require 'py_config_parser/py_config_parser'
require 'zool/server'
require 'zool/server_pool'
require 'zool/key_file_writer'
require 'zool/configuration'

module Zool  
  DEFAULT_LOGGER = begin
    if defined?(Spec)
      # we are in test environment
      Logger.new('test.log')
    else
      Logger.new('zool.log')
    end
  end
end