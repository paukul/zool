$:.unshift File.dirname(__FILE__)

require 'rubygems'
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
