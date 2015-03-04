require 'win32ole' if Facter['osfamily'].value == 'windows'

class SecurityDescriptor

  attr_accessor :username, :sid

  def initialize
    @wmi_session = WIN32OLE.connect("winmgmts://localhost/root/cimv2")
  end

  def trustee
    trust = @wmi_session.get("Win32_Trustee").spawninstance_
    trust.name = @username
    trust.sid = @sid
    return trust
  end

  def sd
    sd = @wmi_session.get("Win32_SecurityDescriptor").spawninstance_
    sd.controlflags = 4
    sd.owner = trustee
    return sd
  end

end
