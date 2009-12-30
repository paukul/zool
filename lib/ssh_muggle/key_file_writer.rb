module SSHMuggle
  module KeyfileWriter
    def self.dump_key_to_file(key)
      key_name = key[/\=\=\s([^@]+).*$/, 1].gsub(/[^A-Z|^a-z|^0-9]/, '_').downcase
      key_count = Dir["keys/#{key_name}*.pub"].size

      key_name += "_#{key_count + 1}" if key_count > 0
      key_path = "keys/#{key_name}.pub"
    
      File.open(key_path, 'w+') do |file|
        file.puts key
      end
    end
  end
end