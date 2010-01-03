module SSHMuggle
  class ServerPool < Array
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