require 'win32ole' if Facter['osfamily'].value == 'windows'

class Fileshare

  attr_accessor :name, :path

  def initialize(name)
    @wmi_session = WIN32OLE.connect("winmgmts://localhost/root/cimv2")
    @name = name
  end

  def create
    wmi = WIN32OLE.connect("winmgmts:Win32_Share")
    creation = wmi.create(@path, @name, 0, nil, nil)
    evaluate_success(creation)
  end

  def delete
    deletion = @wmi_session.get("Win32_Share='#{@name}'").delete
    evaluate_success(deletion)
  end

  def exists?
    begin
      @wmi_session.get("Win32_Share='#{@name}'") #Raises exception if share doesn't exist
      return true
    rescue
      return false
    end
  end

  def comment
    @wmi_session.get("Win32_Share='#{@name}'").description
  end
  
  def comment=(string)
    @wmi_session.get("Win32_Share='#{@name}'").setshareinfo(maxcon, string)
  end

  def maxcon
    @wmi_session.get("Win32_Share='#{@name}'").maximumallowed
  end

  def maxcon=(int)
    @wmi_session.get("Win32_Share='#{@name}'").setshareinfo(int, comment)
  end

  def sd=(sd)
    share = @wmi_session.get("Win32_LogicalShareSecuritySetting='#{@name}'")
    share.setsecuritydescriptor(sd)
  end

  def dacl
    share = @wmi_session.get("Win32_LogicalShareSecuritySetting='#{@name}'")
    share.getsecuritydescriptor(4)
    returns = WIN32OLE::ARGV[0] #Retrospectively receives args from GetSecurityDescriptor
    return returns.DACL
  end

  private

  # Responsible for raising the correct error message for a given code
  def evaluate_success(action)
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
    raise(return_values[action]) unless action == 0
  end

end
