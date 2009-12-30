require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module SSHMuggle
  describe KeyfileWriter do
    context "dumping keys to files" do
      before :all do
        sorted_keys = [
          key_fixtures[:pascal],
          key_fixtures[:pascal_private],
          key_fixtures[:pascal_laptop],
          key_fixtures[:bob],
          key_fixtures[:upcase]
        ]

        sorted_keys.each do |key|
          KeyfileWriter.dump_key_to_file key
        end
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
