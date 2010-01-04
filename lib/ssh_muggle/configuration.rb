module SSHMuggle
  class Configuration
    class ParseError < Exception; end
    attr_reader :servers, :roles, :groups

    def self.parse(configuration)
      parser = PyConfigParser.new
      if raw_config = parser.parse(configuration)
        self.new(raw_config.build)
      else
        raise ParseError.new(parser.failure_reason)
      end
    end

    def initialize(raw_config)
      @raw_config = raw_config
      parse
    end

    def keys
      @keys ||= read_keys
    end

    def upload_keys
      @servers.each { |servername, server| server.upload_keys }
    end

    private
      def parse
        @roles = {}
        @servers = {}
        @groups = {}

        parse_groups
        parse_roles
      end

      def parse_groups
        raw_groups.each do |raw_group|
          @groups[raw_group[/^group\s(.*)/, 1]] = @raw_config[raw_group]['members']
        end
      end

      def raw_groups
        @raw_config.select {|k, v| k =~ /^group/}.map {|role_arrey| role_arrey[0]}
      end

      def parse_roles
        raw_roles.each do |raw_role|
          @roles[raw_role[/^role\s(.*)/, 1]] = server_pool(raw_role)
        end
      end

      def raw_roles
        @raw_config.select {|k, v| k =~ /^role/}.map {|role_arrey| role_arrey[0]}
      end

      def server(hostname)
        return @servers[hostname] if @servers[hostname]
        new_server = Server.new(hostname)
        new_server.keys = []
        @servers[hostname] = new_server
        new_server
      end

      def read_keys
        hash = {}
        key_directory = KeyfileWriter.new.out_directory # FIXME: terrible and lazy hack!
        keyfiles = Dir["#{key_directory}/*.pub"]
        keyfiles.each do |keyfile|
          keyname = File.basename(keyfile)[/(.*)\.pub/, 1]
          hash[keyname] = File.read(keyfile).chomp
        end
        hash
      end

      def server_pool(raw_role)
        pool = ServerPool.new()

        @raw_config[raw_role]['servers'].each do |hostname|
          pool << server(hostname)
        end

        @raw_config[raw_role]['keys'].each do |key|
          if key =~ /^&/
            @groups[key[1..-1]].each do |gkey|
              pool.keys << keys[gkey]
            end
          else
            pool.keys << keys[key]
          end
        end

        pool
      end
  end
end