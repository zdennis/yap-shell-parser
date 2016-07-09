# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yap/shell/parser'
require 'yap/shell/parser/version'

Gem::Specification.new do |spec|
  spec.name          = "yap-shell-parser"
  spec.version       = Yap::Shell::Parser::VERSION
  spec.authors       = ["Zach Dennis"]
  spec.email         = ["zach.dennis@gmail.com"]
  spec.summary       = %q{The parser for the yap shell}
  spec.description   = %q{The parser for the yap shell}
  spec.homepage      = "https://github.com/zdennis/yap-shell-parser"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  # spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  # Be specific about these dependencies otherwise RubyGems may print
  # following warning:
  #
  #    WARN: Unresolved specs during Gem::Specification.reset
  #
  # This warning is caused by RubyGems having multiple versions of a gem
  # installed that could match requirements.
  spec.add_dependency "tins", "= 1.10.2"

  spec.add_dependency "treefell", "~> 0.3"
  spec.add_dependency "term-ansicolor", "~> 1.3.2"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "pry-byebug"
end
