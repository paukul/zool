$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../lib'))
require 'ssh_muggle'
require 'spec'
require 'fakefs'

class Net::SCP
  class << self
    def disallow_file_operation(a, b, c, d)
      raise("unexpected call to SCP in test environment, see #{__FILE__}:#{__LINE__}")
    end
    alias upload!   disallow_file_operation
    alias upload    disallow_file_operation
    alias download! disallow_file_operation
    alias download  disallow_file_operation
  end
end

class StringbufferMatcher
  def initialize(expected)
    @expected = expected
  end
  
  def ==(actual)
    actual.string == @expected
  end
end

def stringbuffer_with(content)
  StringbufferMatcher.new(content)
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

module PyConfigParserHelper
  def parse(string)
    PyConfigParser.new.parse(string)
  end
end