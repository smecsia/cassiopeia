require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'lib/cassiopeia'

desc 'Default: .'
task :default => :test

PKG_FILES = FileList[ '[a-zA-Z]*',  'lib/**/*' ]

spec = Gem::Specification.new do |s|
  s.name = "cassiopeia"
  s.version = Cassiopeia::VERSION
  s.author = "smecsia"
  s.email = "smecsia@gmail.com"
  #s.homepage = ""
  s.platform = Gem::Platform::RUBY
  s.summary = "Rails plugin for custom CAS(Cassiopeia) server/client implementation"
  s.add_dependency('uuidtools')
  s.add_dependency('rails', '>=3.0.0')
  s.files = PKG_FILES.to_a 
  s.require_path = "lib"
  s.has_rdoc = false
  s.extra_rdoc_files = ["README.rdoc"]
end

desc 'Turn this plugin into a gem.'
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

