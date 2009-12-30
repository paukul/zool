require 'spec'
require 'ssh_muggle'

Before do
  @muggle = nil
end

After do
  cmd = "rm -rf #{File.expand_path(File.dirname(__FILE__) + '/../tmp/*')}"
  puts "Cleaning up wit: #{cmd}"
  `#{cmd}`
end