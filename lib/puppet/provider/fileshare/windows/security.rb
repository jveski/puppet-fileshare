class Puppet::Provider::Fileshare
  module Windows
    module Security

      def everyone_full_sd
        wmi_session = WIN32OLE.connect("winmgmts://localhost/root/cimv2")

        # Spawn Win32_Trustee
        trustee = wmi_session.get("Win32_Trustee").spawninstance_
        trustee.name = 'Everyone'
        trustee.sidstring = 'S-1-1-0'

        # Spawn Win32_SecurityDescriptor
        sd = wmi_session.get("Win32_SecurityDescriptor").spawninstance_
        sd.controlflags = 4

        # Add Trustee to SD
        sd.owner = trustee
        sd
      end

      # Give everyone full access to the shar
      # Access should be managed through NTFS permissions
      def set_acl share_name
        wmi = WIN32OLE.connect('winmgmts://localhost/root/cimv2')
        share = wmi.get("Win32_LogicalShareSecuritySetting='#{share_name}'")
        share.setsecuritydescriptor(everyone_full_sd)
        notice ("Set ACL for file share #{share_name}")
      end

      # Gets a share's DACL object
      def get_dacl share_name
        wmi_session = WIN32OLE.connect("winmgmts://localhost/root/cimv2")
        share = wmi_session.Get("Win32_LogicalShareSecuritySetting='#{share_name}'")
        share.GetSecurityDescriptor(4)
        returns = WIN32OLE::ARGV[0] #Retrospectively receives args from GetSecurityDescriptor
        return returns.DACL
      end

      # Checks if Everyone has full control
      def permissions? share_name
        get_dacl(share_name).each do |acl|
          if acl.trustee.name == 'Everyone' && acl.accessmask == 2032127
            return true
          end
        end
        return false
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
end
