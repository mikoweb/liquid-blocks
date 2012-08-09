# -*- encoding: utf-8 -*-
require File.expand_path('../lib/liquid_blocks/version', __FILE__)

Gem::Specification.new do |s|
  s.name              = 'liquid-blocks'
  s.version           = LiquidBlocks::VERSION
  s.platform          = Gem::Platform::RUBY
  s.license           = 'MIT'
  s.authors           = ['Dan Webb', 'Silas Sewell']
  s.email             = ['silas@sewell.org']
  s.homepage          = 'https://github.com/silas/liquid-blocks'
  s.summary           = 'Liquid Blocks'
  s.description       = 'Django-style template inheritance for Liquid'

  s.required_rubygems_version = '>= 1.3.6'
  s.rubyforge_project         = 'liquid-blocks'

  s.add_development_dependency 'bundler', '>= 1.0.0'

  s.files             = `git ls-files -- lib/*`.split("\n")
  s.files            += ['LICENSE']
  s.require_paths     = 'lib'
  s.test_files        = `git ls-files -- test/*`.split("\n")
end
