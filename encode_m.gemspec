require_relative 'lib/encode_m/version'

Gem::Specification.new do |spec|
  spec.name          = 'encode_m'
  spec.version       = EncodeM::VERSION
  spec.authors       = ['Steve Shreeve']
  spec.email         = ['steve.shreeve@gmail.com']

  spec.summary       = 'Complete M language subscript encoding - numbers, strings, and composite keys'
  spec.description   = 'EncodeM v3.0 brings complete M language (MUMPS) subscript encoding to Ruby, ' \
                       'supporting numbers, strings, and composite keys with perfect sort order. ' \
                       'Build hierarchical database keys like M("users", 42, "email") that sort ' \
                       'correctly as raw bytes. This 40-year production-tested algorithm from ' \
                       'YottaDB/GT.M powers Epic (70% of US hospitals) and VistA. Perfect for ' \
                       'B-tree indexes, key-value stores, and any system requiring sortable ' \
                       'hierarchical keys. All types maintain correct ordering when compared ' \
                       'as byte strings - no decoding needed.'
  spec.homepage      = 'https://github.com/shreeve/encode_m'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.5.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['bug_tracker_uri'] = "#{spec.homepage}/issues"
  spec.metadata['documentation_uri'] = "https://rubydoc.info/gems/encode_m"

  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f|
      f.match(%r{^(test|spec|features)/}) ||
      f.match(%r{^\.}) ||
      f == 'Gemfile.lock'
    }
  end
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'minitest-reporters', '~> 1.6'
  spec.add_development_dependency 'benchmark-ips', '~> 2.10'

  spec.post_install_message = <<-MSG
Thank you for installing EncodeM v3.0!

🎉 NEW: Complete M language support - numbers, strings, and composite keys!

Quick start:
  require 'encode_m'

  # Numbers
  M(42)

  # Strings
  M("Hello")

  # Composite keys
  M("users", 42, "email")

Learn more: https://github.com/shreeve/encode_m
MSG
end
