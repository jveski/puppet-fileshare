require 'spec_helper'

describe Puppet::Type.type(:fileshare) do
  it "should throw an error for an invalid name" do
    expect {
      described_class.new(:name => '?*')
    }.to raise_error(/must not contain/)
  end

  it "should allow a valid name" do
    expect {
      described_class.new(:name => 'testshare')
    }.to_not raise_error
  end


  it "should throw an error for an absolute posix-style path" do
    expect {
      described_class.new(
        :name => 'testshare',
        :path => '/tmp/foo',
      )
    }.to raise_error(/must be fully qualified/)
  end

  it "should allow absolute windows paths with capital drive letters" do
    expect {
      described_class.new(
        :name => 'testshare',
        :path => 'C:\test',
      )
    }.to_not raise_error
  end

  it "should allow absolute windows paths with lowercase drive letters" do
    expect {
      described_class.new(
        :name => 'testshare',
        :path => 'c:\test',
      )
    }.to_not raise_error
  end

  it "should allow forward slashes in the path" do
    expect {
      described_class.new(
        :name => 'testshare',
        :path => 'c:/test/foo',
      )
    }.to_not raise_error
  end

  it "should allow back slashes in the path" do
    expect {
      described_class.new(
        :name => 'testshare',
        :path => 'c:\test\foo',
      )
    }.to_not raise_error
  end

  it "should allow maxcon integer" do
    expect {
      described_class.new(
        :name   => 'testshare',
        :maxcon => 123,
      )
    }.to_not raise_error
  end

  it "should not allow maxcon string" do
    expect {
      described_class.new(
        :name   => 'testshare',
        :maxcon => '123',
      )
    }.to raise_error(/expressed as an integer/)
  end

  it "should not allow a maxcon larger than the max" do
    expect {
      described_class.new(
        :name   => 'testshare',
        :maxcon => 16777217,
      )
    }.to raise_error(/must be less/)
  end
end
