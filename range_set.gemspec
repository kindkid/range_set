# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "range_set/version"

Gem::Specification.new do |s|
  s.name        = "range_set"
  s.version     = RangeSet::VERSION
  s.authors     = ["Chris Johnson"]
  s.email       = ["chris@kindkid.com"]
  s.homepage    = "https://github.com/kindkid/range_set"
  s.summary     = "Set implementation based on ranges"
  s.description = s.summary

  s.rubyforge_project = "range_set"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_dependency "rbtree-pure", "~> 0.1"
  s.add_development_dependency "rspec", "~> 2.6"
  s.add_development_dependency "simplecov", "~> 0.4"
  s.add_development_dependency("rb-fsevent", "~> 0.4") if RUBY_PLATFORM =~ /darwin/i
  s.add_development_dependency "guard", "~> 0.5"
  s.add_development_dependency "guard-bundler", "~> 0.1"
  s.add_development_dependency "guard-rspec", "~> 0.4"
end
