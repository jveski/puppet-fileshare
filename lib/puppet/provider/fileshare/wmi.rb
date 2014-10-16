require 'win32ole'

Puppet::Type.type(:fileshare).provide(:wmi) do
  desc "Create/Destroy Windows File Shares"

  def create
    return_values = {
      0 => "success",
      2 => "access denied",
      8 => "unknown failure",
      9 => "invalid name",
      10 => "invalid level",
      21 => "invalid parameter",
      22 => "duplicate share",
      23 => "redirected path",
      24 => "unknown directory",
      25 => "net name not found",
    }
    wmi = WIN32OLE.connect("winmgmts:Win32_Share")
    creator = wmi.Create(String(@resource[:path]), String(@resource[:name]), Integer(@resource[:max_con]))
    # If the WMI call doesn't return 0, raise an error containing the appropriate message
    unless creator == 0
      raise(return_values[creator])
    end
  end

  def destroy
    return_values = {
      0 => "success",
      2 => "access denied",
      8 => "unknown failure",
      9 => "invalid name",
      10 => "invalid level",
      21 => "invalid parameter",
      22 => "duplicate share",
      23 => "redirected path",
      24 => "unknown directory",
      25 => "net name not found",
    }
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
