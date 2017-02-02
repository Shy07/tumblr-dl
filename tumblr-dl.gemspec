# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tumblr/dl/version'

Gem::Specification.new do |spec|
  spec.name          = "tumblr-dl"
  spec.version       = Tumblr::Dl::VERSION
  spec.authors       = ["Lynch HSU"]
  spec.email         = ["Gernischt@gmail.com"]

  spec.summary       = %q{Get image and video resources from Tumblr by username.}
  spec.description   = %q{Get image and video resources from Tumblr by username.}
  spec.homepage      = "http://shy07.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables << 'tumblr_dl'
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
end
