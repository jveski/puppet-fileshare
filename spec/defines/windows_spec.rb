require 'spec_helper'

describe Puppet::Type.type(:fileshare).provider(:windows) do
  let (:resource) { Puppet::Type.type(:fileshare).new(:provider => :windows, :name => "test_fileshare") }
  let (:provider) { resource.provider }

  context "when validating parameters" do
    it "should throw an error for an invalid name" do
      expect { resource[:name] = "test*&^illegal!@#name" }.to raise_error(Puppet::ResourceError, /must not contain/)
    end

    it "should allow a valid name" do
      expect { resource[:name] = "alegitsharename" }.to_not raise_error
    end

    it "should throw an error for an absolute posix-style path" do
      expect { resource[:path] = "/posix/path/here" }.to raise_error(Puppet::ResourceError, /absolute file path/)
    end

    it "should allow absolute windows paths with capital drive letters" do
      expect { resource[:path] = "C:/path/here" }.to_not raise_error
    end

    it "should allow absolute windows paths with lowercase drive letters" do
      expect { resource[:path] = "c:/path/here" }.to_not raise_error
    end

    it "should allow forward slashes in the path" do
      expect { resource[:path] = "c:/path/here" }.to_not raise_error
    end

    it "should allow back slashes in the path" do
      expect { resource[:path] = "C:\\path\\here" }.to_not raise_error
    end

    it "should allow setting of comment" do
      resource[:comment] = "testcomment"
      expect(resource[:comment]).to eq("testcomment")
    end
  end
end
