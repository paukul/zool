require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module SSHMuggle
  describe KeyfileWriter do
    context "dumping keys to files" do
      before :each do
        @writer = KeyfileWriter.new
      end

      context "#write" do
        context "with no filename provided" do
          before :each do
            sorted_keys = [
              key_fixtures[:pascal],
              key_fixtures[:pascal_private],
              key_fixtures[:pascal_laptop],
              key_fixtures[:bob],
              key_fixtures[:upcase]
            ]
            sorted_keys.each do |key|
              @writer.write key
            end
          end

          it "should replace special characters with underscores in filename" do
            it_should_generate_keyfile 'bob_schneider.pub'
            it_should_generate_keyfile 'pascal_friederich.pub'
          end
          
          it "should not fail if keyfile name is not parsable" do
            key_without_host = "ssh-dsa asdfkasdlfjasdlfkjsdf="
            @writer.write key_without_host
            it_should_generate_keyfile '1__not_parsable.pub'
          end

          it "should write the ssh key in the appropriate keyfile" do
            File.read('keys/bob_schneider.pub').chomp.should == key_fixtures[:bob]
            File.read('keys/pascal_friederich.pub').chomp.should == key_fixtures[:pascal]
          end

          it "should turn the filenames to underscores" do
            it_should_generate_keyfile 'upcase_van.pub'
          end

          it "should number dublicate keynames" do
            it_should_generate_keyfile 'pascal_friederich_2.pub'
            it_should_generate_keyfile 'pascal_friederich_3.pub'
          end
        end
        
        context "with a filename provided" do
          it "should write the ssh key to the file named as given (with .pub added to the name)" do
            @writer.write('a key', 'customname')
            it_should_generate_keyfile('customname.pub')
          end
        end
      end
      
      context "#write_keys" do
        it "should write every key" do
          @writer.should_receive(:write).exactly(3).times
          keys = [
                  key_fixtures[:pascal],
                  key_fixtures[:pascal_private],
                  key_fixtures[:pascal_laptop]
                 ]
          @writer.write_keys(keys)
        end
      end
    end
  end
end

def it_should_generate_keyfile(keyfile)
  Dir['keys/*.pub'].map {|path| path.split('/').last }.should include keyfile
end
