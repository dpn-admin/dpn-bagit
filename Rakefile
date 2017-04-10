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

# app_version_tasks
spec = Gem::Specification.find_by_name 'app_version_tasks'
load "#{spec.gem_dir}/lib/tasks/app_version_tasks.rake"
require 'app_version_tasks'
AppVersionTasks.configure do |config|
  config.application_name = 'DPN::Bagit'
  config.version_file_path = File.join(pwd, 'lib', 'dpn', 'bagit', 'version.rb')
  config.git_working_directory = pwd
end
