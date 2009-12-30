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
      before :all do
        sorted_keys = [
          key_fixtures[:pascal],
          key_fixtures[:pascal_private],
          key_fixtures[:pascal_laptop],
          key_fixtures[:bob],
          key_fixtures[:upcase]
        ]

        server = server_with_keys(sorted_keys)
        server.dump_keyfiles
      end

      it "should replace special characters with underscores in filename" do
        it_should_generate_keyfile 'bob_schneider.pub'
        it_should_generate_keyfile 'pascal_friederich.pub'
      end

      it "should write the ssh key in the appropriate keyfile" do
        File.open('keys/bob_schneider.pub').read.chomp.should == key_fixtures[:bob]
        File.open('keys/pascal_friederich.pub').read.chomp.should == key_fixtures[:pascal]
      end

      it "should turn the filenames to underscores" do
        it_should_generate_keyfile 'upcase_van.pub'
      end

      it "should number dublicate keynames" do
        it_should_generate_keyfile 'pascal_friederich_2.pub'
        it_should_generate_keyfile 'pascal_friederich_3.pub'
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
  @key_fixtures ||= {
                       :pascal => 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA0YllcgPG3lFhW1R6g1zHIOOZhW8fl5MsBxNQYFJnkNUvwcqcH1CLFr5ybdEwgOfjqT2YDLt9qY/cn4Wa1xLvPEph7nkdx6NW7VzcxcIiakgtEEGI+F6K0ux/3bXPIEIDZcaAmlfcnw+OkoqyQR1PWppT/74mc+6+GkCoewqgIhxuajPmjLK9eAtDjNGnwsN1t0+gZkc9HNWOxWGGGNyfoSgRPlIzr4cTDnfuRPzxZDKJXLd75RJIAhr2PQwQTrdhPurCG2+48AHul/D1mg+BzWeaXifl3pd8on/Buo97A6iLM+jcx1VjDzhVil6esS/+30XSEUANh974PlIECZnIFw== pascal.friederich@nb-pfriederich.local',
                       :pascal_private  => 'ssh-rsa fajfoijewaofjewofjaweofnlwkaenfakdjngkaldsjgndkjsnflkjdsfnjsadfkjlasdfnasnfamlfaj9efj09waj09j3f029j3029j3f2j3f2uhfuhgkashgkljdsagkjeahh3iuf2h398fh329f8h32f983h2fh3n29unfup3fhapw39fhpa93fha9w3fh983bf2fubkbawekjbfabf,ebfa,menbfiufbawefuwefiweafiubewafibefbiuwbgiu4gbiueraghaeiuhfsdiofuhasdifuhaw9e8fh9f8h238fh239fhpawh3fp9ahwpfhawp39fhp490f8hawf8ha9ef8hawp9haugbs== pascal.friederich@private',
                       :pascal_laptop  => 'ssh-rsa fajfoijewaofjewofjaweofnlwkaenfakdjngkaldsjgndkjsnflkjdsfnjsadfkjlasdfnasnfamlfaj9efj09waj09j3f029j3029j3f2j3f2uhfuhgkashgkljdsagkjeahh3iuf2h398fh329f8h32f983h2fh3n29unfup3fhapw39fhpa93fha9w3fh983bf2fubkbawekjbfabf,ebfa,menbfiufbawefuwefiweafiubewafibefbiuwbgiu4gbiueraghaeiuhfsdiofuhasdifuhaw9e8fh9f8h238fh239fhpawh3fp9ahwpfhawp39fhp490f8hawf8ha9ef8hawp9haugbs== pascal.friederich@laptop',
                       :bob => 'ssh-rsa LKASJFLASJFLKASJFLAKSFNALSKVNasdfj0fj0Jf0j09Jf90jw0fj9w0fjJFIWJLFNlnfLNlknflewknaflefawelfhweaf8932y98ry239f832hfh3fh3fiuhkljdsfkjasbdfwhefhewkjfhenkhfnkejfhhdskfjhdskfjhsdkjfhskdjfhalksdjhfkjdfhalsdkfhklasdfhdskfhjdkfjhqufheufwhewiuf38h9fh3298fh2938fh9283hf9823hf9823hfk2j3hfkj23fkj23fkjh23kjfhljhaasdfsadfsadf90usdf90saudf09jas0f9jas0fj09wjf0932hf0923hf0h320f9h230f9h329h== bob.schneider@nb-pfriederich.local',
                       :upcase => 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA0YllcgPG3lFhW1R6g1zHIOOZhW8fl5MsBxNQYFJnkNUvwcqcH1CLFr5ybdEwgOfjqT2YDLt9qY/cn4Wa1xLvPEph7nkdx6NW7VzcxcIiakgtEEGI+F6K0ux/3bXPIEIDZcaAmlfcnw+OkoqyQR1PWppT/74mc+6+GkCoewqgIhxuajPmjLK9eAtDjNGnwsN1t0+gZkc9HNWOxWGGGNyfoSgRPlIzr4cTDnfuRPzxZDKJXLd75RJIAhr2PQwQTrdhPurCG2+48AHul/D1mg+BzWeaXifl3pd8on/Buo97A6iLM+jcx1VjDzhVil6esS/+30XSEUANh974PlIECZnIFw== upcase.VaN@nb-UPCASE.StuFF'
                     }
end