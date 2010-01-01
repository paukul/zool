module SSHMuggle
  class ServerPool < Array
    alias servers entries
    DELEGATE_METHODS = %w(keys fetch_keys)

    DELEGATE_METHODS.each do |delegate_method|
      define_method delegate_method do
        call_for_pool(delegate_method)
      end
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
end