source :rubygems
puppetversion = ENV.key?('PUPPET_VERSION') ? "= #{ENV['PUPPET_VERSION']}" : ['>= 2.7']

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion
else
  gem 'puppet'
end

group :test do
  gem 'rake', '>= 0.9.0'
  gem 'rspec', '>= 2.8.0'
  gem 'rspec-puppet', '>= 0.1.1'
  gem 'puppetlabs_spec_helper', '>=0.8.1'
end
