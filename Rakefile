#require "bundler/gem_tasks"

require 'fileutils'
#require 'rake'
#require 'rake/clean'

require_relative 'src/bootstrap/directories'

CURRENT_DIRECTORY = File.dirname(__FILE__)
TARGET_DIRECTORY = File.join CURRENT_DIRECTORY, 'target'
FileUtils.mkdir_p TARGET_DIRECTORY

nested_script = File.join CURRENT_DIRECTORY, 'tbag'
final_symlink = '/usr/bin/tbag'

def prompt_clean_warning
  puts 'Warning -- previous tbag installation detected.'
  puts "Cleaning will obliterate `#{Tbag::BASE_DIRECTORY.path}`, and you'll lose any existing tasks."
  puts 'Continue? [y/n]'
  response = STDIN.gets.chomp
  exit 0 if !%w(Y y).include? response
end

begin
  require 'rspec/core/rake_task'

  rspec_opts = []
  rspec_opts.push '--color' # color output
  rspec_opts.push '--format', 'documentation'
  #rspec_opts.push '--out', File.join(TARGET_DIRECTORY, 'rspec_output')

  RSpec::Core::RakeTask.new(:unit) do |t|
    puts 'unit: running unit tests'
    t.pattern = 'spec/unit/*_spec.rb'
    t.rspec_opts = rspec_opts
  end

  RSpec::Core::RakeTask.new(:integration) do |t|
    puts 'integration: running integration tests'
    t.pattern = 'spec/integration/*_spec.rb'
    t.rspec_opts = rspec_opts
  end
rescue LoadError
  puts 'Warning -- rspec not available, skipping unit and integration tests'

  task :unit do end
  task :integration do end
end

task :clean do
  prompt_clean_warning if Dir.exists? Tbag::BASE_DIRECTORY.path

  %W(#{Tbag::BASE_DIRECTORY.path} #{final_symlink}).each do |path|
    puts "clean: obliterating `#{path}`"
    FileUtils.rm_rf path
  end
end

task :configure do
  puts 'configure: validating file system hierarchy'
  Tbag::DIRECTORIES.each do |directory|
    raise "    fail - directory already exists (#{directory.path})" if Dir.exists? directory.path
  end

  puts '  configuring file system hierarchy...'
  Tbag::DIRECTORIES.reduce([]) { |acc, directory| acc.concat([directory].concat(directory.subdirectories)) }.each do |directory|
    puts "    creating directory (#{directory.path})"
    FileUtils.mkdir_p directory.path
  end

  puts '  file system hierarchy configured successfully!'
end

task :create_symlink do
  puts "    create symlink: #{nested_script} -> #{final_symlink})"
  FileUtils.symlink nested_script, final_symlink
end

task :full => [:clean, :unit, :integration, :configure, :create_symlink]
task :bootstrap => [:clean, :configure, :create_symlink]
task :default => [:clean, :unit, :integration]
