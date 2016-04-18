# -*- encoding: utf-8 -*-
require File.expand_path('../lib/liquid_blocks/version', __FILE__)

Gem::Specification.new do |s|
  s.name              = 'liquid4-blocks'
  s.version           = LiquidBlocks::VERSION
  s.platform          = Gem::Platform::RUBY
  s.license           = 'MIT'
  s.authors           = ['Dan Webb', 'Silas Sewell', 'Justin Locsei', 'Rafał Mikołajun']
  s.homepage          = 'https://github.com/mikoweb/liquid4-blocks'
  s.summary           = 'Liquid Blocks'
  s.description       = 'Django-style template inheritance for Liquid'

  s.required_rubygems_version = '>= 1.3.6'

  s.add_dependency 'liquid', '~> 4.0.0.rc2'
  s.add_development_dependency 'bundler', '>= 1.0.0'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'test-unit'

  s.files             = `git ls-files -- lib/*`.split("\n")
  s.files            += ['LICENSE']
  s.require_paths     = ['lib']
  s.test_files        = `git ls-files -- test/*`.split("\n")
end
