require 'spec_helper'

describe Puppet::Type.type(:fileshare).provider(:wmi) do
  let(:resource) { Puppet::Type.type(:fileshare).new(
    :provider => :wmi,
    :name     => "windows_fileshare",
    :comment  => "stub comment",
    :maxcon   => 123,
  ) }
  let(:provider) { resource.provider }
  let(:ole)  { mock('ole') }

  before do
    WIN32OLE.stubs(:connect).returns(ole)
  end

  context "when the wmi method returns 2" do
    it "should raise the appropriate error" do
      ole.stubs(:create).returns(2)
      expect{provider.create}.to raise_error(/Access Denied/)
    end
  end

  context "when the wmi method returns 8" do
    it "should raise the appropriate error" do
      ole.stubs(:create).returns(8)
      expect{provider.create}.to raise_error(/Unknown Failure/)
    end
  end

  context "when the wmi method returns 9" do
    it "should raise the appropriate error" do
      ole.stubs(:create).returns(9)
      expect{provider.create}.to raise_error(/Invalid Name/)
    end
  end

  context "when the wmi method returns 10" do
    it "should raise the appropriate error" do
      ole.stubs(:create).returns(10)
      expect{provider.create}.to raise_error(/Invalid Level/)
    end
  end

  context "when the wmi method returns 21" do
    it "should raise the appropriate error" do
      ole.stubs(:create).returns(21)
      expect{provider.create}.to raise_error(/Invalid Parameter/)
    end
  end

  context "when the wmi method returns 22" do
    it "should raise the appropriate error" do
      ole.stubs(:create).returns(22)
      expect{provider.create}.to raise_error(/Duplicate Share/)
    end
  end

  context "when the wmi method returns 23" do
    it "should raise the appropriate error" do
      ole.stubs(:create).returns(23)
      expect{provider.create}.to raise_error(/Redirected Path/)
    end
  end

  context "when the wmi method returns 24" do
    it "should raise the appropriate error" do
      ole.stubs(:create).returns(24)
      expect{provider.create}.to raise_error(/Unknown Directory/)
    end
  end

  context "when the wmi method returns 25" do
    it "should raise the appropriate error" do
      ole.stubs(:create).returns(25)
      expect{provider.create}.to raise_error(/Net Name Not Found/)
    end
  end
end
