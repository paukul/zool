require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module Zool
  describe Configuration do
    before :all do
      @keyfile_stub_data = {
        'peter'   => 'ssh-dsa adfsdfafef00if0i23f== peter@localhost',
        'paul'    => 'ssh-dsa adfsdfafef00if0i23f== paul@horst',
        'system'  => 'ssh-dsa adfsdfafef00if0i23f== system@admins',
        'log'     => 'ssh-dsa adfsdfafef00if0i23f== log@admins',
      }
    end

    context "building a configuration file from a serverpool" do
      before :each do
        server1_keys = [@keyfile_stub_data['peter'], @keyfile_stub_data['paul']]
        server1 = stub(:hostname => 'server1', :keys => server1_keys)
        server2_keys = [@keyfile_stub_data['system'], @keyfile_stub_data['log']]
        server2 = stub(:hostname => 'server2', :keys => server2_keys)
        @pool = ServerPool.new([server1, server2])
      end
      
      it "should write a server entry for every server in the pool and add it's keys" do
        Configuration.build(@pool).should == <<-EXPECTED_CONF
[server server1]
  keys = peter, paul

[server server2]
  keys = system, log
        EXPECTED_CONF
      end
    end
    
    context ".parse" do
      context "an invalid configuration" do
        it "should raise an exception" do
          lambda { Configuration.parse('asdf') }.should raise_error(Zool::Configuration::ParseError)
        end
        
        context "pointing the reason why the configuration is invalid" do
          it "should complain about missing groups that are referenced in roles" do
            conf = <<-CONF
              [role app]
                servers = 12.3.4.5
                keys = &snafu
            CONF
            lambda { Configuration.parse(conf) }.should raise_error(Zool::Configuration::ParseError, /missing referenced group 'snafu'/)
          end
          
          it "should complain about missing keys" do
            conf = <<-CONF
              [role app]
                servers = 12.3.4.5
                keys = i_am_not_there
            CONF
            lambda { Configuration.parse(conf) }.should raise_error(Zool::Configuration::ParseError, /missing ssh key 'i_am_not_there'/)
          end
        end
      end
      
      context "a valid configuration" do
        it "should return a configuration object with the parsed configuration hash" do
          conf = <<-CONF
          [role app]
            servers = 13.9.6.1, 13.9.6.2
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
        writer = KeyfileWriter.new
        FileUtils.rm_r(writer.out_directory)
        
        @keyfile_stub_data.each do |key, value|
          writer.write value, key
        end

        @conf_hash = {
          "role app" => {
            'servers' => ['preview_server', 'production_server', 'edge_server'],
            'keys' => ['&qa']
          },
          "role cron servers" => {
            'servers' => ['crn1', 'crn2', 'edge_server'],
            'keys' => ['system', 'log']
          },
          "group qa" => {
            'members' => ['peter', 'paul']
          },
          "server 13.9.6.1" => {
            'keys' => ['system']
          }
        }
        @configuration = Configuration.new(@conf_hash)
      end
      
      it "should create a server for every server section" do
        @configuration.servers['13.9.6.1'].keys.should include(@keyfile_stub_data['system'])
      end
      
      it "should create a serverpool for every role" do
        @configuration.roles['app'].should be_a(ServerPool)
        @configuration.roles['cron servers'].should be_a(ServerPool)
      end
      
      it "should read the keys from the key files" do
        @configuration.keys.should have(4).keys
      end
      
      it "should add a groups keys to the serverpool" do
        @configuration.servers['preview_server'].keys.should include(@keyfile_stub_data['peter'])
      end
      
      it "should have only one server object per hostname shared between groups" do
        edge_servers_keys = @configuration.servers['edge_server'].keys
        edge_servers_keys.should include(@keyfile_stub_data['system'])
        edge_servers_keys.should include(@keyfile_stub_data['paul'])
        edge_servers_keys.should include(@keyfile_stub_data['peter'])
        edge_servers_keys.should include(@keyfile_stub_data['log'])
        edge_servers_keys.should have(4).keys
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