require 'spec_helper'

# This test suite is intended to cover all of the
# gory method calls to WIN32OLE, in effort to make
# future refactoring less painful.
#
# If you're adding system calls, add tests around the
# entire procedure here also. They don't have to be
# beautiful.
describe Puppet::Type.type(:fileshare).provider(:wmi) do
  let(:resource) { Puppet::Type.type(:fileshare).new(
    :provider => :wmi,
    :name     => "windows_fileshare",
    :comment  => "stub comment",
    :maxcon   => 123,
  ) }
  let(:provider) { resource.provider }

  let(:ole)  { mock('ole') }
  let(:wmi)  { mock('wmi') }
  let(:sd)   { mock('sd') }
  let(:sg)   { mock('sg') }
  let(:argv) { mock('argv') }
  let(:dacl) { mock('dacl') }
  let(:share) { mock('share') }
  let(:trustee) { mock('trustee') }

  before do
    WIN32OLE.stubs(:connect).at_least_once.returns(ole)
  end

  it "can create a share" do
    WIN32OLE.expects(:connect).with('winmgmts:Win32_Share').returns(ole)
    ole.expects(:create).at_least_once.with(nil, 'windows_fileshare', 0, nil, nil).returns(0)

    ole.stubs(:get).with("Win32_LogicalShareSecuritySetting='windows_fileshare'").returns(sg)
    ole.stubs(:get).with('Win32_Trustee').returns(trustee)
    ole.stubs(:get).with('Win32_SecurityDescriptor').returns(sd)
    sd.expects(:spawninstance_).returns(sd)
    trustee.expects(:spawninstance_).returns(trustee)
    sd.expects(:controlflags=).with(4)
    trustee.expects(:name=).with('Everyone')
    trustee.expects(:sid=).with([1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0])
    sd.expects(:owner=).with(trustee)
    sg.expects(:setsecuritydescriptor).with(sd)

    ole.expects(:get).at_least_once.with("Win32_Share='windows_fileshare'").returns(share)
    share.expects(:setshareinfo).at_least_once.with(123, 'stub comment')

    provider.create
  end

  it "can destroy a share" do
    ole.expects(:get).with("Win32_Share='windows_fileshare'").returns(wmi)
    wmi.expects(:delete).returns(0)
    provider.destroy
  end

  describe "checking for the existence of a share" do
    context "when the share exists" do
      it "should return true" do
        ole.expects(:get).with("Win32_Share='windows_fileshare'")
        expect(provider.exists?).to be true
      end
    end

    context "when the share does not exist" do
      it "should return false" do
        ole.expects(:get).with("Win32_Share='windows_fileshare'").raises
        expect(provider.exists?).to be false
      end
    end
  end

  it "can set the owner" do
    ole.stubs(:get).with("Win32_LogicalShareSecuritySetting='windows_fileshare'").returns(sg)
    ole.stubs(:get).with('Win32_Trustee').returns(trustee)
    ole.stubs(:get).with('Win32_SecurityDescriptor').returns(sd)
    sd.expects(:spawninstance_).returns(sd)
    trustee.expects(:spawninstance_).returns(trustee)
    sd.expects(:controlflags=).with(4)
    trustee.expects(:name=).with(nil)
    trustee.expects(:sid=).with(nil)
    sd.expects(:owner=).with(trustee)
    sg.expects(:setsecuritydescriptor).with(sd)
    provider.owner = {:owner => :foo}
  end

  describe "checking the owner" do
    context "when the owner hasn't been set" do
      it "should return :absent" do
        ole.expects(:get).with("Win32_LogicalShareSecuritySetting='windows_fileshare'").returns(sg)
        sg.expects(:getsecuritydescriptor).with(4)
        WIN32OLE::ARGV.expects(:[]).with(0).returns(argv)
        argv.expects(:DACL).returns(dacl)
        dacl.expects(:[]).with(0)
        expect(provider.owner).to be :absent
      end
    end

    context "when the owner has been set" do
      it "should return a hash containing the owner's attributes" do
        ole.expects(:get).at_least_once.with("Win32_LogicalShareSecuritySetting='windows_fileshare'").returns(sg)
        sg.expects(:getsecuritydescriptor).at_least_once.with(4)
        WIN32OLE::ARGV.expects(:[]).at_least_once.with(0).returns(argv)
        argv.expects(:DACL).at_least_once.returns(dacl)
        dacl.expects(:[]).at_least_once.with(0).returns(dacl)
        dacl.expects(:accessmask).returns('accessmask')
        dacl.expects(:trustee).at_least_once.returns(trustee)
        trustee.expects(:sid).returns('sid')
        trustee.expects(:name).returns('name')
        expect(provider.owner).to eq({
          "accessmask" => "accessmask",
          "sid"        => "sid",
          "username"   => "name",
        })
      end
    end
  end

  it "can set the comment" do
    ole.expects(:get).at_least_once.with("Win32_Share='windows_fileshare'").returns(share)
    share.expects(:setshareinfo).with(123, 'the comment')
    provider.comment = "the comment"
  end

  describe "getting the comment" do
    context "when the comment has been set" do
      it "should return the comment" do
        ole.expects(:get).at_least_once.with("Win32_Share='windows_fileshare'").returns(share)
        share.expects(:description).at_least_once.returns(:comment)
        expect(provider.comment).to eq(:comment)
      end
    end

    context "when the comment has not been set" do
      it "should return :absent" do
        ole.expects(:get).at_least_once.with("Win32_Share='windows_fileshare'").returns(share)
        share.expects(:description).at_least_once
        expect(provider.comment).to eq(:absent)
      end
    end
  end

  it "can set the maxcon" do
    ole.expects(:get).at_least_once.with("Win32_Share='windows_fileshare'").returns(share)
    share.expects(:setshareinfo).with(:maxcon, 'stub comment')
    provider.maxcon = :maxcon
  end

  describe "getting the maxcon" do
    context "when the maximum connections have been set" do
      it "should return the maxcon" do
        ole.expects(:get).at_least_once.with("Win32_Share='windows_fileshare'").returns(share)
        share.expects(:maximumallowed).at_least_once.returns(:maxcon)
        expect(provider.maxcon).to be :maxcon
      end
    end

    context "when the maximum connections have not been set" do
      it "should return :absent" do
        ole.expects(:get).at_least_once.with("Win32_Share='windows_fileshare'").returns(share)
        share.expects(:maximumallowed).at_least_once
        expect(provider.maxcon).to eq(:absent)
      end
    end
  end
end
