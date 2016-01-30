begin; require 'win32ole'; rescue Exception; end

Puppet::Type.type(:fileshare).provide(:wmi) do
  desc "Manage Windows file shares"
  confine :operatingsystem => :windows
  defaultfor :operatingsystem => :windows

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
    handle_wmi_error do
      wmi('winmgmts:Win32_Share').create(@resource[:path], @resource[:name], 0, nil, nil)
    end

    self.owner = @resource[:owner]
    self.maxcon = @resource[:maxcon]
    self.comment = @resource[:comment]
  end

  def destroy
    handle_wmi_error do
      wmi.get("Win32_Share#{name_slug}").delete
    end
  end

  def exists?
    begin; wmi.get("Win32_Share#{name_slug}"); rescue; return false; end
    true
  end

  def owner
    wmi.get("Win32_LogicalShareSecuritySetting#{name_slug}").getsecuritydescriptor(4)
    dacl = WIN32OLE::ARGV[0].DACL[0]

    return :absent unless dacl

    Trustee.from_dacl(dacl)
  end

  def owner=(owner_hash)
    trustee = Trustee.new.merge(owner_hash)
    wmi.get("Win32_LogicalShareSecuritySetting#{name_slug}").setsecuritydescriptor(trustee.to_sd)
  end

  def comment
    wmi.get("Win32_Share#{name_slug}").description || :absent
  end

  def comment=(string)
    wmi.get("Win32_Share#{name_slug}").setshareinfo(@resource[:maxcon], string)
  end

  def maxcon
    wmi.get("Win32_Share#{name_slug}").maximumallowed || :absent
  end

  def maxcon=(int)
    wmi.get("Win32_Share#{name_slug}").setshareinfo(int, @resource[:comment])
  end

  class Trustee < Hash
    def self.from_dacl(dacl)
      hash = new
      hash['accessmask'] = String(dacl.accessmask)
      hash['sid'] = dacl.trustee.sid
      hash['username'] = dacl.trustee.name
      hash
    end

    def to_trustee
      trustee = WIN32OLE.connect('winmgmts://localhost/root/cimv2').get('Win32_Trustee').spawninstance_
      trustee.name = self['username']
      trustee.sid = self['sid']
      trustee
    end

    def to_sd
      sd = WIN32OLE.connect('winmgmts://localhost/root/cimv2').get('Win32_SecurityDescriptor').spawninstance_
      sd.controlflags = 4
      sd.owner = to_trustee
      sd
    end
  end

  private

  # Take a block, yield it, and raise an error with the applicable
  # message given a yielded WMI call. This is intended to wrap WMI
  # operations that don't return a value, but may fail by returning
  # non-0.
  def handle_wmi_error
    code = yield
    raise(Puppet::Error, ExitCodes[code]) unless code == 0
  end

  # WMI constructs a WIN32OLE object in a provided or default namespace
  # and returns it.
  def wmi(str=nil)
    WIN32OLE.connect(str || 'winmgmts://localhost/root/cimv2')
  end

  def name_slug
    "='" + @resource[:name] + "'"
  end
end
