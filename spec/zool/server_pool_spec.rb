require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module Zool
  describe ServerPool do
    context "parsing from a hosts file" do
      context "with a user argument and/or password" do
        before :each do
          hostsfile = <<-HOSTS
          12.21.4.1 servername
          HOSTS
          @server = ServerPool.from_hostfile(hostsfile, :user => 'peter', :password => 'peters1234').servers.first
        end
        
        it "should pass the user argument to the servers" do
          @server.user.should == 'peter'
        end
        
        it "should pass the password argument to the servers" do
          @server.send(:instance_variable_get, :@options)[:password].should == 'peters1234'
        end
      end

      context "when given a String" do
        it "should return a Serverpool object with the servers from the hosts file" do
          hostsfile = StringIO.new <<-HOSTS
            12.21.4.1       servername
            12.21.4.2       servername2
            12.21.4.3       servername3
            12.21.4.4       servername4
          HOSTS
          pool = ServerPool.from_hostfile(hostsfile)
          pool.servers.map {|server| server.hostname }.should == ['12.21.4.1', '12.21.4.2', '12.21.4.3', '12.21.4.4']
        end

        it "should remove duplicates from the list of servers" do
          hostsfile = StringIO.new <<-HOSTS
            12.21.4.1       servername1
            12.21.4.2       servername2
            12.21.4.2       fancy_alias
          HOSTS
          pool = ServerPool.from_hostfile(hostsfile)
          pool.servers.map {|server| server.hostname }.should == ['12.21.4.1', '12.21.4.2']
        end
        
        it "should remove localhost and networks from the list of servers" do
          hostfile = StringIO.new <<-HOSTS
            12.34.45.56     validserver
            localhost       localhost
            127.0.0.1       localhost
            255.255.255.255 network
            ::1             localhost
          HOSTS
          pool = ServerPool.from_hostfile(hostfile)
          pool.servers.map {|server| server.hostname }.should == ['12.34.45.56']
        end

        it "should ignore malformed lines" do
          hostsfile = StringIO.new <<-HOSTS
            # asdfasdfasdf  comment
            19023912u0194h  odd_line
            12.21.4.1       servername1

            10.257.2.1      invalid_ip
            12.21.4.2       servername2
            myhost.de
          HOSTS
          pool = ServerPool.from_hostfile(hostsfile)
          pool.servers.map {|server| server.hostname }.should == ['12.21.4.1', '12.21.4.2', 'myhost.de']
        end
      end
    end
    before :each do
      @pool = ServerPool.new
    end

    it "should only take Server objects" do
      lambda { @pool << Object.new }.should raise_error TypeError
      lambda { @pool.add Object.new }.should raise_error TypeError
    end

    it "should delegate methods to the server objects" do
      server = mock('server')
      server.should_receive(:keys)
      server.should_receive(:fetch_keys)
      server.should_receive(:upload_keys)
      @pool.push server

      @pool.keys
      @pool.fetch_keys
      @pool.upload_keys
    end

    context "delegating methods to the servers" do
      it "should aggregated values as an hash" do
        server1 = stub
        server1_keys = ['first key', 'second key']
        server1.stub!(:keys).and_return(server1_keys)

        server2 = stub
        server2_keys = ['third key', 'forth key']
        server2.stub!(:keys).and_return(server2_keys)

        @pool.push server1
        @pool.push server2

        @pool.keys.should == server1_keys + server2_keys
      end      
    end

    context "dumping the servers keys to files" do
      it "should write a keyfile for every key" do
        FileUtils.rm_r 'keys' # cleanup old keyfiles
        @pool.stub!(:keys).and_return(key_fixtures.values.join("\n"))
        @pool.dump_keyfiles
        Dir['keys/*'].should have(key_fixtures.size).keys
      end
    end

    context "adding a key to the serverpool" do
      it "should add the key to every server in the pool" do
        new_key = 'a key'
        keys = mock('keys')
        server1 = mock('server1', :keys => keys)
        server2 = mock('server2', :keys => keys)
        @pool.push server1
        @pool.push server2

        keys.should_receive(:<<).twice.with(new_key)        
        @pool.keys << new_key
      end
    end
  end
end