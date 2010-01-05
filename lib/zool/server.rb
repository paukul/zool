require 'net/sftp'
require 'net/scp'

module Zool
  class Server
    class ConnectionVerificationExecption < Exception; end
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
    key_writer.write_keys keys
   end
   
   def create_backup
     begin
       backup = load_remote_file
       backup_filename = "#{@keyfile_location}_#{Time.now.to_i}"
       Net::SCP.upload!(@hostname, @user, StringIO.new(backup), backup_filename)
       backup_filename
     rescue Net::SCP::Error => e
       logger.fatal "Error during backup of authorized keys file: #{e.message}"
       raise
     end
   end
   
   def upload_keys
     remote_backup_file = create_backup
     begin
       backup_channel = Net::SSH.start(@hostname, @user, :password => '')
       main_channel   = Net::SSH.start(@hostname, @user, :password => '')
       main_channel.scp.upload!(StringIO.new(keys.join("\n")), @keyfile_location)
       main_channel.close
       begin
         logger.info "Trying to connect to #{@hostname} to see if I still have access"
         Net::SSH.start(@hostname, @user, :password => '')
         logger.info "Backup channel connection succeeded. Assuming everything went fine!"
       rescue Net::SSH::AuthenticationFailed => e
         if !@rolled_back
           logger.warn "!!!!!! Could not login to server after upload operation! Rolling back !!!!!!"
           backup_channel.exec "mv #{remote_backup_file} #{@keyfile_location}"
           backup_channel.loop
           @rolled_back = true
           retry
         else
           logger.fatal "Tried to role back... didnt work... giving up... sorry :("
           raise e
         end
       end
     ensure
       main_channel.close unless main_channel.closed?
       backup_channel.close unless backup_channel.closed?
     end
     raise ConnectionVerificationExecption.new("Error after uploading the keyfile to #{@hostname}") if @rolled_back
   end

   def to_s
    "<Zool::Server #{hostname}>"
   end

    private
      def load_remote_file
        downloaded_file = StringIO.new
        begin
          Timeout::timeout(2) do
            logger.info "Fetching key from #{@hostname}"
            Net::SCP.download!(@hostname, @user, @keyfile_location, downloaded_file)
          end
        rescue Net::SCP::Error
          logger.warn "Warning! Empty keyfile" # logging? later... :P
        rescue Net::SSH::AuthenticationFailed
          logger.warn "No access to Server #{@hostname}"
        rescue Errno::ETIMEDOUT, Timeout::Error
          logger.warn "Access to server #{@hostname} timed out"
        end
        downloaded_file.string
      end
      
      def default_keyfile_location
        '~/.ssh/authorized_keys'
      end
      
      def logger
        DEFAULT_LOGGER
      end
  end
end