module SSHMuggle
  class ServerPool < Array
    alias servers entries

    def <<(object)
      raise TypeError.new 'Invalid Argument' unless object.instance_of?(Server)
      super
    end
    alias add <<
    
    def dump_keyfiles
      keys.each do |key|
        KeyfileWriter.write(key)
      end
    end

    private
      def call_for_pool(method)
        servers.map do |server|
          server.send(method)
        end.flatten.uniq
      end

      def method_missing(method, *args)
        if servers.first.respond_to?(method)
          call_for_pool(method, *args)
        else
          super
        end
      end
  end
end