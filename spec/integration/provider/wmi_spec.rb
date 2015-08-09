require 'puppetlabs_spec_helper/module_spec_helper'
WIN32OLE = Class.new
WIN32OLE::ARGV = Class.new

describe Puppet::Type.type(:fileshare).provider(:wmi) do
  let(:resource) { Puppet::Type.type(:fileshare).new(:provider => :wmi, :name => "windows_fileshare") }
  let(:provider) { resource.provider }

  let(:the_ole)  { mock('ole') }
  let(:the_wmi)  { mock('wmi') }
  let(:the_sd)   { mock('sd') }
  let(:the_sg)   { mock('sg') }
  let(:the_argv) { mock('argv') }
  let(:the_dacl) { mock('dacl') }
  let(:the_share) { mock('share') }
  let(:the_trustee) { mock('trustee') }

  before do
    WIN32OLE.stubs(:connect).returns(the_ole)
  end

  describe ".create" do
    it "should create the file share and set the owner" do
      WIN32OLE.expects(:connect).with('winmgmts:Win32_Share').returns(the_ole)
      the_ole.expects(:create).with(nil, 'windows_fileshare', 0, nil, nil).returns(0)

      the_ole.expects(:get).with('Win32_SecurityDescriptor').returns(the_sd)
      the_ole.expects(:get).with('Win32_Trustee').returns(the_trustee)
      the_ole.expects(:get).with("Win32_LogicalShareSecuritySetting='windows_fileshare'").returns(the_sg)
      the_sd.expects(:spawninstance_).returns(the_sd)
      the_trustee.expects(:spawninstance_).returns(the_trustee)
      the_sd.expects(:controlflags=).with(4)
      the_trustee.expects(:name=).with('Everyone')
      the_trustee.expects(:sid=).with([1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0])
      the_sd.expects(:owner=).with(the_trustee)
      the_sg.expects(:setsecuritydescriptor).with(the_sd)
      the_ole.expects(:get).at_least_once.with("Win32_Share='windows_fileshare'").returns(the_wmi)
      the_wmi.expects(:setshareinfo).with(16777216, nil)

      provider.create
    end

    context "when the comment is set" do
      let(:resource) { Puppet::Type.type(:fileshare).new(:provider => :wmi, :name => "windows_fileshare", :comment => 'the comment') }
      it "should create the file share and set the comment" do
        WIN32OLE.expects(:connect).with('winmgmts:Win32_Share').returns(the_ole)
        the_ole.expects(:create).with(nil, 'windows_fileshare', 0, nil, nil).returns(0)

        the_ole.expects(:get).with('Win32_SecurityDescriptor').returns(the_sd)
        the_ole.expects(:get).with('Win32_Trustee').returns(the_trustee)
        the_ole.expects(:get).with("Win32_LogicalShareSecuritySetting='windows_fileshare'").returns(the_sg)
        the_sd.expects(:spawninstance_).returns(the_sd)
        the_trustee.expects(:spawninstance_).returns(the_trustee)
        the_sd.expects(:controlflags=).with(4)
        the_trustee.expects(:name=).with('Everyone')
        the_trustee.expects(:sid=).with([1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0])
        the_sd.expects(:owner=).with(the_trustee)
        the_sg.expects(:setsecuritydescriptor).with(the_sd)
        the_ole.expects(:get).at_least_once.with("Win32_Share='windows_fileshare'").returns(the_wmi)
        the_wmi.expects(:setshareinfo).with(16777216, 'the comment')

        provider.create
      end
    end

    context "when the wmi method returns 2" do
      it "should raise the appropriate message" do
        the_ole.stubs(:create).returns(2)
        expect{provider.create}.to raise_error(/Access Denied/)
      end
    end

    context "when the wmi method returns 8" do
      it "should raise the appropriate message" do
        the_ole.stubs(:create).returns(8)
        expect{provider.create}.to raise_error(/Unknown Failure/)
      end
    end

    context "when the wmi method returns 9" do
      it "should raise the appropriate message" do
        the_ole.stubs(:create).returns(9)
        expect{provider.create}.to raise_error(/Invalid Name/)
      end
    end

    context "when the wmi method returns 10" do
      it "should raise the appropriate message" do
        the_ole.stubs(:create).returns(10)
        expect{provider.create}.to raise_error(/Invalid Level/)
      end
    end

    context "when the wmi method returns 21" do
      it "should raise the appropriate message" do
        the_ole.stubs(:create).returns(21)
        expect{provider.create}.to raise_error(/Invalid Parameter/)
      end
    end

    context "when the wmi method returns 22" do
      it "should raise the appropriate message" do
        the_ole.stubs(:create).returns(22)
        expect{provider.create}.to raise_error(/Duplicate Share/)
      end
    end

    context "when the wmi method returns 23" do
      it "should raise the appropriate message" do
        the_ole.stubs(:create).returns(23)
        expect{provider.create}.to raise_error(/Redirected Path/)
      end
    end

    context "when the wmi method returns 24" do
      it "should raise the appropriate message" do
        the_ole.stubs(:create).returns(24)
        expect{provider.create}.to raise_error(/Unknown Directory/)
      end
    end

    context "when the wmi method returns 25" do
      it "should raise the appropriate message" do
        the_ole.stubs(:create).returns(25)
        expect{provider.create}.to raise_error(/Net Name Not Found/)
      end
    end
  end

  describe ".destroy" do
    it "should destroy the file share" do
      WIN32OLE.expects(:connect).with('winmgmts://localhost/root/cimv2').returns(the_ole)
      the_ole.expects(:get).with("Win32_Share='windows_fileshare'").returns(the_wmi)
      the_wmi.expects(:delete).returns(0)
      provider.destroy
    end

    context "when the wmi method returns 0" do
      it "should raise the appropriate message" do
        the_ole.stubs(:get).returns(the_wmi)
        the_wmi.stubs(:delete).returns(0)
        expect{provider.destroy}.to_not raise_error
      end
    end

    context "when the wmi method returns 2" do
      it "should raise the appropriate message" do
        the_ole.stubs(:get).returns(the_wmi)
        the_wmi.stubs(:delete).returns(2)
        expect{provider.destroy}.to raise_error(/Access Denied/)
      end
    end

    context "when the wmi method returns 8" do
      it "should raise the appropriate message" do
        the_ole.stubs(:get).returns(the_wmi)
        the_wmi.stubs(:delete).returns(8)
        expect{provider.destroy}.to raise_error(/Unknown Failure/)
      end
    end

    context "when the wmi method returns 9" do
      it "should raise the appropriate message" do
        the_ole.stubs(:get).returns(the_wmi)
        the_wmi.stubs(:delete).returns(9)
        expect{provider.destroy}.to raise_error(/Invalid Name/)
      end
    end

    context "when the wmi method returns 10" do
      it "should raise the appropriate message" do
        the_ole.stubs(:get).returns(the_wmi)
        the_wmi.stubs(:delete).returns(10)
        expect{provider.destroy}.to raise_error(/Invalid Level/)
      end
    end

    context "when the wmi method returns 21" do
      it "should raise the appropriate message" do
        the_ole.stubs(:get).returns(the_wmi)
        the_wmi.stubs(:delete).returns(21)
        expect{provider.destroy}.to raise_error(/Invalid Parameter/)
      end
    end

    context "when the wmi method returns 22" do
      it "should raise the appropriate message" do
        the_ole.stubs(:get).returns(the_wmi)
        the_wmi.stubs(:delete).returns(22)
        expect{provider.destroy}.to raise_error(/Duplicate Share/)
      end
    end

    context "when the wmi method returns 23" do
      it "should raise the appropriate message" do
        the_ole.stubs(:get).returns(the_wmi)
        the_wmi.stubs(:delete).returns(23)
        expect{provider.destroy}.to raise_error(/Redirected Path/)
      end
    end

    context "when the wmi method returns 24" do
      it "should raise the appropriate message" do
        the_ole.stubs(:get).returns(the_wmi)
        the_wmi.stubs(:delete).returns(24)
        expect{provider.destroy}.to raise_error(/Unknown Directory/)
      end
    end

    context "when the wmi method returns 25" do
      it "should raise the appropriate message" do
        the_ole.stubs(:get).returns(the_wmi)
        the_wmi.stubs(:delete).returns(25)
        expect{provider.destroy}.to raise_error(/Net Name Not Found/)
      end
    end
  end

  describe ".exists?" do
    it "should check for the file share's existence" do
      WIN32OLE.expects(:connect).with('winmgmts://localhost/root/cimv2').returns(the_ole)
      the_ole.expects(:get).with("Win32_Share='windows_fileshare'")
      provider.exists?
    end

    context "when the share exists" do
      it "should return true" do
        WIN32OLE.expects(:connect).with('winmgmts://localhost/root/cimv2').returns(the_ole)
        the_ole.expects(:get).with("Win32_Share='windows_fileshare'")
        expect(provider.exists?).to be true
      end
    end

    context "when the share does not exist" do
      it "should return false" do
        WIN32OLE.expects(:connect).with('winmgmts://localhost/root/cimv2').returns(the_ole)
        the_ole.expects(:get).with("Win32_Share='windows_fileshare'").raises
        expect(provider.exists?).to be false
      end
    end
  end

  describe ".owner=" do
    it "should set the owner" do
      WIN32OLE.expects(:connect).with('winmgmts://localhost/root/cimv2').returns(the_ole)
      the_ole.expects(:get).with('Win32_SecurityDescriptor').returns(the_sd)
      the_ole.expects(:get).with('Win32_Trustee').returns(the_trustee)
      the_ole.expects(:get).with("Win32_LogicalShareSecuritySetting='windows_fileshare'").returns(the_sg)
      the_sd.expects(:spawninstance_).returns(the_sd)
      the_trustee.expects(:spawninstance_).returns(the_trustee)
      the_sd.expects(:controlflags=).with(4)
      the_trustee.expects(:name=).with(nil)
      the_trustee.expects(:sid=).with(nil)
      the_sd.expects(:owner=).with(the_trustee)
      the_sg.expects(:setsecuritydescriptor).with(the_sd)
      provider.owner = :the_owner
    end
  end

  describe ".owner" do
    context "when the owner hasn't been set" do
      it "should return :absent" do
        WIN32OLE.expects(:connect).with('winmgmts://localhost/root/cimv2').returns(the_ole)
        the_ole.expects(:get).with("Win32_LogicalShareSecuritySetting='windows_fileshare'").returns(the_sg)
        the_sg.expects(:getsecuritydescriptor).with(4)
        WIN32OLE::ARGV.expects(:[]).with(0).returns(the_argv)
        the_argv.expects(:DACL).returns(the_dacl)
        the_dacl.expects(:[]).with(0)
        expect(provider.owner).to be :absent
      end
    end

    context "when the owner has been set" do
      it "should return a hash containing the owner's attributes" do
        WIN32OLE.expects(:connect).with('winmgmts://localhost/root/cimv2').returns(the_ole)
        the_ole.expects(:get).at_least_once.with("Win32_LogicalShareSecuritySetting='windows_fileshare'").returns(the_sg)
        the_sg.expects(:getsecuritydescriptor).at_least_once.with(4)
        WIN32OLE::ARGV.expects(:[]).at_least_once.with(0).returns(the_argv)
        the_argv.expects(:DACL).at_least_once.returns(the_dacl)
        the_dacl.expects(:[]).at_least_once.with(0).returns(the_dacl)
        the_dacl.expects(:accessmask).returns('the_accessmask')
        the_dacl.expects(:trustee).at_least_once.returns(the_trustee)
        the_trustee.expects(:sid).returns('the_sid')
        the_trustee.expects(:name).returns('the_name')
        expect(provider.owner).to eq({
          "accessmask" => "the_accessmask",
          "sid"        => "the_sid",
          "username"   => "the_name",
        })
      end
    end
  end

  describe ".comment=" do
    it "should set the comment" do
      WIN32OLE.expects(:connect).with('winmgmts://localhost/root/cimv2').returns(the_ole)
      the_ole.expects(:get).at_least_once.with("Win32_Share='windows_fileshare'").returns(the_share)
      the_share.expects(:maximumallowed).at_least_once.returns('the max')
      the_share.expects(:setshareinfo).with('the max', 'the comment')
      provider.comment = "the comment"
    end
  end

  describe ".comment" do
    context "when the comment has been set" do
      it "should return the comment" do
        WIN32OLE.expects(:connect).with('winmgmts://localhost/root/cimv2').returns(the_ole)
        the_ole.expects(:get).at_least_once.with("Win32_Share='windows_fileshare'").returns(the_share)
        the_share.expects(:description).at_least_once.returns(:the_comment)
        expect(provider.comment).to eq(:the_comment)
      end
    end

    context "when the comment has not been set" do
      it "should return :absent" do
        WIN32OLE.expects(:connect).with('winmgmts://localhost/root/cimv2').returns(the_ole)
        the_ole.expects(:get).at_least_once.with("Win32_Share='windows_fileshare'").returns(the_share)
        the_share.expects(:description).at_least_once
        expect(provider.comment).to eq(:absent)
      end
    end
  end

  describe ".maxcon=" do
    it "should set the maxcon" do
      WIN32OLE.expects(:connect).with('winmgmts://localhost/root/cimv2').returns(the_ole)
      the_ole.expects(:get).at_least_once.with("Win32_Share='windows_fileshare'").returns(the_share)
      the_share.expects(:description).returns(:the_comment)
      the_share.expects(:setshareinfo).with(:the_maxcon, :the_comment)
      provider.maxcon = :the_maxcon
    end
  end

  describe ".maxcon" do
    context "when the maximum connections have been set" do
      it "should return the maxcon" do
        WIN32OLE.expects(:connect).with('winmgmts://localhost/root/cimv2').returns(the_ole)
        the_ole.expects(:get).at_least_once.with("Win32_Share='windows_fileshare'").returns(the_share)
        the_share.expects(:maximumallowed).at_least_once.returns(:the_maxcon)
        expect(provider.maxcon).to be :the_maxcon
      end
    end

    context "when the maximum connections have not been set" do
      it "should return :absent" do
        WIN32OLE.expects(:connect).with('winmgmts://localhost/root/cimv2').returns(the_ole)
        the_ole.expects(:get).at_least_once.with("Win32_Share='windows_fileshare'").returns(the_share)
        the_share.expects(:maximumallowed).at_least_once
        expect(provider.maxcon).to eq(:absent)
      end
    end
  end

end
