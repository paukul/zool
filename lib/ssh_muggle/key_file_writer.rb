require 'ruby-debug'
Debugger.start

module SSHMuggle
  class KeyfileWriter
    attr_accessor :out_directory

    def initialize(out_directory = 'keys')
      @out_directory = out_directory
    end

    def write_keys(keys)
      keys.each do |key|
        write key
      end
    end

    def write(key, outname = nil)
      key_name = outname || begin
        temp_name = key[/^\S*\s\S*\s([^@]+)\S.*$/, 1]
        if temp_name.nil?
          debugger
        end
        temp_name.gsub(/[^A-Z|^a-z|^0-9]/, '_').downcase
      end
      key_count = Dir["#{out_directory}/#{key_name}*.pub"].size

      key_name += "_#{key_count + 1}" if key_count > 0
      key_path = "#{out_directory}/#{key_name}.pub"

      File.open(key_path, 'w+') do |file|
        file.puts key
      end
    end
  end
end