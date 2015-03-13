require 'spec_helper'

describe Puppet::Type.type(:fileshare).provider(:windows) do
  let (:resource) { Puppet::Type.type(:fileshare).new(:provider => :wmi, :name => "test_fileshare") }

  context "when setting name" do
    it "should throw an error for an invalid name" do
      expect { resource[:name] = "test*&^illegal!@#name" }.to raise_error(Puppet::ResourceError, /must not contain/)
    end

    it "should allow a valid name" do
      expect { resource[:name] = "alegitsharename" }.to_not raise_error
    end
  end

  context "when setting path" do
    it "should throw an error for an absolute posix-style path" do
      expect { resource[:path] = "/posix/path/here" }.to raise_error(Puppet::ResourceError, /must be fully qualified/)
    end

    it "should throw an error for a path ending in a forward slash" do
      expect { resource[:path] = "C:/trailing/slash/" }.to raise_error(Puppet::ResourceError, /not end with a forward slash/)
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
  end

  context "when setting comment" do
    it "should allow setting of comment" do
      expect { resource[:comment] = "testcomment" }.to_not raise_error
    end
  end

  context "when setting maxcon" do
    it "should allow integer" do
      expect { resource[:maxcon] = 12 }.to_not raise_error
    end

    it "should not allow string" do
      expect { resource[:maxcon] = "teststring" }.to raise_error(Puppet::ResourceError, /expressed as an integer/)
    end
  end
end
