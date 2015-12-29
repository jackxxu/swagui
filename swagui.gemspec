# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'swagui/version'

Gem::Specification.new do |spec|
  spec.name          = "swagui"
  spec.version       = Swagui::VERSION
  spec.authors       = ["Jack Xu"]
  spec.email         = ["jackxxu@gmail.com"]
  spec.summary       = %q{A rack-based swagger-ui middleware and commandline utility.}
  spec.homepage      = "https://github.com/jackxxu/swagui"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rack"
  spec.add_dependency 'rack-cors'
  spec.add_dependency 'watir'
  spec.add_dependency 'watir-webdriver'
  spec.add_dependency 'webrick'

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
