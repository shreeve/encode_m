require_relative 'lib/encode_m/version'

Gem::Specification.new do |spec|
  spec.name          = 'encode_m'
  spec.version       = EncodeM::VERSION
  spec.authors       = ['Steve Shreeve']
  spec.email         = ['steve.shreeve@gmail.com']
  
  spec.summary       = 'M language numeric encoding for Ruby - sortable, efficient, production-tested'
  spec.description   = 'EncodeM brings a 40-year production-tested numeric encoding algorithm ' \
                       'from YottaDB/GT.M to Ruby. This algorithm from the M language (MUMPS) ' \
                       'provides efficient numeric handling with the unique property that ' \
                       'encoded byte strings maintain sort order. Perfect for database ' \
                       'operations, financial calculations, and systems requiring efficient ' \
                       'sortable number storage. A practical alternative between Float and ' \
                       'BigDecimal.'
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
Thank you for installing EncodeM!

Quick start:
  require 'encode_m'
  a = M(42)  # Create a number with M language encoding

Learn more: https://github.com/shreeve/encode_m
MSG
end
