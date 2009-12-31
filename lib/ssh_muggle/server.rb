require 'net/sftp'
require 'net/scp'

module SSHMuggle
  class Server
    attr_reader :hostname
    attr_accessor :keyfile_location

    def initialize(hostname, user = 'root')
      @hostname = hostname
      @user = user
      @keyfile_location = default_keyfile_location
    end

    def fetch_keys
      @keys = nil
      @raw_authorized_keys = load_remote_file
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
    key_writer = KeyfileWriter.new
    keys.each do |key|
      key_writer.write key
    end
   end
   
   def upload_keys
     begin
       backup = load_remote_file
       Net::SCP.upload!(@hostname, @user, backup, "#{@keyfile_location}_#{Time.now.to_i}")
     rescue Exception => e
       raise "Error during backup of authorized keys file: #{e.message}"
     end
     Net::SCP.upload!(@hostname, @user, keys.join("\n"), @keyfile_location)
   end

    private
      def load_remote_file
        remote_file = StringIO.new
        Net::SCP.download!(@hostname, @user, @keyfile_location, remote_file)
        remote_file.string
      end
      
      def default_keyfile_location
        '~/.ssh/authorized_keys'
      end
    end
end