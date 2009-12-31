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
        @server.stub!(:load_remote_file).and_return("#{key_fixtures[:pascal]}\n#{key_fixtures[:bob]}")
        @server.keys.should == [key_fixtures[:pascal], key_fixtures[:bob]]
      end

      it "should remove unneccasarry whitespace from the output" do
        @server = Server.new('somehost')
        @server.stub!(:load_remote_file).and_return("    #{key_fixtures[:pascal]}   ")
        @server.keys.should == [key_fixtures[:pascal]]
        @server.keys.should have(1).key
      end

      it "should remove blank lines" do
        @server = Server.new('somehost')
        @server.stub!(:load_remote_file).and_return("    #{key_fixtures[:pascal]}   \n    ")
        @server.keys.should == [key_fixtures[:pascal]]
        @server.keys.should have(1).key
      end

      it "should remove duplicate keys from the list" do
        @server = Server.new('somehost')
        @server.stub!(:load_remote_file).and_return("#{key_fixtures[:pascal]}\n#{key_fixtures[:pascal]}")
        @server.keys.should have(1).key
        @server.keys.should == [key_fixtures[:pascal]]
      end
      
      context "requesting the keys several times" do
        it "should not fetch the keys again" do
          @server = Server.new('somehost')
          @server.should_receive(:load_remote_file).once.and_return("n#{key_fixtures[:pascal]}")
          @server.keys
          @server.keys
        end
      end
      
      context "fetching the keys again after they have already been fetched" do
        it "should return the new list of keys" do
          @server = Server.new('somehost')
          @server.should_receive(:load_remote_file).ordered.and_return("#{key_fixtures[:pascal]}")
          @server.should_receive(:load_remote_file).ordered.and_return("#{key_fixtures[:bob]}")
          @server.keys
          @server.keys.should == [key_fixtures[:pascal]]
          @server.fetch_keys
          @server.keys.should == [key_fixtures[:bob]]
        end
      end
    end

    context "dumping the keys to files" do
      it "should write a keyfile for every key" do
        key_fixtures.values.each do |key|
          KeyfileWriter.should_receive(:write).with(key)
        end
        @server.stub!(:load_remote_file).and_return(key_fixtures.values.join("\n"))
        @server.dump_keyfiles
      end
    end
    
    context "setting a servers keys" do
      before do
        @server = Server.new('somehost')
        @server.stub!(:load_remote_file).and_return("")
      end

      it "should take a array of keys" do
        @server.keys = [key_fixtures[:pascal], key_fixtures[:bob]]
        @server.keys.should == [key_fixtures[:pascal], key_fixtures[:bob]]
      end

      context "and uploading them" do
        before :each do
          @server.keys = [key_fixtures[:pascal], key_fixtures[:bob]]
          @backup_keys = StringIO.new('original keys')
          StringIO.stub!(:new).and_return(@backup_keys)

          Net::SCP.stub(:download!)
        end

        it "should write a authorized_keys file with all the keys" do          
          Net::SCP.should_receive(:upload!).with(any_args).ordered
          Net::SCP.should_receive(:upload!).with('somehost', 'root', @server.keys.join("\n"), '/root/.ssh/authorized_keys').ordered
          @server.upload_keys
        end

        it "should backup the existing authorized_keys file" do
          Net::SCP.should_receive(:download!)
          Net::SCP.should_receive(:upload!).with('somehost', 'root', @backup_keys.string, /authorized_keys_\d+$/).ordered
          Net::SCP.should_receive(:upload!).with(any_args).ordered
          @server.upload_keys
        end

        context "with an exception during backup of the original keys" do
          before do
            Net::SCP.stub!(:download!).and_raise(Exception)
          end

          it "should not upload the new keys" do
            Net::SCP.should_not_receive(:upload!)
            lambda { @server.upload_keys }.should raise_error
          end
        end
      end
    end
  end
end
