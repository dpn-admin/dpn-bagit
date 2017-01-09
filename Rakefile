require "bundler/gem_tasks"
require "rake"
require "rake/testtask"

task :default => [:test]

desc "Run all tests."
Rake::TestTask.new(:test) do |t|
     t.libs << "lib"
     t.libs << "test"
     t.test_files = FileList['test/**/*_test.rb']
end
