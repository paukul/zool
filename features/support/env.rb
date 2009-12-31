$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../../lib'))
require 'spec'
require 'ssh_muggle'
TEST_TMP_PATH = File.expand_path(File.dirname(__FILE__) + "/../tmp")

class SSHMuggle::Server
  def initialize(host, user = 'root')
    @hostname = 'localhost'
    @user = `whoami`.chomp
    temp_server_path = TEST_TMP_PATH + "/servers/#{host}"
    @keyfile_location = temp_server_path + '/authorized_keys'
    FileUtils.mkdir_p temp_server_path unless File.directory? temp_server_path
  end
end

class SSHMuggle::KeyfileWriter
  def initialize(out_directory = 'keys')
    @out_directory = TEST_TMP_PATH + "/#{out_directory}"
    FileUtils.mkdir_p @out_directory unless File.directory? @out_directory
  end
end

Before do
  FileUtils.rm_r TEST_TMP_PATH
  @muggle = nil
  @servers = nil
end