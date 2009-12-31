require 'net/sftp'

module SSHMuggle
  class Server
    attr_reader :hostname

    def initialize(hostname, user = "root")
      @hostname = hostname
      @user = user
    end

    def fetch_keys
      @keys = nil
      @raw_authorized_keys = load_remote_file('/root/.ssh/authorized_keys')
    end

   def keys
    @keys ||= begin
      @raw_authorized_keys ||= fetch_keys
      @raw_authorized_keys.split("\n").map {|key| key.strip}.uniq.reject {|key| key == ""}
    end
   end

   def keys=(new_keys)
    @keys = new_keys
   end

   def dump_keyfiles
    keys.each do |key|
      KeyfileWriter.write key
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