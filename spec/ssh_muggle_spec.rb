require File.dirname(__FILE__) + '/spec_helper'

describe SSHMuggle do
  context "#parse" do
    context "when given a String" do
      it "should return a Serverpool object with the servers from the hosts file" do
        hostsfile = StringIO.new <<-HOSTS
          12.21.4.1       servername
          12.21.4.2       servername2
          12.21.4.3       servername3
          12.21.4.4       servername4
        HOSTS
        pool = SSHMuggle.parse(hostsfile)
        pool.servers.map {|server| server.hostname }.should == ['12.21.4.1', '12.21.4.2', '12.21.4.3', '12.21.4.4']
      end
      
      it "should remove duplicates from the list of servers" do
        hostsfile = StringIO.new <<-HOSTS
          12.21.4.1       servername1
          12.21.4.2       servername2
          12.21.4.2       fancy_alias
        HOSTS
        pool = SSHMuggle.parse(hostsfile)
        pool.servers.map {|server| server.hostname }.should == ['12.21.4.1', '12.21.4.2']
      end
      
      it "should ignore malformed lines" do
        hostsfile = StringIO.new <<-HOSTS
          # asdfasdfasdf  comment
          19023912u0194h  odd_line
          12.21.4.1       servername1
          
          10.257.2.1      invalid_ip
          12.21.4.2       servername2
        HOSTS
        pool = SSHMuggle.parse(hostsfile)
        pool.servers.map {|server| server.hostname }.should == ['12.21.4.1', '12.21.4.2']
      end
    end
  end
end