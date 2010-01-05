module Zool
  class ServerPool < Array
    IP_FORMAT = /\A(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}\z/

    def self.from_hostfile(hostsfile)
      hosts = hostsfile.to_a.map { |host| host.split[0] }
      hosts.uniq!
      invalid_hosts = %w(127.0.0.1 255.255.255.255)
      hosts.reject! { |host| host !~ IP_FORMAT }
      hosts.reject! { |host| invalid_hosts.include?(host) }
      pool = self.new

      hosts.each do |host|
        # puts host
        server = Server.new(host)
        # puts server.hostname
        pool << server
      end
      pool
    end

    alias servers entries

    def keys
      @keys_proxy ||= KeysProxy.new(self)
    end

    def fetch_keys
      call_for_pool(:fetch_keys)
      @keys_proxy = nil
    end

    def upload_keys
      call_for_pool(:upload_keys)
    end

    def <<(object)
      raise TypeError.new 'Invalid Argument' unless object.instance_of?(Server)
      super
    end
    alias add <<
    
    def dump_keyfiles
      writer = KeyfileWriter.new
      keys.each do |key|
        writer.write(key)
      end
    end
    
    def inspect
      "#<Zool::ServerPool @servers=[#{servers.join(', ')}]>"
    end

    private
      def call_for_pool(method)
        servers.map do |server|
          server.send(method)
        end.flatten.uniq
      end
  end
  
  class KeysProxy < Array
    def initialize(pool)
      @pool = pool
      super @pool.send(:call_for_pool, :keys)
    end
    
    def <<(key)
      @pool.each do |server|
        server.keys << key
      end
    end
  end
end