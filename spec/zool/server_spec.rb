require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'ruby-debug'
Debugger.start

module Zool
  describe Server do
    before :each do
      @server = Server.new("somehost")
    end
    
    it "should have a getter for the user attribute" do
      @server.user.should == @server.send(:instance_variable_get, :@options)[:user]
    end
    
    context "fetching a servers keys" do
      it "should use a password if provided" do
        server = Server.new('somehost', :user => 'root', :password => 'a password')
        Net::SCP.should_receive(:download!).with(anything, anything, anything, anything, :ssh => {:password => 'a password'})
        server.keys
      end

      it "should use the default server location" do
        Server.new('somehost').keyfile_location.should          == '~/.ssh/authorized_keys'
        Server.new('somehost', :user => 'peter').keyfile_location.should == '~/.ssh/authorized_keys'
      end
      
      context "with a custom keyfile location set" do
        it "should use the custom keyfile location" do
          @server = Server.new('somehost')
          custom_keyfile_location = '/some/custom/path'
          @server.keyfile_location = custom_keyfile_location
          Net::SCP.should_receive(:download!).with(anything, anything, custom_keyfile_location, anything, anything)

          @server.fetch_keys          
        end
      end
      
      context "when the keyfile is not presetn" do
        it "should return an empty list of keys" do
          Net::SCP.should_receive(:download!).and_raise(Net::SCP::Error)
          @server.keys.should be_empty
        end
      end

      it "should load the authorized_keys file from the server" do
        @server = Server.new('somehost')
        Net::SCP.should_receive(:download!).with(anything, anything, @server.keyfile_location, anything, anything)

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
        FileUtils.rm_r 'keys' # cleanup old keyfiles
        @server.stub!(:load_remote_file).and_return(key_fixtures.values.join("\n"))
        @server.dump_keyfiles
        Dir['keys/*'].should have(key_fixtures.size).keys
      end
    end
    
    context "setting a servers keys" do
      before :each do
        @server = Server.new('somehost')
        @server.stub!(:load_remote_file).and_return("")
      end

      context "by replacing all of them" do
        it "should take a array of keys" do
          @server.keys = [key_fixtures[:pascal], key_fixtures[:bob]]
          @server.keys.should == [key_fixtures[:pascal], key_fixtures[:bob]]
        end

        it "should not fetch the servers existing keys" do
          @server.should_not_receive(:load_remote_file)
          @server.keys = [key_fixtures[:pascal]]
        end
      end

      context "by adding keys to the existing keys" do
        it "should fetch the servers current keys if not done before" do
          @server.should_receive(:load_remote_file)
          @server.keys << "asdf"
        end        
      end

      context "and uploading them" do
        before :each do
          @server.keys = [key_fixtures[:pascal], key_fixtures[:bob]]
          @backup_keys = 'original keys'
          @server.stub!(:load_remote_file).and_return(@backup_keys)

          Net::SCP.stub(:download!)
        end

        it "should write a authorized_keys file with all the keys" do          
          channel_stub = stub('ssh channel stub', :null_object => true)
          Net::SSH.stub!(:start).and_return(channel_stub)
          Net::SCP.stub!(:upload!) # the backup
          channel_stub.stub(:scp).and_return(channel_stub)

          channel_stub.should_receive(:upload!).with(stringbuffer_with(@server.keys.join("\n")), @server.keyfile_location).ordered
          @server.upload_keys
        end

        it "should backup the existing authorized_keys file" do
          @server.should_receive(:load_remote_file).and_return(@backup_keys)
          Net::SSH.stub!(:start).and_return(stub('ssh channel stub', :null_object => true))
          
          Net::SCP.should_receive(:upload!).with('somehost', 'root', stringbuffer_with(@backup_keys), /authorized_keys_\d+$/, anything)
          @server.upload_keys
        end

        context "with an exception during backup of the original keys" do
          before :each do
            Net::SCP.stub!(:download!).and_raise(Exception)
          end

          it "should not upload the new keys" do
            Net::SCP.should_not_receive(:upload!)
            lambda { @server.upload_keys }.should raise_error
          end
        end
        
        context "providing a fallback if something goes wrong" do
          
        end
      end
    end
  end
end
