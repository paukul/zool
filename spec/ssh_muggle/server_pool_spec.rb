require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module SSHMuggle
  describe ServerPool do
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