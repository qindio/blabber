require 'rake/testtask'
require 'linemanager'

app_dir = File.expand_path(File.dirname(__FILE__))

task :envtest do
  @manager = LineManager::Runner.new(app_dir, 'test', debug: true)
  @manager.wait_for('] started')

  Rake::Task['test'].invoke
  @manager.teardown
end

task :travisci do
  @manager = LineManager::Runner.new(app_dir, 'travisci', debug: true)
  @manager.wait_for('Server started, Redis')

  Rake::Task['test'].invoke
  @manager.teardown
end

Rake::TestTask.new do |t|
  t.pattern = "spec/**/*_spec.rb"
end

