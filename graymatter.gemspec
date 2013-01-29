# -*- encoding: utf-8 -*-
require File.expand_path('../lib/graymatter/version.rb', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'graymatter'
  gem.version       = SugarCube::Version

  gem.authors = ['Colin T.A. Gray']
  gem.email   = ['colinta@gmail.com']
  gem.summary     = %{Tools, helpers, custom views, etc. for RubyMotion.}
  gem.description = <<-DESC
I hope you enjoy this random assortment of tools!  Read about each one in the
README.
DESC

  gem.homepage    = 'https://github.com/colinta/graymatter'

  gem.files        = `git ls-files`.split($\)
  gem.executables  = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files   = gem.files.grep(%r{^spec/})

  gem.require_paths = ['lib']
end
