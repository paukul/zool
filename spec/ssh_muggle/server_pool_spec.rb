require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module SSHMuggle
  describe ServerPool do
    it "should only take Server objects" do
      pool = ServerPool.new
      lambda { pool << Object.new }.should raise_error TypeError
      lambda { pool.add Object.new }.should raise_error TypeError
    end
    
    it "should delegate unknown methods to the server objects and return the aggregated values as an hash" do
      pool = ServerPool.new
      server1 = stub
      server1_keys = ['first key', 'second key']
      server1.stub!(:hostname).and_return('server1')
      server1.stub!(:keys).and_return(server1_keys)
      
      server2 = stub
      server2_keys = ['third key', 'forth key']
      server2.stub!(:hostname).and_return('server2')
      server2.stub!(:keys).and_return(server2_keys)
      
      pool.push server1
      pool.push server2
      
      pool.keys.should == server1_keys + server2_keys
    end
  end
end