require 'rake/testtask'
require 'linemanager'

task :envtest do
  app_dir = File.expand_path(File.dirname(__FILE__))
  @manager = LineManager::Runner.new(app_dir, 'test', debug: true)
  @manager.wait_for('Server started, Redis')

  Rake::Task['test'].invoke
  @manager.teardown
end

Rake::TestTask.new do |t|
  t.pattern = "spec/**/*_spec.rb"
end

