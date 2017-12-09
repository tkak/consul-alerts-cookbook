# # encoding: utf-8

# Inspec test for recipe consul-alerts-cookbook::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe service('consul') do
  it { should be_enabled }
  it { should be_running }
end

describe service('consul-alerts') do
  it { should be_enabled }
  it { should be_running }
end
