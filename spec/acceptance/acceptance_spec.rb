require 'spec_helper_acceptance'

pp = 'puppet apply spec/fixtures/acceptance.pp --modulepath .. --detailed-exitcodes'

describe command(pp) do
  its(:exit_status) { should_not eq 1 }
end

describe command(pp) do
  its(:exit_status) { should eq 1 }
end

describe file('\\\\localhost\test\test.txt') do
  it { should contain 'foo bar baz' }
end
