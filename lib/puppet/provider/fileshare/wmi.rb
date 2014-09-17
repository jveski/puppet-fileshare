require 'win32ole'

Puppet::Type.type(:fileshare).provide(:wmi) do
  desc "Windows file share functionality."

  def grant_user(share_name, user_name, user_domain, user_access)
    wmi_session = WIN32OLE.connect("winmgmts://localhost/root/cimv2")
    #Create Trustee
    begin
      trustee = wmi_session.get("Win32_Trustee").spawninstance_
      account = wmi_session.get("Win32_UserAccount.Name='#{user_name}',Domain='#{user_domain}'") #get existing user
      sid = wmi_session.get("Win32_SID.SID='#{account.sid}'").binaryrepresentation #get sid object for existing user
      trustee.name = user_name
      trustee.domain = user_domain
      trustee.sid = sid
    rescue
      raise("Couldn't Locate User #{user_domain}\\#{user_name}")
    end
    #Create ACE
    ace = wmi_session.get("Win32_Ace").spawninstance_
    ace.accessmask = user_access
    ace.aceflags = 3
    ace.acetype = 0
    ace.trustee = trustee
    #Get Old DACL
    begin
      share = wmi_session.get("Win32_LogicalShareSecuritySetting='#{share_name}'")
      share.GetSecurityDescriptor(1)
      out = WIN32OLE::ARGV[0] #Retrospectively receives args from GetSecurityDescriptor
      dacl = out.DACL
      sd_flags = out.controlflags
      dacl << ace
      #Prepare SecurityDescriptor
      sd = wmi_session.get("Win32_SecurityDescriptor").spawninstance_
      sd.controlflags = sd_flags
      sd.dacl = dacl
      #Push SecurityDescriptor to file share
      share.setsecuritydescriptor(sd)
      notice("Giving #{user_domain}\\#{user_name} Access to #{share_name}")
    rescue
      raise("Couldn't Update Security Settings for #{share_name}")
    end
  end

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
    share_permissions = {
      "full" => 2032127,
      "read" => 1179817,
      "change" => 1245631,
    }
    wmi = WIN32OLE.connect("winmgmts:Win32_Share")
    creator = wmi.Create(String(@resource[:path]), String(@resource[:name]), Integer(@resource[:max_con]))
    if creator == 0
      @resource[:permissions].each do |user, permissions|
        user_name = user.split("\\")[1]
        domain = user.split("\\")[0]
        grant_user(@resource[:name], user_name, domain, share_permissions[permissions])
      end
    else
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

  def check_permissions 
  share_permissions = {
      "full" => 2032127,
      "read" => 1179817,
      "change" => 1245631,
    }
    wmi = WIN32OLE.connect('winmgmts://localhost/root/cimv2')
    @resource[:permissions].each do |resource_user, resource_perm|
      resource_user_name = resource_user.split("\\")[1]
      resource_user_domain = resource_user.split("\\")[0]
      share = wmi.Get("Win32_LogicalShareSecuritySetting='#{@resource[:name]}'")
      share.GetSecurityDescriptor(1)
      acl = WIN32OLE::ARGV[0] #Retrospectively receives args from GetSecurityDescriptor
      user_is_included = false
      permissions_are_correct = false
      acl.DACL.each do |current_user|
        user_is_included = resource_user.downcase == (String(current_user.trustee.domain) + '\\' + String(current_user.trustee.name)).downcase
        if user_is_included
          permissions_are_correct = share_permissions.key(current_user.accessmask) == resource_perm
        end
      end
      if not user_is_included
        debug("#{resource_user_name} Isn't Included in the ACL for #{@resource[:name]}")
        grant_user(@resource[:name], resource_user_name, resource_user_domain, share_permissions[resource_perm])
      elsif !(user_is_included && permissions_are_correct)
        debug("#{resource_user_name} at #{@resource[:name]} Doesn't Have the Correct Permissions")
        grant_user(@resource[:name], resource_user_name, resource_user_domain, share_permissions[resource_perm])
      end
    end
  end

  def exists?
    wmi = WIN32OLE.connect('winmgmts://localhost/root/cimv2')
    begin
      wmi.Get("Win32_Share='#{@resource[:name]}'") #Raises exception if share doesn't exist
      check_permissions #Only check permissions if the block lived this long - aka only if the share exists
      return true
    rescue
      return false
    end
  end

end
