require 'spec_helper'

describe Puppet::Type.type(:fileshare) do
  context "when setting name" do
    it "should throw an error for an invalid name" do
      expect {
        Puppet::Type.type(:fileshare).new(
          :name => '?*',
        )
      }.to raise_error(/must not contain/)
    end

    it "should allow a valid name" do
      expect {
        Puppet::Type.type(:fileshare).new(
          :name => 'testshare',
        )
      }.to_not raise_error
    end

  end

  context "when setting path" do
    it "should throw an error for an absolute posix-style path" do
      expect {
        Puppet::Type.type(:fileshare).new(
          :name => 'testshare',
          :path => '/tmp/foo',
        )
      }.to raise_error(/must be fully qualified/)
    end

    it "should allow absolute windows paths with capital drive letters" do
      expect {
        Puppet::Type.type(:fileshare).new(
          :name => 'testshare',
          :path => 'C:\test',
        )
      }.to_not raise_error
    end

    it "should allow absolute windows paths with lowercase drive letters" do
      expect {
        Puppet::Type.type(:fileshare).new(
          :name => 'testshare',
          :path => 'c:\test',
        )
      }.to_not raise_error
    end

    it "should allow forward slashes in the path" do
      expect {
        Puppet::Type.type(:fileshare).new(
          :name => 'testshare',
          :path => 'c:/test/foo',
        )
      }.to_not raise_error
    end

    it "should allow back slashes in the path" do
      expect {
        Puppet::Type.type(:fileshare).new(
          :name => 'testshare',
          :path => 'c:\test\foo',
        )
      }.to_not raise_error
    end
  end

  context "when setting maxcon" do
    it "should allow integer" do
      expect {
        Puppet::Type.type(:fileshare).new(
          :name   => 'testshare',
          :maxcon => '123',
        )
      }.to_not raise_error
    end

    it "should not allow string" do
      expect {
        Puppet::Type.type(:fileshare).new(
          :name   => 'testshare',
          :maxcon => 'foo',
        )
      }.to raise_error(/expressed as an integer/)
    end
  end
end
