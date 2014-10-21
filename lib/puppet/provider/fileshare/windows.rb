require 'win32ole'
require 'pathname'

Puppet::Type.type(:fileshare).provide(:windows) do
  desc "Create/Destroy Windows File Shares"
  confine :operatingsystem => :windows
  defaultfor :operatingsystem => :windows

  require Pathname.new(__FILE__).dirname + '../../../' + 'puppet/provider/fileshare/windows/security'
  include Puppet::Provider::Fileshare::Windows::Security

  def create
    wmi = WIN32OLE.connect("winmgmts:Win32_Share")
    creator = wmi.Create(String(@resource[:path]), String(@resource[:name]), 0, nil, String(@resource[:comment]))
    # If the WMI call doesn't return 0, raise an error containing the appropriate message
    unless creator == 0
      raise(return_values[creator])
    end
    # Give Everyone full access
    set_acl @resource[:name]
  end

  def destroy
    wmi = WIN32OLE.connect('winmgmts://localhost/root/cimv2')
    destroyer = wmi.Get("Win32_Share='#{String(@resource[:name])}'").delete
    # If the WMI call doesn't return 0, raise an error containing the appropriate message
    unless destroyer == 0
      raise(return_values[return_values])
    end
  end

  # Ugly, uses error handling to determine if share exists
  def exists?
    share_exists = false
    wmi = WIN32OLE.connect('winmgmts://localhost/root/cimv2')
    begin
      share = wmi.Get("Win32_Share='#{@resource[:name]}'") #Raises exception if share doesn't exist
      share_exists = true
    rescue
      share_exists = false
    end

    if share_exists
      # Check permissions
      unless permissions? @resource[:name]
        set_acl @resource[:name]
      end
      # Check comment
      if @resource[:comment]
        unless share.caption == String(@resource[:comment])
          share.setshareinfo(nil, String(@resource[:comment]))
          notice "Set comment"
        end
      end
      return true
    else
      return false
    end
  end

end
