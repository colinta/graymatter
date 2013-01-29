$:.unshift('/Library/RubyMotion/lib')
require 'motion/project'
require 'bundler'
Bundler.require


Motion::Project::App.setup do |app|
  app.name = 'GrayMatter'
  Dir.glob(File.join(app.project_dir, 'lib/**/*.rb')).each do |file|
    app.files << file
  end
end
