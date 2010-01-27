require 'spec/rake/spectask'
require 'cucumber/rake/task'

Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = "--format progress"
end

task :default do
  %w(spec cucumber).each do |task|
    Rake::Task[task].invoke
  end
end

desc "Run all specs"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "zool"
    s.summary = "Library and command-line client to manage authorized_keys files"
    s.description = "Zool allows you to manage authorized_keys files on servers. It comes with a command-line client 'zool'. The configuration can be done in a pyconfig/gitosis like configuration file. See README.md for further details"
    s.email = "paukul@gmail.com"
    s.homepage = "http://github.com/paukul/zool"
    s.authors = ["Pascal Friederich"]
    s.version = ["0.1.3"]
    s.files.exclude 'vendor', 'spec', 'features', '.gitignore', 'Gemfile'
    s.test_files.include 'features/**/*'
    s.test_files.exclude 'features/tmp'
    s.add_dependency 'net-scp',   '>=1.0.2'
    s.add_dependency 'net-ssh',   '>=2.0.17'
    s.add_dependency 'treetop',   '>=1.4.3'
    s.add_dependency 'highline',  '>=1.5.1'

    s.add_development_dependency 'builder',          '>=2.1.2'
    s.add_development_dependency 'columnize',        '>=0.3.1'
    s.add_development_dependency 'cucumber',         '>=0.5.3'
    s.add_development_dependency 'diff-lcs',         '>=1.1.2'
    s.add_development_dependency 'fakefs',           '>=0.2.1'
    s.add_development_dependency 'json_pure',        '>=1.2.0'
    s.add_development_dependency 'linecache',        '>=0.43'
    s.add_development_dependency 'rake',             '>=0.8.7'
    s.add_development_dependency 'rspec',            '>=1.2.9'
    s.add_development_dependency 'ruby-debug',       '>=0.10.3'
    s.add_development_dependency 'ruby-debug-base',  '>=0.10.3'
    s.add_development_dependency 'term-ansicolor',   '>=1.0.4'
    
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end
