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
      ServerPool::DELEGATE_METHODS.each do |method|
        @pool.should respond_to(method)
      end
    end

    context "delegating methods to the servers" do
      it "should aggregated values as an hash" do
        server1 = stub
        server1_keys = ['first key', 'second key']
        server1.stub!(:hostname).and_return('server1')
        server1.stub!(:keys).and_return(server1_keys)

        server2 = stub
        server2_keys = ['third key', 'forth key']
        server2.stub!(:hostname).and_return('server2')
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
    
  end
end