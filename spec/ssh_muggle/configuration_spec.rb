require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module SSHMuggle
  describe Configuration do
    context ".parse" do
      context "an invalid configuration" do
        it "should raise an exception" do
          lambda { Configuration.parse('asdf') }.should raise_error(SSHMuggle::Configuration::ParseError)
        end
        
        context "pointing the reason why the configuration is invalid" do
          it "should complain about missing groups that are referenced in roles" do
            conf = <<-CONF
              [role app]
                servers = 12.3.4.5
                keys = &snafu
            CONF
            lambda { Configuration.parse(conf) }.should raise_error(SSHMuggle::Configuration::ParseError, /missing referenced group 'snafu'/)
          end
          
          it "should complain about missing keys" do
            conf = <<-CONF
              [role app]
                servers = 12.3.4.5
                keys = i_am_not_there
            CONF
            lambda { Configuration.parse(conf) }.should raise_error(SSHMuggle::Configuration::ParseError, /missing ssh key 'i_am_not_there'/)
          end
        end
      end
      
      context "a valid configuration" do
        it "should return a configuration object with the parsed configuration hash" do
          conf = <<-CONF
          [role app]
            servers = 10.52.6.1, 10.52.6.2
            keys = &qa, peter
          
          [group qa]
            members = david
          CONF
          writer = KeyfileWriter.new
          FileUtils.rm_r(writer.out_directory)
          
          writer.write 'davids key', 'david'
          writer.write 'peters key', 'peter'
          configuration = Configuration.parse(conf)
          configuration.should be_a(Configuration)
        end
      end
    end
    
    context "instanciating a configuration" do
      before :all do
        @keyfile_stub_data = {
          'peter'   => 'ssh-dsa adfsdfafef00if0i23f== peter@localhost',
          'paul'    => 'ssh-dsa adfsdfafef00if0i23f== paul@horst',
          'system'  => 'ssh-dsa adfsdfafef00if0i23f== system@admins',
          'log'     => 'ssh-dsa adfsdfafef00if0i23f== log@admins',
        }
        
        writer = KeyfileWriter.new
        FileUtils.rm_r(writer.out_directory)
        
        @keyfile_stub_data.each do |key, value|
          writer.write value, key
        end

        @conf_hash = {
          "role app" => {
            'servers' => ['preview', 'production', 'edge'],
            'keys' => ['&qa']
          },
          "role cron servers" => {
            'servers' => ['crn1', 'crn2', 'edge'],
            'keys' => ['system', 'log']
          },
          "group qa" => {
            'members' => ['peter', 'paul']
          }
        }
        @configuration = Configuration.new(@conf_hash)
      end
      
      it "should create a serverpool for every role" do
        @configuration.roles['app'].should be_a(ServerPool)
        @configuration.roles['cron servers'].should be_a(ServerPool)
      end
      
      it "should read the keys from the key files" do
        @configuration.keys.should have(4).keys
      end
      
      it "should add a groups keys to the serverpool" do
        @configuration.servers['preview'].keys.should include(@keyfile_stub_data['peter'])
      end
      
      it "should have only one server object per hostname shared between groups" do
        edges_keys = @configuration.servers['edge'].keys
        edges_keys.should include(@keyfile_stub_data['system'])
        edges_keys.should include(@keyfile_stub_data['paul'])
        edges_keys.should include(@keyfile_stub_data['peter'])
        edges_keys.should include(@keyfile_stub_data['log'])
        edges_keys.should have(4).keys
      end
      
      context "calling the upload_keys method" do
        it "should upload the keys to every server in the configuration" do
          @configuration.servers.values.each do |server|
            server.should_receive(:upload_keys).and_return(nil)
          end
          @configuration.upload_keys
        end
      end
    end
  end
end

Spec::Matchers.define :have_role do |role|
  match do |configuration|
    !configuration.roles[role].nil?
  end
end