require 'net/sftp'

module SSHMuggle
  class Server
    attr_reader :hostname

    def initialize(hostname, user = "root")
      @hostname = hostname
      @user = user
    end
    
    def fetch_keys
      @authorized_keys = load_remote_file('/root/.ssh/authorized_keys')
    end
   
   def keys
    @authorized_keys ||= fetch_keys
    @authorized_keys.split("\n").map {|key| key.strip}.uniq.reject {|key| key == ""}
   end

   def dump_keyfiles
    keys.each do |key|
      keyname = key[/\=\=\s(.*)$/, 1].gsub(/[^A-Z|^a-z|^@]/, '_')
      File.open("keys/#{keyname.downcase}.pub", 'w+') do |file|
        file.puts key
      end
    end
   end

    private
      def load_remote_file(path)
        Net::SFTP.start(@hostname, 'root') do |sftp|
          sftp.file.open(path) do |f|
            return f.read
          end
        end
      end
  end
end