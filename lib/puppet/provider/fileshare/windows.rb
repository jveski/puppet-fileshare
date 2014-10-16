require 'win32ole'

Puppet::Type.type(:fileshare).provide(:windows) do
  desc "Create/Destroy Windows File Shares"
  confine :operatingsystem => :windows
  defaultfor :operatingsystem => :windows

  include Puppet::Provider::Fileshare::Windows::Security

  def create
    creator = WIN32OLE.connect("winmgmts:Win32_Share").Create(String(@resource[:path]), String(@resource[:name]), Integer(@resource[:max_con]))
    # If the WMI call doesn't return 0, raise an error containing the appropriate message
    #share.setsecuritydescriptor(sd)
    unless creator == 0
      raise(return_values[creator])
    end
  end

  def destroy
    wmi = WIN32OLE.connect('winmgmts://localhost/root/cimv2')
    destroyer = wmi.Get("Win32_Share='#{share_name}'").delete
    if destroyer != 0
      raise(return_values[return_values])
    end
  end

  # Ugly, uses error handling to determine if share exists
  def exists?
    wmi = WIN32OLE.connect('winmgmts://localhost/root/cimv2')
    begin
      wmi.Get("Win32_Share='#{@resource[:name]}'") #Raises exception if share doesn't exist
      return true
    rescue
      return false
    end
  end

end
