desc "Validate Syntax"
task :validate do
  Dir['**/*.pp'].each do |manifest|
    sh "puppet-lint --no-autoloader_layout-check #{manifest}"
  end
  Dir['manifests/**/*.pp'].each do |manifest|
    sh "puppet parser validate --noop #{manifest}"
  end
  Dir['**/*.rb'].each do |file|
    sh "ruby-lint #{file} -a pedantics"
  end
end
