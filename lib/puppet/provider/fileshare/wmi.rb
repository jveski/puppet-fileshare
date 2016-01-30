begin; require 'win32ole'; rescue Exception; end

Puppet::Type.type(:fileshare).provide(:wmi) do
  desc "Manage Windows File Shares"
  confine :operatingsystem => :windows
  defaultfor :operatingsystem => :windows

  OLEPrefix = 'winmgmts:'
  ShareType = 'Win32_Share'
  CIMV2 = '//localhost/root/cimv2'
  SD = 4
  CreationDefaults = [0, nil, nil]
  TrusteeType = 'Win32_Trustee'
  SDType = 'Win32_SecurityDescriptor'
  SecuritySettingsType = 'Win32_LogicalShareSecuritySetting'
  ExitCodes = {
    2 => "Access Denied",
    8 => "Unknown Failure",
    9 => "Invalid Name",
    10 => "Invalid Level",
    21 => "Invalid Parameter",
    22 => "Duplicate Share",
    23 => "Redirected Path",
    24 => "Unknown Directory",
    25 => "Net Name Not Found",
  }

  def create
    eval WIN32OLE.connect(OLEPrefix + ShareType).create(@resource[:path], @resource[:name], *CreationDefaults)
    owner = @resource[:owner]
    maxcon = @resource[:maxcon]
    comment = @resource[:comment]
  end

  def destroy
    eval WIN32OLE.connect(OLEPrefix + CIMV2).get(ShareType + name).delete
  end

  def exists?
    begin
      WIN32OLE.connect(OLEPrefix + CIMV2).get(ShareType + name)
      true
    rescue
      false
    end
  end

  def owner
    WIN32OLE.connect(OLEPrefix + CIMV2).get(SecuritySettingsType + name).getsecuritydescriptor(SD)
    dacl = WIN32OLE::ARGV[0].DACL[0]

    return :absent unless dacl

    {
      'accessmask' => String(dacl.accessmask),
      'sid' => dacl.trustee.sid,
      'username' => dacl.trustee.name,
    }
  end

  def owner=(owner_hash)
    trustee = WIN32OLE.connect(OLEPrefix + CIMV2).get(TrusteeType).spawninstance_
    trustee.name = owner_hash['username']
    trustee.sid = owner_hash['sid']

    sd = WIN32OLE.connect(OLEPrefix + CIMV2).get(SDType).spawninstance_
    sd.controlflags = 4
    sd.owner = trustee

    WIN32OLE.connect(OLEPrefix + CIMV2).get(SecuritySettingsType + name).setsecuritydescriptor(sd)
  end

  def comment
    WIN32OLE.connect(OLEPrefix + CIMV2).get(ShareType + name).description || :absent
  end

  def comment=(string)
    WIN32OLE.connect(OLEPrefix + CIMV2).get(ShareType + name).setshareinfo(maxcon, string)
  end

  def maxcon
    WIN32OLE.connect(OLEPrefix + CIMV2).get(ShareType + name).maximumallowed || :absent
  end

  def maxcon=(int)
    WIN32OLE.connect(OLEPrefix + CIMV2).get(ShareType + name).setshareinfo(int, comment)
  end

  private

  def eval(action)
    raise(Puppet::Error, ExitCodes[action]) unless action == 0
  end

  def name
    "='" + @resource[:name] + "'"
  end

end
