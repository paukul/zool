require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe PyConfigParser do
  include PyConfigParserHelper

  before :all do
    @config_string = <<-CONF
    [without_whitespace]
      key:value
      multiple_values=foo, bar, baz
      sticky_values=blim,blam,blum
    [with whitespace]
      key2: value2
      key3 : value3
      multiple_values = foo, bar, baz
    CONF
  end

  context "parsing a config" do
    context "when invalid" do
      it "should compile to nil" do
        parse('strange stuff').should be_nil
      end
    end

    context "when valid" do
      it "should compile to a hash" do
        parse("").build.should == {}
      end
    
      context "with sections" do
        before :all do
          @sections = parse(@config_string).build
        end
      
        it "should recognize sections" do
          @sections["with whitespace"].should be_a(Hash)
          @sections["without_whitespace"].should be_a(Hash)
        end
      
        it "should map key/value pairs separated by colons" do
          @sections["with whitespace"]['key2'].should == 'value2'
          @sections["without_whitespace"]['key'].should == 'value'
        end
      
        it "should map key/value pairs separated by an equal sign and devided by commas" do
          @sections["with whitespace"]['multiple_values'].should == %w(foo bar baz)
          @sections["without_whitespace"]['multiple_values'].should == %w(foo bar baz)
          @sections["without_whitespace"]['sticky_values'].should == %w(blim blam blum)
        end      
      end
    end
  end
end