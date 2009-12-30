require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'ruby-debug'
Debugger.start

module SSHMuggle
  describe Server do
    before do
      @server = Server.new("somehost")
    end

    context "fetching a servers keys" do
      it "should load the authorized_keys file from the server" do
        host = "somehost"
        sftp_stub = mock()
        sftp_stub.should_receive(:file).and_return(sftp_stub)
        sftp_stub.should_receive(:open).with('/root/.ssh/authorized_keys').and_yield(sftp_stub)
        sftp_stub.should_receive(:read).and_return(key_fixtures[:pascal])
        Net::SFTP.should_receive(:start).with(host, "root").and_yield(sftp_stub)

        @server = Server.new(host)
        @server.fetch_keys
      end

      it "should make the keys available through a keys array" do
        @server.stub!(:fetch_keys).and_return("#{key_fixtures[:pascal]}\n#{key_fixtures[:bob]}")
        @server.keys.should == [key_fixtures[:pascal], key_fixtures[:bob]]
      end

      it "should remove unneccasarry whitespace from the output" do
        @server = Server.new('somehost')
        @server.stub!(:fetch_keys).and_return("    #{key_fixtures[:pascal]}   ")
        @server.keys.should == [key_fixtures[:pascal]]
        @server.keys.should have(1).key
      end

      it "should remove blank lines" do
        @server = Server.new('somehost')
        @server.stub!(:fetch_keys).and_return("    #{key_fixtures[:pascal]}   \n    ")
        @server.keys.should == [key_fixtures[:pascal]]
        @server.keys.should have(1).key
      end

      it "should remove duplicate keys from the list" do
        @server = Server.new('somehost')
        @server.stub!(:fetch_keys).and_return("#{key_fixtures[:pascal]}\n#{key_fixtures[:pascal]}")
        @server.keys.should have(1).key
        @server.keys.should == [key_fixtures[:pascal]]
      end
    end

    context "dumping the keys to files" do
      it "should write a keyfile for every key" do
        key_fixtures.values.each do |key|
          KeyfileWriter.should_receive(:dump_key_to_file).with(key)
        end
        @server.stub!(:fetch_keys).and_return(key_fixtures.values.join("\n"))
        @server.dump_keyfiles
      end
    end
  end
end
