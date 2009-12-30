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

namespace :bundler do
  desc "Bundle the needed gems with bundler"
  task :bundle do
    system "gem bundle"
  end
end
