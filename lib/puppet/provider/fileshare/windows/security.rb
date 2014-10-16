class Puppet::Provider::Fileshare
  module Security

    def get_everyone_trustee
      trustee = WIN32OLE.connect("winmgmts://localhost/root/cimv2").get("Win32_Trustee").spawninstance_
      trustee.name = 'Everyone'
      trustee.domain = nil
      trustee.sid = 'S-1-1-0' 
      trustee
    end

    def ace trustee
      ace = wmi_session.get("Win32_Ace").spawninstance_
      ace.accessmask = 20321
      ace.aceflags = 3
      ace.acetype = 0
      ace.trustee = trustee
      ace
    end

    def spawn_sd acl
      sd = wmi_session.get("Win32_SecurityDescriptor").spawninstance_
      sd.dacl = acl
      sd
    end

    def everyone_full_sd
      spawn_sd(ace(get_everyone_trustee))
    end

    # Hash of exit codes / messages
    def return_values
      {
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
    end
  end
end
