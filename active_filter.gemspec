$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'active_filter/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'active_filter'
  spec.version     = ActiveFilter::VERSION
  spec.authors     = ['Lumbreras']
  spec.email       = ['nac13k@gmail.com']
  spec.homepage    = 'https://github.com/nac13k/'
  spec.summary     = 'ActiveFilter for postgresql.'
  spec.description = 'Description of ActiveFilter.'
  spec.license     = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'pg', '>= 0.18'
  spec.add_dependency 'rails', '~> 5.2.2'
end
