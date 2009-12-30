require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'ruby-debug'
Debugger.start

module SSHMuggle
  describe Server do
    context "fetch_keysing a servers keys" do
      it "should load the authorized_keys file from the server" do
        host = "somehost"
        sftp_stub = mock()
        sftp_stub.should_receive(:file).and_return(sftp_stub)
        sftp_stub.should_receive(:open).with('/root/.ssh/authorized_keys').and_yield(sftp_stub)
        sftp_stub.should_receive(:read).and_return(key_fixtures[:pascal])
        Net::SFTP.should_receive(:start).with(host, "root").and_yield(sftp_stub)

        server = Server.new(host)
        server.fetch_keys
      end
      
      it "should make the keys available through a keys array" do
        server = Server.new("host")
        server.stub!(:fetch_keys).and_return("#{key_fixtures[:pascal]}\n#{key_fixtures[:bob]}")
        server.keys.should == [key_fixtures[:pascal], key_fixtures[:bob]]
      end
      
      it "should remove unneccasarry whitespace from the output" do
        server = Server.new('somehost')
        server.stub!(:fetch_keys).and_return("    #{key_fixtures[:pascal]}   ")
        server.keys.should == [key_fixtures[:pascal]]
        server.keys.should have(1).key
      end
      
      it "should remove blank lines" do
        server = Server.new('somehost')
        server.stub!(:fetch_keys).and_return("    #{key_fixtures[:pascal]}   \n    ")
        server.keys.should == [key_fixtures[:pascal]]
        server.keys.should have(1).key
      end
      
      it "should remove duplicate keys from the list" do
        server = Server.new('somehost')
        server.stub!(:fetch_keys).and_return("#{key_fixtures[:pascal]}\n#{key_fixtures[:pascal]}")
        server.keys.should have(1).key
        server.keys.should == [key_fixtures[:pascal]]
      end
    end
    
    context "dumping the keys to files" do
      before do
        server = server_with_keys([key_fixtures[:pascal], key_fixtures[:bob]])
        server.dump_keyfiles
      end

      it "should replace special characters with underscores in filename" do
        it_should_generate_keyfile 'bob_schneider@nb_pfriederich_local.pub'
        it_should_generate_keyfile 'pascal_friederich@nb_pfriederich_local.pub'
      end
      
      it "should write the ssh key in the appropriate keyfile" do
        File.open('keys/bob_schneider@nb_pfriederich_local.pub').read.chomp.should == key_fixtures[:bob]
        File.open('keys/pascal_friederich@nb_pfriederich_local.pub').read.chomp.should == key_fixtures[:pascal]
      end
      
      it "should turn the filenames to underscores" do
        server = server_with_keys([key_fixtures[:upcase]])
        server.dump_keyfiles
        it_should_generate_keyfile 'upcase_van@nb_upcase_stuff.pub'
      end
    end
  end
end

def it_should_generate_keyfile(keyfile)
  Dir['keys/*.pub'].map {|path| path.split('/').last }.should include keyfile
end

def server_with_keys(keys)
  server = SSHMuggle::Server.new('hostname')
  server.stub!(:fetch_keys).and_return(keys.join("\n"))
  server.stub!(:keys).and_return(keys)
  server
end

def key_fixtures
  @key_fixtures ||= {:pascal => 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA0YllcgPG3lFhW1R6g1zHIOOZhW8fl5MsBxNQYFJnkNUvwcqcH1CLFr5ybdEwgOfjqT2YDLt9qY/cn4Wa1xLvPEph7nkdx6NW7VzcxcIiakgtEEGI+F6K0ux/3bXPIEIDZcaAmlfcnw+OkoqyQR1PWppT/74mc+6+GkCoewqgIhxuajPmjLK9eAtDjNGnwsN1t0+gZkc9HNWOxWGGGNyfoSgRPlIzr4cTDnfuRPzxZDKJXLd75RJIAhr2PQwQTrdhPurCG2+48AHul/D1mg+BzWeaXifl3pd8on/Buo97A6iLM+jcx1VjDzhVil6esS/+30XSEUANh974PlIECZnIFw== pascal.friederich@nb-pfriederich.local',
                     :bob => 'ssh-rsa LKASJFLASJFLKASJFLAKSFNALSKVNasdfj0fj0Jf0j09Jf90jw0fj9w0fjJFIWJLFNlnfLNlknflewknaflefawelfhweaf8932y98ry239f832hfh3fh3fiuhkljdsfkjasbdfwhefhewkjfhenkhfnkejfhhdskfjhdskfjhsdkjfhskdjfhalksdjhfkjdfhalsdkfhklasdfhdskfhjdkfjhqufheufwhewiuf38h9fh3298fh2938fh9283hf9823hf9823hfk2j3hfkj23fkj23fkjh23kjfhljhaasdfsadfsadf90usdf90saudf09jas0f9jas0fj09wjf0932hf0923hf0h320f9h230f9h329h== bob.schneider@nb-pfriederich.local',
                     :upcase => 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA0YllcgPG3lFhW1R6g1zHIOOZhW8fl5MsBxNQYFJnkNUvwcqcH1CLFr5ybdEwgOfjqT2YDLt9qY/cn4Wa1xLvPEph7nkdx6NW7VzcxcIiakgtEEGI+F6K0ux/3bXPIEIDZcaAmlfcnw+OkoqyQR1PWppT/74mc+6+GkCoewqgIhxuajPmjLK9eAtDjNGnwsN1t0+gZkc9HNWOxWGGGNyfoSgRPlIzr4cTDnfuRPzxZDKJXLd75RJIAhr2PQwQTrdhPurCG2+48AHul/D1mg+BzWeaXifl3pd8on/Buo97A6iLM+jcx1VjDzhVil6esS/+30XSEUANh974PlIECZnIFw== upcase.VaN@nb-UPCASE.StuFF'}
end